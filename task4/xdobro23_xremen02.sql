DROP TABLE zivocich CASCADE CONSTRAINTS;

DROP TABLE umiestnenie CASCADE CONSTRAINTS;
DROP TABLE bol_umiestneny CASCADE CONSTRAINTS;

DROP TABLE vlastnost CASCADE CONSTRAINTS;
DROP TABLE typ_vlastnosti;

DROP TABLE typ_zivocicha;
DROP TABLE trieda_zivocicha;
DROP TABLE druh_zivocicha;
DROP TABLE rad_zivocicha;
DROP TABLE celad_zivocicha;
DROP TABLE rod_zivocicha;

DROP TABLE zamestnanec CASCADE CONSTRAINTS;
DROP TABLE pozicia;

DROP TABLE osetruje CASCADE CONSTRAINTS;
DROP TABLE klietka CASCADE CONSTRAINTS;


CREATE TABLE zivocich
(
    ID_zivocicha    INT             GENERATED BY DEFAULT AS IDENTITY (START WITH 1 INCREMENT BY 1) NOT NULL,
    meno            VARCHAR2(64)    NOT NULL,
    datum_narodenia DATE            NOT NULL,
    datum_umrtia    DATE,

    ID_typu         INT             NOT NULL,

    PRIMARY KEY (ID_zivocicha)
);

-- Generalizovane entity `Pavilon` a `Vybeh` sme zlucili do entity `Umiestnenie`
-- pretoze su totalne a disjunktne.
-- Taktiez sme pridali integritne obmedzenie (`CHECK`), ktore kontroluje,
-- ze je zadana bud `interakcia` ak ide o vybeh alebo su vyplnene OBA atributy
-- `teplota` a `vlhost` ak ide o pavilon, nebolo teda treba pridavat dodatocny
-- atribut `typ`, ktory by rozlisoval, ci sa jedna o `Pavilon` alebo `Vybeh`.
CREATE TABLE umiestnenie
(
    ID_umiestnenia  INT             GENERATED BY DEFAULT AS IDENTITY (START WITH 1 INCREMENT BY 1) NOT NULL,
    nazov          VARCHAR2(64)             NOT NULL,
    vyuzitelna_plocha         INT           NOT NULL,

    --vybeh
    interakcia              NUMBER(1,0),

    -- pavilon
    teplota                 FLOAT,
    vlhkost                 INT,

    CHECK (interakcia IS NULL OR (teplota IS NULL AND vlhkost IS NULL)), -- kontrola specializacie
    PRIMARY KEY (ID_umiestnenia)
);

CREATE TABLE klietka
(
    ID_klietky      INT             GENERATED BY DEFAULT AS IDENTITY (START WITH 1 INCREMENT BY 1) NOT NULL,
    nazov           VARCHAR2(64) NOT NULL,
    kod_zamku       NUMBER(6) NOT NULL,

    ID_pavilonu     INT NOT NULL,

    CONSTRAINT FK_pavilonu FOREIGN KEY (ID_pavilonu) REFERENCES umiestnenie ON DELETE CASCADE,
    PRIMARY KEY (ID_pavilonu, ID_klietky) -- diskriminator
);


CREATE TABLE bol_umiestneny
(
    ID_zivocicha    INT             NOT NULL,
    ID_umiestnenia  INT             NOT NULL,
    ID_zamestnanca  INT, --moze byt null, ak by sa zamestnanec prepustil

    od              DATE            NOT NULL,
    do              DATE,

    CHECK ( od <= do ),
    PRIMARY KEY (ID_zivocicha, ID_umiestnenia, od)
);

CREATE TABLE vlastnost
(
    ID_merania      INT             GENERATED BY DEFAULT AS IDENTITY (START WITH 1 INCREMENT BY 1) NOT NULL,
    hodnota         VARCHAR2(256)   NOT NULL,
    datum           DATE            NOT NULL,

    ID_zivocicha    INT             NOT NULL,
    ID_zamestnanca  INT,  -- moze byt null, ked niekoho prepustime, zaznam sa vymaze spolu so zivocichom
    ID_vlastnosti   INT            NOT NULL,

    PRIMARY KEY (ID_merania)
);

