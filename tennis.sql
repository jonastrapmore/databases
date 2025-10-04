-- verwijderen van bestaande tabellen binnen het schema Tennis
IF OBJECT_ID('Tennis.Bestuurslid', 'U') IS NOT NULL
    DROP TABLE Tennis.Bestuurslid;

IF OBJECT_ID('Tennis.Boete', 'U') IS NOT NULL
    DROP TABLE Tennis.Boete;

IF OBJECT_ID('Tennis.Wedstrijd', 'U') IS NOT NULL
    DROP TABLE Tennis.Wedstrijd;

IF OBJECT_ID('Tennis.Team', 'U') IS NOT NULL
    DROP TABLE Tennis.Team;

IF OBJECT_ID('Tennis.Speler', 'U') IS NOT NULL
    DROP TABLE Tennis.Speler;

DROP SCHEMA IF EXISTS Tennis;
Go
-- aanmaken Tennis schema
CREATE SCHEMA Tennis;
GO

-- aanmaken van tabel Speler
CREATE TABLE Tennis.Speler
(
    id            int,
    naam          char(15)    NOT NULL,
    voornaam      char(15)    NOT NULL,
    geboortedatum date,
    geslacht      char(1)     NOT NULL,
    lidSinds      smallint    NOT NULL,
    straat        varchar(30) NOT NULL,
    huisnummer    char(4),
    postcode      char(6),
    plaats        varchar(30) NOT NULL,
    telefoon      char(13),
    bondsnummer   char(4),
    CONSTRAINT PK_Speler PRIMARY KEY (id),
    CONSTRAINT CK_Speler_geslacht CHECK (geslacht IN ('V', 'M')),
    CONSTRAINT CH_Speler_lidSinds CHECK (lidSinds > 1989),
    CONSTRAINT CH_Speler_postcode CHECK (postcode LIKE '______')
);

-- aanmaken van tabel Team
CREATE TABLE Tennis.Team
(
    id       int IDENTITY (1,1),
    spelerId int     NOT NULL,
    divisie  char(6) NOT NULL,
    CONSTRAINT PK_Team PRIMARY KEY (id),
    CONSTRAINT FK_Team_Speler FOREIGN KEY (spelerId) REFERENCES Tennis.Speler (id),
    CONSTRAINT CK_Team_divisiie CHECK (divisie IN ('ere', 'tweede'))
);

-- aanmaken van tabel Wedstrijd
CREATE TABLE Tennis.Wedstrijd
(
    id                 int IDENTITY (1,1),
    teamId             int      NOT NULL,
    spelerId           int      NOT NULL,
    aantalGewonnenSets smallint NOT NULL,
    aantalVerlorenSets smallint NOT NULL,
    CONSTRAINT PK_Wedstrijd PRIMARY KEY (id),
    CONSTRAINT FK_Wedstrijd_Team FOREIGN KEY (teamId) REFERENCES Tennis.Team (id),
    CONSTRAINT FK_Wedstrijd_Speler FOREIGN KEY (spelerId) REFERENCES Tennis.Speler (id),
    CONSTRAINT CK_Wedstrijd_aantalGewonnenSet CHECK (aantalGewonnenSets BETWEEN 0 AND 3),
    CONSTRAINT CK_Wedstrijd_aantalVerlorenSet CHECK (aantalVerlorenSets BETWEEN 0 AND 3),
);

-- aanmaken van tabel Boete
CREATE TABLE Tennis.Boete
(
    id       int IDENTITY (1,1),
    spelerId int   NOT NULL,
    datum    date  NOT NULL,
    bedrag   money NOT NULL,
    CONSTRAINT PK_Boete PRIMARY KEY (id),
    CONSTRAINT FK_Boete_Speler FOREIGN KEY (spelerId) REFERENCES Tennis.Speler (id),
    CONSTRAINT CK_Boete_datum CHECK (datum >= CAST('1989-12-31' AS date)),
    CONSTRAINT CK_Boete_bedrag CHECK (bedrag > 0)
);

-- aanmaken tabel Bestuurslid
CREATE TABLE Tennis.Bestuurslid
(
    spelerId   int,
    beginDatum date,
    eindDatum  date,
    functie    char(20),
    CONSTRAINT PK_Bestuurslid PRIMARY KEY (spelerId, beginDatum),
    CONSTRAINT FK_Bestuurslid_Speler FOREIGN KEY (spelerId) REFERENCES Tennis.Speler (id),
    CONSTRAINT CK_Bestuurslid_beginDatum_eindDatum CHECK (beginDatum < eindDatum),
    CONSTRAINT CK_Bestuurslid_beginDatum CHECK (beginDatum >= CAST('1990-01-01' AS date))
);