CREATE TABLE typ_vlastnosti
(
    ID_vlastnosti   INT             GENERATED BY DEFAULT AS IDENTITY (START WITH 1 INCREMENT BY 1) NOT NULL,
    nazov           VARCHAR2(64)    NOT NULL,
    popis           VARCHAR2(256),

    PRIMARY KEY (ID_vlastnosti)
);

CREATE TABLE typ_zivocicha
(
    ID_typu         INT             GENERATED BY DEFAULT AS IDENTITY (START WITH 1 INCREMENT BY 1) NOT NULL,

    ID_triedy       INT             NOT NULL,
    ID_druhu        INT             NOT NULL,
    ID_radu         INT             NOT NULL,
    ID_celade       INT             NOT NULL,
    ID_rodu         INT             NOT NULL,

    PRIMARY KEY (ID_typu),
    UNIQUE (ID_triedy, ID_druhu, ID_radu, ID_celade, ID_rodu)
);

CREATE TABLE trieda_zivocicha
(
    ID_triedy       INT             GENERATED BY DEFAULT AS IDENTITY (START WITH 1 INCREMENT BY 1) NOT NULL,
    nazov           VARCHAR2(64)    NOT NULL,
    popis           VARCHAR2(256),

    PRIMARY KEY (ID_triedy)
);


CREATE TABLE druh_zivocicha
(
    ID_druhu       INT             GENERATED BY DEFAULT AS IDENTITY (START WITH 1 INCREMENT BY 1) NOT NULL,
    nazov          VARCHAR2(64)    NOT NULL,
    popis          VARCHAR2(256),

    PRIMARY KEY (ID_druhu)
);


CREATE TABLE rad_zivocicha
(
    ID_radu       INT             GENERATED BY DEFAULT AS IDENTITY (START WITH 1 INCREMENT BY 1) NOT NULL,
    nazov         VARCHAR2(64)    NOT NULL,
    popis         VARCHAR2(256),

    PRIMARY KEY (ID_radu)
);


CREATE TABLE celad_zivocicha
(
    ID_celade       INT             GENERATED BY DEFAULT AS IDENTITY (START WITH 1 INCREMENT BY 1) NOT NULL,
    nazov           VARCHAR2(64)    NOT NULL,
    popis           VARCHAR2(256),

    PRIMARY KEY (ID_celade)
);


CREATE TABLE rod_zivocicha
(
    ID_rodu         INT             GENERATED BY DEFAULT AS IDENTITY (START WITH 1 INCREMENT BY 1) NOT NULL,
    nazov           VARCHAR2(64)    NOT NULL,
    popis           VARCHAR2(256),

    PRIMARY KEY (ID_rodu)
);


CREATE TABLE zamestnanec
(
    ID_zamestnanca  INT             GENERATED BY DEFAULT AS IDENTITY (START WITH 1 INCREMENT BY 1) NOT NULL,
    meno            VARCHAR2(64)    NOT NULL,
    priezvisko      VARCHAR2(64)    NOT NULL,
    heslo           VARCHAR2(256)   NOT NULL,
    rodne_cislo     VARCHAR2(11),  -- moze byt cudzinec, ten RC nema
    pozicia         INT,


    CHECK ( REGEXP_LIKE(rodne_cislo, '^\d{2}(0[1-9]|1[0-2]|5[1-9]|6[0-2])(0[1-9]|1[0-9]|2[0-9]|3[0-1])/\d{3,4}$') ),
    CHECK ( MOD(TO_NUMBER(REPLACE(rodne_cislo, '/', '')), 11) = 0 ),
    PRIMARY KEY (ID_zamestnanca)
);

CREATE TABLE pozicia
(
    ID_pozicie      INT             GENERATED BY DEFAULT AS IDENTITY (START WITH 1 INCREMENT BY 1) NOT NULL,
    nazov           VARCHAR2(64)    NOT NULL,
    napln_prace     VARCHAR2(256)   NOT NULL,

    PRIMARY KEY (ID_pozicie)
);
ALTER TABLE zamestnanec ADD CONSTRAINT pracuje_ako          FOREIGN KEY (pozicia)    REFERENCES pozicia  ON DELETE SET NULL;


CREATE TABLE osetruje
(
    ID_zivocicha    INT     NOT NULL,
    ID_zamestnanca  INT     NOT NULL
);
ALTER TABLE osetruje ADD CONSTRAINT stara_sa          FOREIGN KEY (ID_zamestnanca)    REFERENCES zamestnanec  ON DELETE CASCADE;
ALTER TABLE osetruje ADD CONSTRAINT je_postarane      FOREIGN KEY (ID_zivocicha)    REFERENCES zivocich  ON DELETE CASCADE;


ALTER TABLE vlastnost ADD CONSTRAINT ma_vlastnost   FOREIGN KEY (ID_zivocicha)      REFERENCES zivocich     ON DELETE CASCADE;
ALTER TABLE vlastnost ADD CONSTRAINT zadal          FOREIGN KEY (ID_zamestnanca)    REFERENCES zamestnanec  ON DELETE SET NULL;
ALTER TABLE vlastnost ADD CONSTRAINT je_typu          FOREIGN KEY (ID_vlastnosti)    REFERENCES typ_vlastnosti;

ALTER TABLE zivocich ADD CONSTRAINT kategoria       FOREIGN KEY (ID_typu)    REFERENCES typ_zivocicha;
ALTER TABLE typ_zivocicha ADD CONSTRAINT patri_triede   FOREIGN KEY (ID_triedy)  REFERENCES trieda_zivocicha;
ALTER TABLE typ_zivocicha ADD CONSTRAINT patri_druhu    FOREIGN KEY (ID_druhu)   REFERENCES druh_zivocicha;
ALTER TABLE typ_zivocicha ADD CONSTRAINT patri_radu     FOREIGN KEY (ID_radu)    REFERENCES rad_zivocicha;
ALTER TABLE typ_zivocicha ADD CONSTRAINT patri_celadi   FOREIGN KEY (ID_celade)  REFERENCES celad_zivocicha;
ALTER TABLE typ_zivocicha ADD CONSTRAINT patri_rodu     FOREIGN KEY (ID_rodu)    REFERENCES rod_zivocicha;


ALTER TABLE bol_umiestneny ADD CONSTRAINT je_v     FOREIGN KEY (ID_zivocicha)    REFERENCES zivocich ON DELETE CASCADE;
ALTER TABLE bol_umiestneny ADD CONSTRAINT umiestnil     FOREIGN KEY (ID_zamestnanca)    REFERENCES zamestnanec ON DELETE SET NULL;
ALTER TABLE bol_umiestneny ADD CONSTRAINT poloha     FOREIGN KEY (ID_umiestnenia)    REFERENCES umiestnenie;


INSERT INTO typ_vlastnosti(nazov, popis) VALUES ('Hmotnost', 'novorodenecka hmotnost');
INSERT INTO typ_vlastnosti(nazov, popis) VALUES ('Vyska', 'novorodenecka vyska');


INSERT INTO pozicia(nazov, napln_prace) VALUES ('Riaditel', 'Nic nerobenie');
INSERT INTO pozicia(nazov, napln_prace) VALUES ('Osetrovatel', 'Staranie sa o pridelene zvierata');
INSERT INTO pozicia(nazov, napln_prace) VALUES ('Spravca', 'Zodpovednost za chod IT systemov');
INSERT INTO pozicia(nazov, napln_prace) VALUES ('Sekretarka', 'Zodpovednost za chod kancelarie');