INSERT INTO Tennis.Speler
VALUES (2, 'Elfring', 'Rudi', '1988-09-01', 'M', 2005, 'Steden', '43', '3575NH', 'Den Haag', '070-237893', '2411');
INSERT INTO Tennis.Speler
VALUES (6, 'Permentier', 'Raf', '1984-06-25', 'M', 2007, 'Hazensteinln', '80', '1234KK', 'Den Haag', '070-476537',
        '8467');
INSERT INTO Tennis.Speler
VALUES (7, 'Wijers', 'Geert-Jan', '1983-05-11', 'M', 2001, 'Erasmusweg', '39', '9758VB', 'Den Haag', '070-347689',
        NULL);
INSERT INTO Tennis.Speler
VALUES (8, 'Niewenburg', 'Bertha', '1982-07-08', 'V', 2000, 'Spoorlaan', '4', '6584WO', 'Rijswijk', '070-458458',
        '2983');
INSERT INTO Tennis.Speler
VALUES (27, 'Cools', 'Marjan', '1984-12-28', 'V', 2003, 'Liespad', '804', '8457DK', 'Zoetermeer', '079-234857', '2513');
INSERT INTO Tennis.Speler
VALUES (28, 'Cools', 'Carla', '1983-06-22', 'V', 2003, 'Oudegracht', '10', '1294QK', 'Leiden', '010-659599', NULL);
INSERT INTO Tennis.Speler
VALUES (39, 'Bischoff', 'Danny', '1986-10-29', 'M', 2000, 'Ericaplein', '78', '9629CD', 'Den Haag', '070-393435', NULL);
INSERT INTO Tennis.Speler
VALUES (44, 'Bakker, de', 'Eric', '1983-01-09', 'M', 2000, 'Lawaaistraat', '23', '4444LJ', 'Rijswijk', '070-368753',
        '1124');
INSERT INTO Tennis.Speler
VALUES (57, 'Bohemen, van', 'Marc', '1991-08-17', 'M', 2005, 'Erasmusweg', '16', '4377CB', 'Den Haag', '070-473458',
        '6409');
INSERT INTO Tennis.Speler
VALUES (83, 'Hofland', 'Pieter', '1976-11-11', 'M', 2002, 'Mariakade', '16a', '1812UP', 'Den Haag', '070-353548',
        '1608');
INSERT INTO Tennis.Speler
VALUES (95, 'Meuleman', 'Peter', '1983-05-14', 'M', 1992, 'Hoofdweg', '33a', '5746OP', 'Voorburg', '070-867564', NULL);
INSERT INTO Tennis.Speler
VALUES (100, 'Permentier', 'Patrick', '1983-02-28', 'M', 1999, 'Hazensteinln', '80', '6494SG', 'Den Haag', '070-494593',
        '6524');
INSERT INTO Tennis.Speler
VALUES (104, 'Moerman', N'Daniëlla', '1990-05-10', 'V', 2004, 'Stoutlaan', '65', '9437AO', 'Zoetermeer', '079-987571',
        '7060');
INSERT INTO Tennis.Speler
VALUES (112, 'Baalen, van', 'Ingrid', '1983-10-01', 'V', 2004, 'Vosseweg', '8', '6392LK', 'Rotterdam', '010-548745',
        '1319');
INSERT INTO Tennis.Speler
VALUES (113, 'Van_Den_Berg', 'Lydia', '1997-10-01', 'V', 2004, 'Vosseweg', '8', '1012AB', 'Amsterdam', '018-548745',
        NULL);

INSERT INTO Tennis.Team
    (spelerId, divisie)
VALUES (6, 'ere');
INSERT INTO Tennis.Team
    (spelerId, divisie)
VALUES (27, 'tweede');

INSERT INTO Tennis.Wedstrijd
    (teamId, spelerId, aantalGewonnenSets, aantalVerlorenSets)
VALUES (1, 6, 3, 1);
INSERT INTO Tennis.Wedstrijd
    (teamId, spelerId, aantalGewonnenSets, aantalVerlorenSets)
VALUES (1, 6, 2, 3);
INSERT INTO Tennis.Wedstrijd
    (teamId, spelerId, aantalGewonnenSets, aantalVerlorenSets)
VALUES (1, 6, 3, 0);
INSERT INTO Tennis.Wedstrijd
    (teamId, spelerId, aantalGewonnenSets, aantalVerlorenSets)
VALUES (1, 44, 3, 2);
INSERT INTO Tennis.Wedstrijd
    (teamId, spelerId, aantalGewonnenSets, aantalVerlorenSets)