INSERT INTO zamestnanec(meno, priezvisko, heslo, rodne_cislo, pozicia) VALUES ('Jozef', 'Mrkvicka', 'sompan123', '770821/4338', 1);
INSERT INTO zamestnanec(meno, priezvisko, heslo, rodne_cislo, pozicia) VALUES ('Martin', 'Osetrovatel', 'milujemzvieratka666', '810615/0019', 2);
INSERT INTO zamestnanec(meno, priezvisko, heslo, rodne_cislo, pozicia) VALUES ('Jan', 'Obstaral', 'somobstaral42', '841207/0095', 2);
INSERT INTO zamestnanec(meno, priezvisko, heslo, rodne_cislo, pozicia) VALUES ('Magda', 'Pomocna', 'pomahatachranit158', '935614/0101', 2);
INSERT INTO zamestnanec(meno, priezvisko, heslo, rodne_cislo, pozicia) VALUES ('Samuel', 'Kazisvet', 'p4$$w0rd', '970903/0067', 3);
INSERT INTO zamestnanec(meno, priezvisko, heslo, rodne_cislo, pozicia) VALUES ('Erzika', 'Sikovna', 'princesska2468', '555207/0095', 4);


--Vybeh bez interakcie--
INSERT INTO umiestnenie(nazov, vyuzitelna_plocha, interakcia) VALUES ('Safari', 2000, 0);

INSERT INTO trieda_zivocicha(nazov, popis) VALUES ('Cicavce', 'saju mliecko');
INSERT INTO druh_zivocicha(nazov , popis) VALUES ('Zirafa severna', 'ale zije na juhu'); -- zirafa na safari
INSERT INTO rad_zivocicha(nazov, popis) VALUES ('Parnokopytnici', 'muz ma skoro 3 nohy');
INSERT INTO celad_zivocicha(nazov) VALUES ('Zirafovite');
INSERT INTO rod_zivocicha(nazov, popis) VALUES ('Zirafa', 'Giraffa');
INSERT INTO typ_zivocicha(ID_triedy, ID_druhu, ID_radu, ID_celade, ID_rodu) VALUES(1, 1, 1, 1, 1);

INSERT INTO zivocich(meno, datum_narodenia, ID_typu) VALUES ('Spageta', TO_DATE('01.02.2022', 'dd.mm.yyyy'), 1);
INSERT INTO vlastnost(hodnota, datum, ID_zivocicha, ID_zamestnanca, ID_vlastnosti) VALUES (168, TO_DATE('01022022', 'ddmmyyyy'), 1, 2, 1);
INSERT INTO osetruje(ID_zivocicha, ID_zamestnanca) VALUES (1, 2);
INSERT INTO bol_umiestneny(id_zivocicha, id_umiestnenia, id_zamestnanca, od) VALUES (1, 1, 2, TO_DATE('01.02.2022', 'dd.mm.yyyy'));

--Vybeh s interakciou--
INSERT INTO umiestnenie(nazov, vyuzitelna_plocha, interakcia) VALUES ('Stredoeuropsky les', 700, 1);

INSERT INTO druh_zivocicha(nazov , popis) VALUES ('Rys ostrovid', 'ale skuli'); -- rys v lese
INSERT INTO rad_zivocicha(nazov, popis) VALUES ('Selmy', 'lovi ine zvierata');
INSERT INTO celad_zivocicha(nazov) VALUES ('Mackovite');
INSERT INTO rod_zivocicha(nazov, popis) VALUES ('Rys', 'Lynx');
INSERT INTO typ_zivocicha(ID_triedy, ID_druhu, ID_radu, ID_celade, ID_rodu) VALUES(1, 2, 2, 2, 2);

INSERT INTO zivocich(meno, datum_narodenia, ID_typu) VALUES ('Skulko', TO_DATE('13022022', 'dd.mm.yyyy'), 2);
INSERT INTO vlastnost(hodnota, datum, ID_zivocicha, ID_zamestnanca, ID_vlastnosti) VALUES (78, TO_DATE('13022022', 'ddmmyyyy'), 2, 3, 1);
INSERT INTO osetruje(ID_zivocicha, ID_zamestnanca) VALUES (2, 3);
INSERT INTO bol_umiestneny(id_zivocicha, id_umiestnenia, id_zamestnanca, od) VALUES (2, 2, 2, TO_DATE('13.02.2022', 'dd.mm.yyyy'));

--Pavilon--
INSERT INTO umiestnenie(nazov, vyuzitelna_plocha, teplota, vlhkost) VALUES ('Okolie rieky Nil', 1000, 29.6, 60);

INSERT INTO druh_zivocicha(nazov , popis) VALUES ('Slon africky', 'ale zije na juhu'); -- slon pri rieke
INSERT INTO rad_zivocicha(nazov, popis) VALUES ('Chobotnac', 'muz ma skoro 3 nohy');
INSERT INTO celad_zivocicha(nazov, popis) VALUES ('Slonovita', 'Tato celad ma dlhe choboty');
INSERT INTO rod_zivocicha(nazov, popis) VALUES ('Slon', 'Loxodonta');
INSERT INTO typ_zivocicha(ID_triedy, ID_druhu, ID_radu, ID_celade, ID_rodu) VALUES(1, 3, 3, 3, 3);

INSERT INTO zivocich(meno, datum_narodenia, ID_typu) VALUES ('Boris', TO_DATE('01.09.2021', 'dd.mm.yyyy'), 3);
INSERT INTO vlastnost(hodnota, datum, ID_zivocicha, ID_zamestnanca, ID_vlastnosti) VALUES (400, TO_DATE('01092021', 'ddmmyyyy'), 3, 1, 1);
INSERT INTO osetruje(ID_zivocicha, ID_zamestnanca) VALUES (3, 2);
INSERT INTO bol_umiestneny(id_zivocicha, id_umiestnenia, id_zamestnanca, od) VALUES (3, 3, 2, TO_DATE('01.09.2021', 'dd.mm.yyyy'));


--Pavilon s klietkami--
INSERT INTO umiestnenie(nazov, vyuzitelna_plocha, teplota, vlhkost) VALUES ('Skandinavska krajina', 1500, 9.6, 10);
INSERT INTO klietka(nazov, kod_zamku, ID_pavilonu) VALUES ('Skandinavske vtactvo', 133742, 4);

INSERT INTO trieda_zivocicha(nazov, popis) VALUES ('Vtaky', 'Ti co lietaju');
INSERT INTO druh_zivocicha(nazov , popis) VALUES ('Orol skalny', 'Aquila chrysaetos');
INSERT INTO rad_zivocicha(nazov, popis) VALUES ('Dravec', 'Caka na potravu, pokial k nemu pride');
INSERT INTO celad_zivocicha(nazov, popis) VALUES ('Jastrabovita', 'Skoro ako lastovicka');
INSERT INTO rod_zivocicha(nazov, popis) VALUES ('Orol', 'Aquila');
INSERT INTO typ_zivocicha(ID_triedy, ID_druhu, ID_radu, ID_celade, ID_rodu) VALUES(2, 4, 4, 4, 4);

INSERT INTO zivocich(meno, datum_narodenia, ID_typu) VALUES ('Letec', TO_DATE('04.05.2019', 'dd.mm.yyyy'), 4);
INSERT INTO vlastnost(hodnota, datum, ID_zivocicha, ID_zamestnanca, ID_vlastnosti) VALUES (70, TO_DATE('04052019', 'ddmmyyyy'), 1, 4, 2);
INSERT INTO osetruje(ID_zivocicha, ID_zamestnanca) VALUES (4, 4);
INSERT INTO bol_umiestneny(id_zivocicha, id_umiestnenia, id_zamestnanca, od) VALUES (4, 4, 4, TO_DATE('04.05.2019', 'dd.mm.yyyy'));