VALUES (1, 83, 0, 3);
INSERT INTO Tennis.Wedstrijd
    (teamId, spelerId, aantalGewonnenSets, aantalVerlorenSets)
VALUES (1, 2, 1, 3);
INSERT INTO Tennis.Wedstrijd
    (teamId, spelerId, aantalGewonnenSets, aantalVerlorenSets)
VALUES (1, 57, 3, 0);
INSERT INTO Tennis.Wedstrijd
    (teamId, spelerId, aantalGewonnenSets, aantalVerlorenSets)
VALUES (1, 8, 0, 3);
INSERT INTO Tennis.Wedstrijd
    (teamId, spelerId, aantalGewonnenSets, aantalVerlorenSets)
VALUES (2, 27, 3, 2);
INSERT INTO Tennis.Wedstrijd
    (teamId, spelerId, aantalGewonnenSets, aantalVerlorenSets)
VALUES (2, 104, 3, 2);
INSERT INTO Tennis.Wedstrijd
    (teamId, spelerId, aantalGewonnenSets, aantalVerlorenSets)
VALUES (2, 112, 2, 3);
INSERT INTO Tennis.Wedstrijd
    (teamId, spelerId, aantalGewonnenSets, aantalVerlorenSets)
VALUES (2, 112, 1, 3);
INSERT INTO Tennis.Wedstrijd
    (teamId, spelerId, aantalGewonnenSets, aantalVerlorenSets)
VALUES (2, 8, 0, 3);

INSERT INTO Tennis.Boete
    (spelerId, datum, bedrag)
VALUES (6, '2000-12-08', 100.1234);
INSERT INTO Tennis.Boete
    (spelerId, datum, bedrag)
VALUES (44, '2001-05-05', 75.5678);
INSERT INTO Tennis.Boete
    (spelerId, datum, bedrag)
VALUES (27, '2003-09-10', 100.7890);
INSERT INTO Tennis.Boete
    (spelerId, datum, bedrag)
VALUES (104, '2004-12-08', 50.2345);
INSERT INTO Tennis.Boete
    (spelerId, datum, bedrag)
VALUES (44, '2000-12-08', 25.5487);
INSERT INTO Tennis.Boete
    (spelerId, datum, bedrag)
VALUES (8, '2000-12-08', 25.0045);
INSERT INTO Tennis.Boete
    (spelerId, datum, bedrag)
VALUES (44, '2002-12-30', 30.0078);
INSERT INTO Tennis.Boete
    (spelerId, datum, bedrag)
VALUES (27, '2004-11-12', 75.0457);

INSERT INTO Tennis.Bestuurslid
VALUES (6, '1990-1-1', '1990-12-31', 'Secretaris');
INSERT INTO Tennis.Bestuurslid
VALUES (6, '1991-1-1', '1992-12-31', 'Lid');
INSERT INTO Tennis.Bestuurslid
VALUES (6, '1992-1-1', '1993-12-31', 'Penningmeester');
INSERT INTO Tennis.Bestuurslid
VALUES (6, '1993-1-1', NULL, 'Voorzitter');
INSERT INTO Tennis.Bestuurslid
VALUES (2, '1990-1-1', '1992-12-31', 'Voorzitter');
INSERT INTO Tennis.Bestuurslid
VALUES (2, '1994-1-1', NULL, 'Lid');
INSERT INTO Tennis.Bestuurslid
VALUES (112, '1992-1-1', '1992-12-31', 'Lid');
INSERT INTO Tennis.Bestuurslid
VALUES (112, '1994-1-1', NULL, 'Secretaris');
INSERT INTO Tennis.Bestuurslid
VALUES (8, '1990-1-1', '1990-12-31', 'Penningmeester');
INSERT INTO Tennis.Bestuurslid
VALUES (8, '1991-1-1', '1991-12-31', 'Secretaris');
INSERT INTO Tennis.Bestuurslid
VALUES (8, '1993-1-1', '1993-12-31', 'Lid');
INSERT INTO Tennis.Bestuurslid
VALUES (8, '1994-1-1', NULL, 'Lid');
INSERT INTO Tennis.Bestuurslid
VALUES (57, '1992-1-1', '1992-12-31', 'Secretaris');
INSERT INTO Tennis.Bestuurslid
VALUES (27, '1990-1-1', '1990-12-31', 'Lid');
INSERT INTO Tennis.Bestuurslid
VALUES (27, '1991-1-1', '1991-12-31', 'Penningmeester');
INSERT INTO Tennis.Bestuurslid
VALUES (27, '1993-1-1', '1993-12-31', 'Penningmeester');
INSERT INTO Tennis.Bestuurslid
VALUES (95, '1994-1-1', NULL, 'Penningmeester');