--------------- Uloha 3 ----------

--spojenie 2 tabuliek
--vypíše meno, priezvisko, nazov pozicie a náplň práce zamestnanca
SELECT meno, priezvisko, nazov, napln_prace FROM zamestnanec NATURAL JOIN pozicia WHERE pozicia.ID_pozicie = zamestnanec.pozicia;

--spojenie 2 tabuliek
--vypíše názov, popis a hodnotu meranej vlastnosti pre zviera s ID = 1 (žirafa)
SELECT nazov, popis, hodnota, datum FROM vlastnost NATURAL JOIN typ_vlastnosti WHERE ID_zivocicha = 1;


--dotaz s group by agregačnou f-ciou
--vypíše počet zadaných hodnôt pre jednotlivé merania
SELECT popis, COUNT(hodnota) pocet_zadanych_hodnot FROM vlastnost NATURAL JOIN typ_vlastnosti GROUP BY popis;

--spojenie 3 tabuliek
--vypíše mená živočíchov, kde sú umiestnené a o aký typ umiestnenia ide
SELECT meno, nazov, CASE WHEN interakcia is not null THEN 'Výbeh' ELSE 'Pavilón' END AS Typ_umiestnenia FROM zivocich NATURAL JOIN bol_umiestneny NATURAL JOIN umiestnenie;

-- VNORENY SELECT S POUZITIM IN:
-- Vypise ID, meno a datum narodenia zivocicha, ktory je cicavec.
-- Trieda zivocicha `Cicavec` je ulozena v tabulke `trieda_zivocicha`, 2. vnoreny SELECT by
-- sa teda dal nahradit za konstantu `1` pod ktorou je `Cicavec` v `trieda_zivocicha`
-- ale toto je prehladnejsie.
SELECT ID_zivocicha, meno, datum_narodenia FROM zivocich WHERE ID_typu IN (SELECT ID_typu FROM TYP_ZIVOCICHA WHERE ID_triedy = (SELECT ID_triedy FROM trieda_zivocicha WHERE nazov = 'Cicavce'));

-- SELECT S POUZITIM EXISTS
-- Vypise zamestnancov (ich ID, mena a priezviska), ktori neosetruju ziadne zviera.
SELECT ID_zamestnanca, meno, priezvisko FROM zamestnanec Z WHERE NOT EXISTS(SELECT * FROM osetruje WHERE osetruje.ID_zamestnanca = Z.ID_zamestnanca);


-- SELECT S AGREGACNOU FUNKCIOU A GROUP BY
-- Vypise ID zamestnanca, meno, jeho priezvisko a pocet zverat, ktore osetruje.
SELECT ID_zamestnanca, meno, priezvisko, COUNT(*) as pocet_osetrovanych FROM zamestnanec NATURAL JOIN osetruje GROUP BY ID_zamestnanca, meno, priezvisko ORDER BY pocet_osetrovanych DESC;


---- Uloha 4 ----

GRANT ALL ON "BOL_UMIESTNENY" TO xremen02;
GRANT ALL ON "CELAD_ZIVOCICHA" TO xremen02;
GRANT ALL ON "DRUH_ZIVOCICHA" TO xremen02;
GRANT ALL ON "KLIETKA" TO xremen02;
GRANT ALL ON "OSETRUJE" TO xremen02;
GRANT ALL ON "POZICIA" TO xremen02;
GRANT ALL ON "RAD_ZIVOCICHA" TO xremen02;
GRANT ALL ON "ROD_ZIVOCICHA" TO xremen02;
GRANT ALL ON "TRIEDA_ZIVOCICHA" TO xremen02;
GRANT ALL ON "TYP_VLASTNOSTI" TO xremen02;
GRANT ALL ON "TYP_ZIVOCICHA" TO xremen02;
GRANT ALL ON "UMIESTNENIE" TO xremen02;
GRANT ALL ON "VLASTNOST" TO xremen02;
GRANT ALL ON "ZAMESTNANEC" TO xremen02;
GRANT ALL ON "ZIVOCICH" TO xremen02;



-- Doplnenie zvierat do vybehu a pavilonu pre materialized view --
--jelen--
INSERT INTO druh_zivocicha(nazov , popis) VALUES ('Jelen europsky', 'american'); -- rys v lese
INSERT INTO celad_zivocicha(nazov) VALUES ('Jelenovite');
INSERT INTO rod_zivocicha(nazov, popis) VALUES ('Jelen', 'Cervus');
INSERT INTO typ_zivocicha(ID_triedy, ID_druhu, ID_radu, ID_celade, ID_rodu) VALUES(1, 5, 1, 5, 5);

INSERT INTO zivocich(meno, datum_narodenia, ID_typu) VALUES ('Parohac', TO_DATE('28022020', 'dd.mm.yyyy'), 5);
INSERT INTO vlastnost(hodnota, datum, ID_zivocicha, ID_zamestnanca, ID_vlastnosti) VALUES (30, TO_DATE('28022020', 'ddmmyyyy'), 5, 3, 1);
INSERT INTO osetruje(ID_zivocicha, ID_zamestnanca) VALUES (2, 3);
INSERT INTO bol_umiestneny(id_zivocicha, id_umiestnenia, id_zamestnanca, od) VALUES (5, 2, 2, TO_DATE('28.02.2020', 'dd.mm.yyyy'));

-- Materializovany pohlad - Pocet zivocichov v pavilonoch a vo vybehoch
DROP MATERIALIZED VIEW "pocet_zivocichov_v_umiestneniach";
CREATE MATERIALIZED VIEW "pocet_zivocichov_v_umiestneniach" AS
    SELECT
           nazov,
           CASE WHEN interakcia is not null THEN 'Výbeh' ELSE 'Pavilón' END AS "Typ umiestnenia",
           COUNT(*) as "Pocet zivocichov"
    FROM umiestnenie
    NATURAL JOIN bol_umiestneny
    GROUP BY
             nazov,
             interakcia
    ORDER BY "Pocet zivocichov" DESC;


SELECT * FROM "pocet_zivocichov_v_umiestneniach";

--zeriav--
INSERT INTO druh_zivocicha(nazov , popis) VALUES ('Zeriav bradavicnaty', 'ma ich ako striga'); -- slon pri rieke
INSERT INTO rad_zivocicha(nazov, popis) VALUES ('Kratkokridlovce', 'ledva lieta');
INSERT INTO celad_zivocicha(nazov, popis) VALUES ('Zeriavovite', 'neda sa ale pouzit na stavbe');
INSERT INTO rod_zivocicha(nazov, popis) VALUES ('Zeriav', 'Grus');
INSERT INTO typ_zivocicha(ID_triedy, ID_druhu, ID_radu, ID_celade, ID_rodu) VALUES(2, 6, 5, 6, 6);

INSERT INTO zivocich(meno, datum_narodenia, ID_typu) VALUES ('Caterpillar', TO_DATE('01.01.2021', 'dd.mm.yyyy'), 6);
INSERT INTO vlastnost(hodnota, datum, ID_zivocicha, ID_zamestnanca, ID_vlastnosti) VALUES (25, TO_DATE('01012021', 'ddmmyyyy'), 6, 4, 1);
INSERT INTO osetruje(ID_zivocicha, ID_zamestnanca) VALUES (6, 4);
INSERT INTO bol_umiestneny(id_zivocicha, id_umiestnenia, id_zamestnanca, od) VALUES (6, 3, 4, TO_DATE('01.01.2021', 'dd.mm.yyyy'));

SELECT * FROM "pocet_zivocichov_v_umiestneniach";
-- V umiestneni `Okolie rieky Nil` su 2 zvierata ale MV ukazuje len jedno
-- lebo sa este neupdatol a ma vo vyrovnavacej pamati stare data. Na aktualizaciu
-- je potrebne spravit refresh.

GRANT ALL ON "pocet_zivocichov_v_umiestneniach" TO XREMEN02;


-- Procedury --
-- Procedura vypise aktualny pocet zivych/mrtvych zvierat v databaze, priemerny pocet zvierat v umiestneni,
-- priemerny pocet zvierat na osetrovatela.
CREATE OR REPLACE PROCEDURE kompletny_prehlad
IS
	"zive_zvierata" NUMBER;
	"mrtve_zvierata" NUMBER;
	"celkovo_zvierat" NUMBER;
	"osetrovatelia" NUMBER;
	"umiestnenia" NUMBER;
	"priemer_v_umiestneni" NUMBER;
	"priemer_na_osetrovatela" NUMBER;
BEGIN
	SELECT COUNT(*) INTO "zive_zvierata" FROM ZIVOCICH WHERE datum_umrtia IS NULL;
	SELECT COUNT(*) INTO "mrtve_zvierata" FROM ZIVOCICH WHERE datum_umrtia IS NOT NULL;
	SELECT COUNT(*) INTO "osetrovatelia" FROM ZAMESTNANEC WHERE pozicia = (SELECT ID_pozicie FROM pozicia WHERE nazov='Osetrovatel');
	SELECT COUNT(*) INTO "umiestnenia" FROM umiestnenie;

	"priemer_v_umiestneni" := "zive_zvierata" / "umiestnenia";
	"priemer_na_osetrovatela" := "zive_zvierata" / "osetrovatelia";

	"celkovo_zvierat" := "zive_zvierata" + "mrtve_zvierata";

	DBMS_OUTPUT.PUT_LINE('Celkovo je v zoo ' || "celkovo_zvierat" || ' zvierat, z toho je ' ||
	                     "zive_zvierata" || ' zivych a ' || "mrtve_zvierata" || ' mrtvych.');

	DBMS_OUTPUT.PUT_LINE('Celkovo je v zoo ' || "umiestnenia" || ' umiestneni a priemerny pocet zvierat v nich je '
	                         || "priemer_v_umiestneni");

	DBMS_OUTPUT.PUT_LINE('Celkovo je v zoo ' || "osetrovatelia" || ' osetrovatelov. Priemerne kazdy osetruje ' ||
	                     "priemer_na_osetrovatela" || ' zvierat.');

	EXCEPTION WHEN ZERO_DIVIDE THEN
	BEGIN
		IF "umiestnenia" = 0 THEN
			DBMS_OUTPUT.put_line('Chybaju akekolvek umiestnenia!');
		END IF;

		IF "osetrovatelia" = 0 THEN
			DBMS_OUTPUT.put_line('Chybaju osetrovatelia!');
		END IF;
	END;
END;

BEGIN
    kompletny_prehlad;
end;


-- Triggre --
-- Pri zadani umrtia zvierata sa nastavi doba `do` v `bol_umiestneny` a odstrani jeho osetrovatela z `osetruje`.
-- Zaroven skontroluje, ze datum umrtia je validny.
CREATE OR REPLACE TRIGGER "vymaz_typ_zivocicha"
	BEFORE UPDATE ON "ZIVOCICH"
	FOR EACH ROW
BEGIN
    IF :new.datum_umrtia IS NOT NULL THEN
        IF :new.datum_umrtia < :old.datum_narodenia THEN
            RAISE_APPLICATION_ERROR(-20999, 'Datum umrtia nemoze byt skor ako narodenie.');
        END IF;

        UPDATE bol_umiestneny SET DO = :new.datum_umrtia WHERE ID_zivocicha = :new.ID_zivocicha;
        DELETE FROM osetruje WHERE osetruje.ID_zivocicha = :new.ID_zivocicha;
    END IF;
END;
