-- In juiste volgorde droppen
DROP TABLE IF EXISTS petanque.Eindronde;
DROP TABLE IF EXISTS petanque.Match;
DROP TABLE IF EXISTS petanque.CompetitieDeelname;
DROP TABLE IF EXISTS petanque.TeamSpeler;
DROP TABLE IF EXISTS petanque.Terrein;
DROP TABLE IF EXISTS petanque.Speler;
DROP TABLE IF EXISTS petanque.Competitie;
DROP TABLE IF EXISTS petanque.Afdeling;
DROP TABLE IF EXISTS petanque.ClubTeam;
DROP TABLE IF EXISTS petanque.Club;

-- Schema verwijderen
DROP SCHEMA IF EXISTS petanque;
GO



---------------------------------------------------------------------------


-- create schema: 
CREATE schema petanque;
GO

-- create CLUB tabel
CREATE table petanque.Club (
    id                  int             identity(1,1),
    provincie           nvarchar(50)    not null,
    naam                nvarchar(100)   not null,
    adres               nvarchar(50)    not null,
    huisnummer          nvarchar(10)    not null,
    postcode            nvarchar(10)    not null,
    gemeente            nvarchar(50)    not null,
    aantalTerreinen     int             not null,
    gebouwGoedgekeurd   bit             not null    default (0),
    tshirtVerplicht     bit             not null    default(0),
    licentieNummer      nvarchar(50)    null,
    oprichtingsDatum    date            not null    default(getdate()),     

    CONSTRAINT PK_Club  PRIMARY KEY (id),

    -- checken op het aantal terreinen
    CONSTRAINT CK_aantalTerreinen  
        CHECK (aantalTerreinen in(3,6,9,12)),

    -- enkel een licentienummer als het gebouw goedgekeurd
    CONSTRAINT CK_licentieNummer 
        CHECK (gebouwGoedgekeurd = 0 OR (gebouwGoedgekeurd = 1 AND licentieNummer IS NOT NULL)),

    -- provincie enum checken
    CONSTRAINT CK_Club_Provincie 
        CHECK (provincie IN (
            'Oost Vlaanderen',
            'West Vlaanderen',
            'Limburg',
            'Vlaams Brabant',
            'Antwerpen'
        )),

    -- clubnaam moet uniek zijn
    CONSTRAINT UQ_Naam UNIQUE (naam)
);

-- Gefilterde unieke index voor licentienummer
CREATE UNIQUE NONCLUSTERED INDEX UIX_Club_licentieNummer 
ON petanque.Club (licentieNummer) 
WHERE licentieNummer IS NOT NULL;

--create clubteam tabel
CREATE TABLE petanque.ClubTeam (
    ploegId       int           IDENTITY(1,1),
    ClubId        int           NOT NULL,
    naam          nvarchar(100) NOT NULL,
    aantalSpelers int           NOT NULL,
    actief        bit           NOT NULL,

    CONSTRAINT PK_ClubTeam PRIMARY KEY (ploegId),

    -- R1 - 1 club kan meerdere teams hebben
    CONSTRAINT FK_ClubTeam_Club
        FOREIGN KEY (ClubId)
        REFERENCES petanque.Club(id),

    -- teamnaam moet uniek zijn
    CONSTRAINT UQ_ClubTeam_naam UNIQUE (naam),

    -- aantalSpelers moet tussen 9 en 12 zijn
    CONSTRAINT CK_ClubTeam_aantalSpelers
        CHECK (aantalSpelers BETWEEN 9 AND 12)
);

--create afdeling tabel
CREATE TABLE petanque.Afdeling (
    id          int           IDENTITY(1,1),
    ReeksNiveau nvarchar(50)  NOT NULL,
    Provincie   nvarchar(50)  NOT NULL,
    niveauType  nvarchar(50)  NOT NULL,

    CONSTRAINT PK_Afdeling PRIMARY KEY (id),

    -- ReeksNiveau enum checken
    CONSTRAINT CK_Afdeling_ReeksNiveau
        CHECK (ReeksNiveau IN (
            'Nationaal 1',
            'Nationaal 2',
            'Federaal 1',
            'Federaal 2',
            'Ere',
            'Provinciaal 1',
            'Provinciaal 2',
            'Provinciaal 3',
            'Provinciaal 4'
        )),

    -- Provincie enum checken
    CONSTRAINT CK_Afdeling_Provincie
        CHECK (Provincie IN (
            'Vlaams Brabant',
            'Antwerpen',
            'Oost-Vlaanderen',
            'West-Vlaanderen',
            'Limburg'
        )),

    -- niveauType enum checken
    CONSTRAINT CK_Afdeling_niveauType
        CHECK (niveauType IN (
            'Provinciaal',
            'Federaal',
            'Nationaal'))
);

-- create competitie tabel
CREATE TABLE petanque.Competitie (
    id             int          IDENTITY(1,1),
    AfdelingId     int          NOT NULL,
    Seizoen        varchar(9)   NOT NULL,
    startUur       time         NOT NULL DEFAULT ('14:00'),
    aantalSpeeldagen int        NULL,

    CONSTRAINT PK_Competitie PRIMARY KEY (id),

    -- R6 - 1 Afdeling kan meerdere Competities hebben
    CONSTRAINT FK_Competitie_Afdeling
        FOREIGN KEY (AfdelingId)
        REFERENCES petanque.Afdeling(id)
);

-- create speler tabel
CREATE TABLE petanque.Speler (
    id            int           IDENTITY(1,1),
    ClubId        int           NOT NULL,
    naam          nvarchar(100) NOT NULL,
    voornaam      nvarchar(100) NOT NULL,
    geboorteDatum date          NULL,
    licentieNummer varchar(50)  NOT NULL,

    CONSTRAINT PK_Speler PRIMARY KEY (id),

    -- R3 - elke speler is aangesloten bij precies 1 club
    CONSTRAINT FK_Speler_Club
        FOREIGN KEY (ClubId)
        REFERENCES petanque.Club(id),

    -- combinatie naam + voornaam moet uniek zijn
    CONSTRAINT UQ_Speler_naam_voornaam
        UNIQUE (naam, voornaam),

    -- licentieNummer moet uniek zijn (AK in je ERD)
    CONSTRAINT UQ_Speler_licentieNummer
        UNIQUE (licentieNummer)
);

-- create terrein tabel
CREATE TABLE petanque.Terrein (
    id         int          IDENTITY(1,1),
    ClubId     int          NOT NULL,
    nummer     int          NOT NULL,
    lengte_cm   decimal(7,0) NOT NULL,
    breedte_cm  decimal(7,0) NOT NULL,

    CONSTRAINT PK_Terrein PRIMARY KEY (id),

    -- R2 - 1 club kan meerdere terreinen hebben (cascade delete)
    CONSTRAINT FK_Terrein_Club
        FOREIGN KEY (ClubId)
        REFERENCES petanque.Club(id)
        ON DELETE CASCADE
        ON UPDATE NO ACTION,

    -- lengte_m moet >= 10
    CONSTRAINT CK_Terrein_lengte
        CHECK (lengte_cm >= 1000),

    -- breedte_m moet >= 2
    CONSTRAINT CK_Terrein_breedte
        CHECK (breedte_cm >= 200)
);

-- create teamSpeler tabel
CREATE TABLE petanque.TeamSpeler (
    id         int  IDENTITY(1,1),
    PloegId    int  NOT NULL,
    SpelerId   int  NOT NULL,
    vanafDatum date NOT NULL,
    totDatum   date NULL,

    CONSTRAINT PK_TeamSpeler PRIMARY KEY (id),

    -- R4 - 1 team kan meerdere spelers hebben (cascade delete)
    CONSTRAINT FK_TeamSpeler_ClubTeam
        FOREIGN KEY (PloegId)
        REFERENCES petanque.ClubTeam(ploegId)
        ON DELETE CASCADE
        ON UPDATE NO ACTION,

    -- R5 - 1 speler kan in meerdere teams spelen (over de tijd)
    CONSTRAINT FK_TeamSpeler_Speler
        FOREIGN KEY (SpelerId)
        REFERENCES petanque.Speler(id)
        ON DELETE CASCADE
        ON UPDATE NO ACTION
);

-- create CompetitieDeelname tabel
CREATE TABLE petanque.CompetitieDeelname (
    id           int IDENTITY(1,1),
    CompetitieId int NOT NULL,
    ClubId       int NOT NULL,
    PloegId      int NOT NULL,
    punten       int NOT NULL DEFAULT (0),
    isKampioen   bit NULL,
    isDegradant  bit NULL,

    CONSTRAINT PK_CompetitieDeelname PRIMARY KEY (id),


    -- R7 - Elke Competitie heeft meerdere deelnemende ploegen (cascade delete)
    CONSTRAINT FK_CompetitieDeelname_Competitie
        FOREIGN KEY (CompetitieId)
        REFERENCES petanque.Competitie(id)
        ON DELETE CASCADE
        ON UPDATE NO ACTION,

    -- R8 - Een ClubTeam kan in meerdere competities/seizoenen deelnemen in de tijd
    CONSTRAINT FK_CompetitieDeelname_ClubTeam
        FOREIGN KEY (PloegId)
        REFERENCES petanque.ClubTeam(ploegId),

    -- R9 -	Een club kan met 2 ploegen deelnemen per competitie 
    CONSTRAINT FK_CompetitieDeelname_Club
        FOREIGN KEY (ClubId)
        REFERENCES petanque.Club(id),

    -- 0..2 regel kun je niet perfect in SQL afdwingen;
    -- deze UNIQUE voorkomt wel dubbele inschrijvingen per ploeg in 1 competitie
    CONSTRAINT UQ_CompetitieDeelname_Competitie_Ploeg
        UNIQUE (CompetitieId, PloegId)
);

-- create Match tabel
CREATE TABLE petanque.Match (
    id            int          IDENTITY(1,1),
    CompetitieId  int          NOT NULL,
    thuisPloegId  int          NOT NULL,
    uitPloegId    int          NOT NULL,
    speeldag      int          NOT NULL,
    datum         date         NOT NULL,
    startUur      time         NOT NULL DEFAULT ('14:00'),
    puntenThuis   int          NULL,
    puntenUit     int          NULL,

    CONSTRAINT PK_Match PRIMARY KEY (id),


    -- R10 - Elke Match hoort bij precies één Competitie (cascade delete)
    CONSTRAINT FK_Match_Competitie
        FOREIGN KEY (CompetitieId)
        REFERENCES petanque.Competitie(id)
        ON DELETE CASCADE
        ON UPDATE NO ACTION,


    -- R11 - thuisploeg is een ClubTeam
    CONSTRAINT FK_Match_ThuisPloeg
        FOREIGN KEY (thuisPloegId)
        REFERENCES petanque.ClubTeam(ploegId),


    -- R12 - uitploeg is een ClubTeam
    CONSTRAINT FK_Match_UitPloeg
        FOREIGN KEY (uitPloegId)
        REFERENCES petanque.ClubTeam(ploegId),


    -- puntenThuis + puntenUit moeten samen 9 zijn
    CONSTRAINT CK_Match_puntenSom
        CHECK (
            puntenThuis >= 0
            AND puntenUit >= 0
            AND puntenThuis + puntenUit = 9
        )
);

-- create Eindronde tabel
CREATE TABLE petanque.Eindronde (
    id             int          IDENTITY(1,1),
    ReeksNiveau    nvarchar(50) NOT NULL,
    Provincie      nvarchar(50) NOT NULL,
    winnaarPloegId int          NOT NULL,
    Seizoen        varchar(9)   NOT NULL,

    CONSTRAINT PK_Eindronde PRIMARY KEY (id),


    -- R13 - Elke Eindronde heeft precies één winnaar; daarom moet Eindronde.winnaarPloegID altijd ingevuld zijn en verwijst het naar één bestaand ClubTeam
    CONSTRAINT FK_Eindronde_ClubTeam
        FOREIGN KEY (winnaarPloegId)
        REFERENCES petanque.ClubTeam(ploegId),

    -- ReeksNiveau enum checken, enkel 'Ere' toegestaan
    CONSTRAINT CK_Eindronde_ReeksNiveau
        CHECK (ReeksNiveau = 'Ere'),

    -- Provincie enum checken (zelfde als bij Club/Afdeling)
    CONSTRAINT CK_Eindronde_Provincie
        CHECK (Provincie IN (
            'Vlaams Brabant',
            'Antwerpen',
            'Oost-Vlaanderen',
            'West-Vlaanderen',
            'Limburg'
        ))
);


----------------------------------------------------------------------------------------

-- Club data - in mijn voorbeeld de ere competitie van vlaamsbrabant en 2 bijkomende clubs die geen licentie hebben gekregen
INSERT INTO petanque.Club (provincie, naam, adres, huisnummer, postcode, gemeente, aantalTerreinen, gebouwGoedgekeurd, tshirtVerplicht, licentieNummer, oprichtingsDatum) VALUES
-- Alle 8 Vlaams Brabant clubs MET licentie (gebouw goedgekeurd)
('Vlaams Brabant', 'Esseghem', 'Rue Jules Lahaye', '304', '1090', 'Jette', 9, 1, 1, 'c1234567', '2001-06-28'),
('Vlaams Brabant', 'Beersel', 'Jozef Huysmanslaan', '5', '1650', 'Beersel', 6, 1, 1, 'c2345678', '2000-01-01'),
('Vlaams Brabant', 'Dilbeek', 'D''arconatiestraat', '3', '1700', 'Dilbeek', 9, 1, 1, 'c3456789', '1990-01-01'),
('Vlaams Brabant', 'Kerkom', 'Schoolstraat', '15', '3370', 'Boutersem', 6, 1, 1, 'c4567890', '1985-01-01'),
('Vlaams Brabant', 'De Blockskes', 'Processiebaan', '5', '1785', 'Merchtem', 12, 1, 1, 'c5678901', '1998-10-01'),
('Vlaams Brabant', 'Singel', 'Grimbergsesteenweg', '99A', '1850', 'Grimbergen', 9, 1, 1, 'c6789012', '1987-01-01'),
('Vlaams Brabant', 'Wemmel', 'Steenweg op Brussel', '113', '1780', 'Wemmel', 9, 1, 1, 'c7890123', '1992-01-01'),
('Vlaams Brabant', 'Rode', 'Kwadeplasstraat', '32A', '1640', 'Sint-Genesius-Rode', 6, 1, 1, 'c8901234', '1989-01-25'),

-- 2 niet-Vlaams Brabant clubs ZONDER licentie
('Antwerpen', 'Lint', 'Kontichsesteenweg', '83', '2547', 'Lint', 6, 0, 0, NULL, '2015-01-01'),
('Oost Vlaanderen', 'Schorpioen', 'Botestraat', '98A', '9032', 'Wondelgem', 9, 0, 0, NULL, '1975-01-01');

--club team
INSERT INTO petanque.ClubTeam (ClubId, naam, aantalSpelers, actief) VALUES
(1, 'Esseghem A', 12, 1),
(2, 'Beersel A', 12, 1),
(2, 'Beersel B', 12, 1),
(3, 'Dilbeek A', 12, 1),
(3, 'Dilbeek B', 12, 1),
(4, 'Kerkom A', 12, 1),
(5, 'De Blockskes A', 12, 1),
(6, 'Singel A', 11, 1),
(7, 'Wemmel A', 11, 1),
(8, 'Rode A', 12, 1),
(9, 'Lint A', 10, 0),     -- Niet actief (geen licentie)
(10, 'Schorpioen A', 11, 0); -- Niet actief (geen licentie)

-- Spelers ingeven
INSERT INTO petanque.Speler (ClubId, naam, voornaam, licentieNummer) VALUES
-- Esseghem A (ClubId = 1)
(1, 'VAN ZEEBROEK', 'Patrick', '001075'),
(1, 'VAN DAMME', 'Remy', '005363'),
(1, 'RODRIGUES', 'David', '007804'),
(1, 'LAMS', 'Heidi', '010350'),
(1, 'VAN BUGGENHOUT', 'David', '013051'),
(1, 'D''HAEN', 'Rudy', '015633'),
(1, 'GILLES', 'Gregory', '016730'),
(1, 'DE MAN', 'Nicolas', '016736'),
(1, 'GUCHEZ', 'Guy', '016737'),
(1, 'DE BOODT', 'Michael', '016742'),
(1, 'HOEBEECK', 'Alain', '016745'),
(1, 'MARLIER', 'Vincent', '018841'),

-- Beersel A (ClubId = 2)
(2, 'DE LEEUW', 'Geert', '002502'),
(2, 'VAN ROY', 'David', '007552'),
(2, 'DE CLERCK', 'Fabrice', '007553'),
(2, 'NEUTS', 'Leana', '023275'),
(2, 'VAN WAELEM', 'laurent', '023786'),
(2, 'UYTTENDAELE', 'DANIEL', '02384'),
(2, 'VANDERVELDE', 'Walter', '024761'),
(2, 'DE KETELAERE', 'JEAN-PIERRE', '024763'),
(2, 'AERTS', 'RUDI', '024764'),
(2, 'URIA MARTINEZ', 'Jordan', '025274'),
(2, 'URIA MARTINEZ', 'Johnathan', '025275'),
(2, 'NEUTS', 'Jeremy', '026154'),

-- Beersel B (ClubId = 2)
(2, 'VLEMINCKX', 'Thierry', '016733'),
(2, 'HAMELRIJK', 'Serge', '023031'),
(2, 'HAMELRIJK', 'Philippe', '023033'),
(2, 'GYSENS', 'MARC', '023837'),
(2, 'HAMELINCKX', 'JURGEN', '023839'),
(2, 'SAKALIS', 'ALEXIS', '023879'),
(2, 'WAEGEMANS', 'PAUL', '024152'),
(2, 'DETIENNE', 'Patrice', '024183'),
(2, 'PAUWELS', 'GREGORY', '024222'),
(2, 'LEYSSENS', 'JOHNNY', '024229'),
(2, 'EVENEPOEL', 'BART', '024349'),
(2, 'HANSSENS', 'Tibby', '024868'),

-- Dilbeek A (ClubId = 3)
(3, 'MEYNAERT', 'Alain', '003623'),
(3, 'GYSELINCK', 'Daniel', '006833'),
(3, 'VAN DE PUTTE', 'Raphaël', '007765'),
(3, 'VAN DER NIEPEN', 'Olivia', '010174'),
(3, 'MEYNAERT', 'Vanessa', '014506'),
(3, 'SIFFAIN', 'Alain', '017786'),
(3, 'OUAHBI', 'Malik', '020706'),
(3, 'LADEMACHER', 'Christophe', '021015'),
(3, 'DESSEIN', 'Yves', '021592'),
(3, 'VEREECKE', 'Ronny', '021650'),
(3, 'DE SAMBLANX', 'Steve', '021714'),
(3, 'LAUWERS', 'Milan', '021983'),

-- Dilbeek B (ClubId = 3)
(3, 'BELSACQ', 'Johan', '009835'),
(3, 'TRATSAERT', 'Ilse', '010824'),
(3, 'ALLONCIUS', 'Luc', '014635'),
(3, 'LALLEMAND', 'Marcelle', '016912'),
(3, 'DE KLERK', 'Patrick', '021589'),
(3, 'RAMPELBERGH', 'Francis', '022971'),
(3, 'WOUTERS', 'Ivo', '023827'),
(3, 'DEKENS', 'Nancy', '026009'),
(3, 'BERLANGER', 'Johan', '026010'),
(3, 'VANLAER', 'Corine', '026677'),
(3, 'SERVAES', 'Marc', '026678'),
(3, 'DE RONNE', 'Patrick', '028147'),

-- Kerkom A (ClubId = 4)
(4, 'TRAP', 'Jonas', '001388'),
(4, 'MERTENS', 'Corneel', '007189'),
(4, 'DEPUTTER', 'Robin', '009865'),
(4, 'VAN GOIDSENHOVEN', 'Gijs', '013432'),
(4, 'GILIS', 'Jens', '013437'),
(4, 'HOOYLAERTS', 'Kevin', '014074'),
(4, 'HOOYLAERTS', 'Erwin', '014140'),
(4, 'SPREUTELS', 'Michaël', '017156'),
(4, 'PITTOMVILS', 'Tom', '017914'),
(4, 'NEVE', 'Emily', '021680'),
(4, 'BERTELS', 'Erik', '028633'),
(4, 'FARKAS', 'Jozsef', '028634'),

-- De Blockskes A (ClubId = 5)
(5, 'BORRÉ', 'Reinold', '000001'),
(5, 'VAN HECK', 'Miranda', '001542'),
(5, 'VAN GYSEGEM', 'Stefan', '002576'),
(5, 'CHRÉTIEN', 'Frédéric', '003981'),
(5, 'DEDOBBELAERE', 'Christine', '007534'),
(5, 'VAN WALLE', 'Dany', '007764'),
(5, 'LEROY', 'Dirk', '007766'),
(5, 'COLMAN', 'Wesley', '013026'),
(5, 'BUYS', 'Dirk', '018142'),
(5, 'VERNAEVE', 'Lucas', '018153'),
(5, 'VAN GYSEGEM', 'JOERI', '023626'),
(5, 'JACOBS', 'Jan', '024323'),

-- Singel A (ClubId = 6)
(6, 'VAN MALDER', 'Sam', '003476'),
(6, 'PÉ', 'Jim', '008996'),
(6, 'LAURENT', 'Sébastien', '011626'),
(6, 'DE CRéE', 'Jordi', '015037'),
(6, 'CNUDDE', 'Remi', '016215'),
(6, 'FERRé', 'Samuel', '018745'),
(6, 'GALLEMAERS', 'Dylan', '023315'),
(6, 'TORDEUR', 'Jérôme', '023805'),
(6, 'ORLANDO', 'Filippo', '026550'),
(6, 'TABERY', 'Hugues', '026982'),
(6, 'CALUWAERTS', 'Stéphane', '027369'),

-- Wemmel A (ClubId = 7)
(7, 'BOTELHO TEIXEIRA', 'José', '014030'),
(7, 'SIBILLE', 'Maxime', '015240'),
(7, 'PRESUTTI', 'Alessio', '015978'),
(7, 'SCHOT', 'Patrick', '021627'),
(7, 'LALOI', 'Frédéric', '022447'),
(7, 'CORREIA PINTO', 'Jimmy', '024342'),
(7, 'DAMIEN', 'Bertrand', '026826'),
(7, 'REYNAERT', 'Frédéric', '026828'),
(7, 'MESKENS', 'Thierry', '026829'),
(7, 'COLON', 'Marc', '027273'),
(7, 'ROZE', 'Steven', '027977'),

-- Rode A (ClubId = 8)
(8, 'BENIJTS', 'Raymond', '017694'),
(8, 'VERHEVEN', 'Olivier', '021050'),
(8, 'VOLDERS', 'Sebastien', '024491'),
(8, 'WEEMAELS', 'Marc', '025131'),
(8, 'BENIJTS', 'Michaël', '025144'),
(8, 'SLACHMUYLDERS', 'Pascal', '025226'),
(8, 'DE PAUW', 'Adrien', '025240'),
(8, 'BOON', 'Philippe', '025241'),
(8, 'BEUGNIES', 'Olivier', '025725'),
(8, 'MARZANO', 'Margaux', '026391'),
(8, 'SLUYS', 'Stephane', '026937'),
(8, 'MARZANO', 'Jean', '027790');

INSERT INTO petanque.TeamSpeler (PloegId, SpelerId, vanafDatum, totDatum) VALUES
-- Esseghem A (PloegId = 1, SpelerId 1-12)
(1, 1, '2023-07-12', NULL),
(1, 2, '2023-02-26', NULL),
(1, 3, '2025-02-28', NULL),
(1, 4, '2024-01-19', NULL),
(1, 5, '2023-05-17', NULL),
(1, 6, '2022-11-18', NULL),
(1, 7, '2021-10-21', NULL),
(1, 8, '2022-09-10', NULL),
(1, 9, '2024-12-15', NULL),
(1, 10, '2023-05-25', NULL),
(1, 11, '2025-11-10', NULL),
(1, 12, '2024-10-05', NULL),

-- Beersel A (PloegId = 2, SpelerId 13-24) 
(2, 13, '2022-04-29', NULL),
(2, 14, '2023-06-13', NULL),
(2, 15, '2025-01-04', NULL),
(2, 16, '2023-10-13', NULL),
(2, 17, '2020-12-31', NULL),
(2, 18, '2021-01-21', NULL),
(2, 19, '2021-03-14', NULL),
(2, 20, '2023-11-04', NULL),
(2, 21, '2025-10-05', NULL),
(2, 22, '2024-02-22', NULL),
(2, 23, '2024-12-09', NULL),
(2, 24, '2023-01-04', NULL),

-- Beersel B (PloegId = 3, SpelerId 25-36)
(3, 25, '2023-02-24', NULL),
(3, 26, '2024-12-18', NULL),
(3, 27, '2025-02-10', NULL),
(3, 28, '2021-11-22', NULL),
(3, 29, '2021-05-08', NULL),
(3, 30, '2023-01-20', NULL),
(3, 31, '2023-03-12', NULL),
(3, 32, '2025-03-02', NULL),
(3, 33, '2022-06-16', NULL),
(3, 34, '2022-11-21', NULL),
(3, 35, '2023-05-03', NULL),
(3, 36, '2025-04-22', NULL),

-- Dilbeek A (PloegId = 4, SpelerId 37-48)
(4, 37, '2022-03-31', NULL),
(4, 38, '2023-09-29', NULL),
(4, 39, '2025-09-04', NULL),
(4, 40, '2022-05-29', NULL),
(4, 41, '2025-04-30', NULL),
(4, 42, '2022-01-26', NULL),
(4, 43, '2022-04-23', NULL),
(4, 44, '2022-06-24', NULL),
(4, 45, '2021-01-14', NULL),
(4, 46, '2024-07-20', NULL),
(4, 47, '2022-07-22', NULL),
(4, 48, '2022-10-23', NULL),

-- Dilbeek B (PloegId = 5, SpelerId 49-60)
(5, 49, '2021-07-21', NULL),
(5, 50, '2022-08-13', NULL),
(5, 51, '2021-05-28', NULL),
(5, 52, '2025-02-08', NULL),
(5, 53, '2024-07-20', NULL),
(5, 54, '2023-12-25', NULL),
(5, 55, '2024-10-29', NULL),
(5, 56, '2025-08-04', NULL),
(5, 57, '2022-10-26', NULL),
(5, 58, '2025-02-25', NULL),
(5, 59, '2022-11-25', NULL),
(5, 60, '2021-12-14', NULL),

-- Kerkom A (PloegId = 6, SpelerId 61-72)
(6, 61, '2025-07-04', NULL),
(6, 62, '2023-04-11', NULL),
(6, 63, '2023-02-13', NULL),
(6, 64, '2023-05-03', NULL),
(6, 65, '2024-11-26', NULL),
(6, 66, '2022-03-17', NULL),
(6, 67, '2023-04-08', NULL),
(6, 68, '2021-07-08', NULL),
(6, 69, '2022-06-14', NULL),
(6, 70, '2024-04-14', NULL),
(6, 71, '2021-06-19', NULL),
(6, 72, '2023-12-10', NULL),

-- De Blockskes A (PloegId = 7, SpelerId 73-84)
(7, 73, '2025-01-31', NULL),
(7, 74, '2021-09-21', NULL),
(7, 75, '2022-11-10', NULL),
(7, 76, '2023-05-05', NULL),
(7, 77, '2021-07-18', NULL),
(7, 78, '2021-10-05', NULL),
(7, 79, '2021-07-14', NULL),
(7, 80, '2021-10-09', NULL),
(7, 81, '2023-04-25', NULL),
(7, 82, '2023-06-16', NULL),
(7, 83, '2023-07-31', NULL),
(7, 84, '2024-02-08', NULL),

-- Singel A (PloegId = 8, SpelerId 85-95)
(8, 85, '2022-02-14', NULL),
(8, 86, '2022-05-05', NULL),
(8, 87, '2023-05-19', NULL),
(8, 88, '2022-09-06', NULL),
(8, 89, '2025-11-08', NULL),
(8, 90, '2021-05-06', NULL),
(8, 91, '2022-04-29', NULL),
(8, 92, '2022-12-18', NULL),
(8, 93, '2021-03-19', NULL),
(8, 94, '2021-04-17', NULL),
(8, 95, '2024-02-03', NULL),

-- Wemmel A (PloegId = 9, SpelerId 96-106)
(9, 96, '2023-03-01', NULL),
(9, 97, '2025-12-22', NULL),
(9, 98, '2022-12-17', NULL),
(9, 99, '2023-03-11', NULL),
(9, 100, '2024-03-08', NULL),
(9, 101, '2022-11-13', NULL),
(9, 102, '2025-10-24', NULL),
(9, 103, '2024-12-03', NULL),
(9, 104, '2023-11-11', NULL),
(9, 105, '2021-10-12', NULL),
(9, 106, '2022-12-23', NULL),

-- Rode A (PloegId = 10, SpelerId 107-118)
(10, 107, '2021-10-08', NULL),
(10, 108, '2024-05-12', NULL),
(10, 109, '2023-12-22', NULL),
(10, 110, '2025-02-02', NULL),
(10, 111, '2022-05-17', NULL),
(10, 112, '2025-10-10', NULL),
(10, 113, '2022-04-14', NULL),
(10, 114, '2022-02-25', NULL),
(10, 115, '2025-05-01', NULL),
(10, 116, '2022-08-01', NULL),
(10, 117, '2021-06-01', NULL),
(10, 118, '2022-01-19', NULL);

INSERT INTO petanque.Terrein (ClubId, nummer, lengte_cm, breedte_cm) VALUES
-- Esseghem (ClubId 1, 9 terreinen) - 11.29m x 2.08m
(1, 1, 1129, 208),
(1, 2, 1129, 208),
(1, 3, 1129, 208),
(1, 4, 1129, 208),
(1, 5, 1129, 208),
(1, 6, 1129, 208),
(1, 7, 1129, 208),
(1, 8, 1129, 208),
(1, 9, 1129, 208),

-- Beersel (ClubId 2, 6 terreinen) - 10.32m x 3.65m
(2, 1, 1032, 365),
(2, 2, 1032, 365),
(2, 3, 1032, 365),
(2, 4, 1032, 365),
(2, 5, 1032, 365),
(2, 6, 1032, 365),

-- Dilbeek (ClubId 3, 9 terreinen) - 11.21m x 3.53m
(3, 1, 1121, 353),
(3, 2, 1121, 353),
(3, 3, 1121, 353),
(3, 4, 1121, 353),
(3, 5, 1121, 353),
(3, 6, 1121, 353),
(3, 7, 1121, 353),
(3, 8, 1121, 353),
(3, 9, 1121, 353),

-- Kerkom (ClubId 4, 6 terreinen) - 12.60m x 4.00m
(4, 1, 1260, 400),
(4, 2, 1260, 400),
(4, 3, 1260, 400),
(4, 4, 1260, 400),
(4, 5, 1260, 400),
(4, 6, 1260, 400),

-- De Blockskes (ClubId 5, 12 terreinen) - 10.05m x 2.81m
(5, 1, 1005, 281),
(5, 2, 1005, 281),
(5, 3, 1005, 281),
(5, 4, 1005, 281),
(5, 5, 1005, 281),
(5, 6, 1005, 281),
(5, 7, 1005, 281),
(5, 8, 1005, 281),
(5, 9, 1005, 281),
(5, 10, 1005, 281),
(5, 11, 1005, 281),
(5, 12, 1005, 281),

-- Singel (ClubId 6, 9 terreinen) - 10.77m x 3.74m
(6, 1, 1077, 374),
(6, 2, 1077, 374),
(6, 3, 1077, 374),
(6, 4, 1077, 374),
(6, 5, 1077, 374),
(6, 6, 1077, 374),
(6, 7, 1077, 374),
(6, 8, 1077, 374),
(6, 9, 1077, 374),

-- Wemmel (ClubId 7, 9 terreinen) - 11.49m x 3.15m
(7, 1, 1149, 315),
(7, 2, 1149, 315),
(7, 3, 1149, 315),
(7, 4, 1149, 315),
(7, 5, 1149, 315),
(7, 6, 1149, 315),
(7, 7, 1149, 315),
(7, 8, 1149, 315),
(7, 9, 1149, 315),

-- Rode (ClubId 8, 6 terreinen) - 11.06m x 3.89m
(8, 1, 1106, 389),
(8, 2, 1106, 389),
(8, 3, 1106, 389),
(8, 4, 1106, 389),
(8, 5, 1106, 389),
(8, 6, 1106, 389),

-- Lint (ClubId 9, 6 terreinen) - 12.74m x 2.91m
(9, 1, 1274, 291),
(9, 2, 1274, 291),
(9, 3, 1274, 291),
(9, 4, 1274, 291),
(9, 5, 1274, 291),
(9, 6, 1274, 291),

-- Schorpioen (ClubId 10, 9 terreinen) - 11.99m x 2.67m
(10, 1, 1199, 267),
(10, 2, 1199, 267),
(10, 3, 1199, 267),
(10, 4, 1199, 267),
(10, 5, 1199, 267),
(10, 6, 1199, 267),
(10, 7, 1199, 267),
(10, 8, 1199, 267),
(10, 9, 1199, 267);

INSERT INTO petanque.Afdeling (ReeksNiveau, Provincie, niveauType) VALUES
-- Provinciale afdelingen (4 per provincie + 1 Ere per provincie)
('Ere', 'Vlaams Brabant', 'Provinciaal'),
('Provinciaal 1', 'Vlaams Brabant', 'Provinciaal'),
('Provinciaal 2', 'Vlaams Brabant', 'Provinciaal'),
('Provinciaal 3', 'Vlaams Brabant', 'Provinciaal'),
('Provinciaal 4', 'Vlaams Brabant', 'Provinciaal'),

('Ere', 'Antwerpen', 'Provinciaal'),
('Provinciaal 1', 'Antwerpen', 'Provinciaal'),
('Provinciaal 2', 'Antwerpen', 'Provinciaal'),
('Provinciaal 3', 'Antwerpen', 'Provinciaal'),
('Provinciaal 4', 'Antwerpen', 'Provinciaal'),

('Ere', 'Oost-Vlaanderen', 'Provinciaal'),
('Provinciaal 1', 'Oost-Vlaanderen', 'Provinciaal'),
('Provinciaal 2', 'Oost-Vlaanderen', 'Provinciaal'),
('Provinciaal 3', 'Oost-Vlaanderen', 'Provinciaal'),
('Provinciaal 4', 'Oost-Vlaanderen', 'Provinciaal'),

('Ere', 'West-Vlaanderen', 'Provinciaal'),
('Provinciaal 1', 'West-Vlaanderen', 'Provinciaal'),
('Provinciaal 2', 'West-Vlaanderen', 'Provinciaal'),
('Provinciaal 3', 'West-Vlaanderen', 'Provinciaal'),
('Provinciaal 4', 'West-Vlaanderen', 'Provinciaal'),

('Ere', 'Limburg', 'Provinciaal'),
('Provinciaal 1', 'Limburg', 'Provinciaal'),
('Provinciaal 2', 'Limburg', 'Provinciaal'),
('Provinciaal 3', 'Limburg', 'Provinciaal'),
('Provinciaal 4', 'Limburg', 'Provinciaal'),

-- Federaal niveau (landelijk)
('Federaal 1', 'Vlaams Brabant', 'Federaal'),
('Federaal 2', 'Vlaams Brabant', 'Federaal'),

-- Nationaal niveau (landelijk)
('Nationaal 1', 'Vlaams Brabant', 'Nationaal'),
('Nationaal 2', 'Vlaams Brabant', 'Nationaal');

INSERT INTO petanque.Competitie (AfdelingId, Seizoen, startUur, aantalSpeeldagen) VALUES
-- Provinciaal Ere per provincie
(1,  '2025-2026', '14:00', 9),  -- Vlaams Brabant Ere
(6,  '2025-2026', '14:00', 9),  -- Antwerpen Ere
(11, '2025-2026', '14:00', 9),  -- Oost-Vlaanderen Ere
(16, '2025-2026', '14:00', 9),  -- West-Vlaanderen Ere
(21, '2025-2026', '14:00', 9),  -- Limburg Ere

-- Federaal niveau (Federaal 1 en 2)
(26, '2025-2026', '14:00', 9),  -- Federaal 1
(27, '2025-2026', '14:00', 9),  -- Federaal 2

-- Nationaal niveau (Nationaal 1 en 2)
(28, '2025-2026', '14:00', 9),  -- Nationaal 1
(29, '2025-2026', '14:00', 9);  -- Nationaal 2

INSERT INTO petanque.Match
(CompetitieId, thuisPloegId, uitPloegId, speeldag, datum, startUur, puntenThuis, puntenUit)
VALUES
-- Speeldag 1 - 05/10/2025
(1, 1, 3, 1, '2025-10-05', '14:00', 4, 5),   -- ESSEGHEM A - BEERSEL B
(1, 4, 5, 1, '2025-10-05', '14:00', 6, 3),   -- DILBEEK A - DILBEEK B
(1, 6, 7, 1, '2025-10-05', '14:00', 7, 2),   -- KERKOM A - DE BLOCKSKES A
(1, 2, 8, 1, '2025-10-05', '14:00', 5, 4),   -- BEERSEL A - SINGEL A
(1, 9,10, 1, '2025-10-05', '14:00', 9, 0),   -- WEMMEL A - RODE A

-- Speeldag 2 - 12/10/2025
(1, 9, 1, 2, '2025-10-12', '14:00', 3, 6),   -- WEMMEL A - ESSEGHEM A
(1, 3, 2, 2, '2025-10-12', '14:00', 8, 1),   -- BEERSEL B - BEERSEL A
(1, 5, 7, 2, '2025-10-12', '14:00', 6, 3),   -- DILBEEK B - DE BLOCKSKES A
(1, 8, 6, 2, '2025-10-12', '14:00', 4, 5),   -- SINGEL A - KERKOM A
(1,10, 4, 2, '2025-10-12', '14:00', 5, 4),   -- RODE A - DILBEEK A

-- Speeldag 3 - 19/10/2025
(1, 2, 9, 3, '2025-10-19', '14:00', 3, 6),   -- BEERSEL A - WEMMEL A
(1, 4, 3, 3, '2025-10-19', '14:00', 5, 4),   -- DILBEEK A - BEERSEL B
(1, 6, 5, 3, '2025-10-19', '14:00', 6, 3),   -- KERKOM A - DILBEEK B
(1, 7, 8, 3, '2025-10-19', '14:00', 2, 7),   -- DE BLOCKSKES A - SINGEL A
(1, 1,10, 3, '2025-10-19', '14:00', 6, 3),   -- ESSEGHEM A - RODE A

-- Speeldag 4 - 26/10/2025
(1, 7, 2, 4, '2025-10-26', '14:00', 6, 3),   -- DE BLOCKSKES A - BEERSEL A
(1, 8, 4, 4, '2025-10-26', '14:00', 3, 6),   -- SINGEL A - DILBEEK A
(1, 5, 1, 4, '2025-10-26', '14:00', 6, 3),   -- DILBEEK B - ESSEGHEM A
(1, 6, 9, 4, '2025-10-26', '14:00', 6, 3),   -- KERKOM A - WEMMEL A
(1, 3,10, 4, '2025-10-26', '14:00', 5, 4),   -- BEERSEL B - RODE A

-- Speeldag 5 - 09/11/2025
(1, 2, 6, 5, '2025-11-09', '14:00', 3, 6),   -- BEERSEL A - KERKOM A
(1, 4, 7, 5, '2025-11-09', '14:00', 8, 1),   -- DILBEEK A - DE BLOCKSKES A
(1, 1, 8, 5, '2025-11-09', '14:00', 4, 5),   -- ESSEGHEM A - SINGEL A
(1, 9, 3, 5, '2025-11-09', '14:00', 6, 3),   -- WEMMEL A - BEERSEL B
(1,10, 5, 5, '2025-11-09', '14:00', 5, 4),   -- RODE A - DILBEEK B

-- Speeldag 6 - 16/11/2025
(1, 2, 4, 6, '2025-11-16', '14:00', 1, 8),   -- BEERSEL A - DILBEEK A
(1, 6, 1, 6, '2025-11-16', '14:00', 5, 4),   -- KERKOM A - ESSEGHEM A
(1, 5, 9, 6, '2025-11-16', '14:00', 7, 2),   -- DILBEEK B - WEMMEL A
(1, 8, 3, 6, '2025-11-16', '14:00', 2, 7),   -- SINGEL A - BEERSEL B
(1, 7,10, 6, '2025-11-16', '14:00', 4, 5),   -- DE BLOCKSKES A - RODE A

-- Speeldag 7 - 23/11/2025
(1, 4, 6, 7, '2025-11-23', '14:00', 4, 5),   -- DILBEEK A - KERKOM A
(1, 1, 7, 7, '2025-11-23', '14:00', 5, 4),   -- ESSEGHEM A - DE BLOCKSKES A
(1, 9, 8, 7, '2025-11-23', '14:00', 5, 4),   -- WEMMEL A - SINGEL A
(1, 3, 5, 7, '2025-11-23', '14:00', 5, 4),   -- BEERSEL B - DILBEEK B
(1,10, 2, 7, '2025-11-23', '14:00', 7, 2),   -- RODE A - BEERSEL A

-- Speeldag 8 - 30/11/2025
(1, 4, 1, 8, '2025-11-30', '14:00', 4, 5),   -- DILBEEK A - ESSEGHEM A
(1, 7, 9, 8, '2025-11-30', '14:00', 5, 4),   -- DE BLOCKSKES A - WEMMEL A
(1, 6, 3, 8, '2025-11-30', '14:00', 6, 3),   -- KERKOM A - BEERSEL B
(1, 2, 5, 8, '2025-11-30', '14:00', 3, 6),   -- BEERSEL A - DILBEEK B
(1, 8,10, 8, '2025-11-30', '14:00', 8, 1),   -- SINGEL A - RODE A

-- Speeldag 9 - 07/12/2025  (gecorrigeerd)
(1, 1, 2, 9, '2025-12-07', '14:00', 7, 2),   -- ESSEGHEM A - BEERSEL A 
(1, 9, 4, 9, '2025-12-07', '14:00', 5, 4),   -- WEMMEL A - DILBEEK A  
(1, 3, 7, 9, '2025-12-07', '14:00', 5, 4),   -- BEERSEL B - DE BLOCKSKES A 
(1, 5, 8, 9, '2025-12-07', '14:00', 4, 5),   -- DILBEEK B - SINGEL A  
(1,10, 6, 9, '2025-12-07', '14:00', 3, 6);   -- RODE A - KERKOM A 

INSERT INTO petanque.CompetitieDeelname (CompetitieId, ClubId, PloegId, punten, isKampioen, isDegradant) VALUES
(1, 4, 6, 9, NULL, NULL),   -- Kerkom A (9 overwinningen)
(1, 2, 3, 6, NULL, NULL),   -- Beersel B (6 overwinningen)
(1, 3, 4, 5, NULL, NULL),   -- Dilbeek A (5 overwinningen)
(1, 7, 9, 5, NULL, NULL),   -- Wemmel A (5 overwinningen)
(1, 1, 1, 5, NULL, NULL),   -- Esseghem A (5 overwinningen)
(1, 3, 5, 4, NULL, NULL),   -- Dilbeek B (4 overwinningen)
(1, 8, 10, 4, NULL, NULL),  -- Rode A (4 overwinningen)
(1, 6, 8, 4, NULL, NULL),   -- Singel A (4 overwinningen)
(1, 5, 7, 2, NULL, NULL),   -- De Blockskes A (2 overwinningen)
(1, 2, 2, 1, NULL, NULL);  -- Beersel A (1 overwinning)

--bepalen van de kampioen
UPDATE petanque.CompetitieDeelname 
SET isKampioen = 1
WHERE CompetitieId = 1 
  AND PloegId = (
    SELECT TOP 1 PloegId 
    FROM petanque.CompetitieDeelname 
    WHERE CompetitieId = 1 
    ORDER BY punten DESC
  );

--bepalen van de degradant  
UPDATE petanque.CompetitieDeelname 
SET isDegradant = 1
WHERE CompetitieId = 1 
AND PloegId IN (
    SELECT TOP 1 PloegId 
    FROM petanque.CompetitieDeelname 
    WHERE CompetitieId = 1 
    ORDER BY punten ASC
);

INSERT INTO petanque.Eindronde (ReeksNiveau, Provincie, winnaarPloegId, Seizoen)
SELECT 
    'Ere' AS ReeksNiveau,
    a.Provincie,
    cd.PloegId AS winnaarPloegId,
    c.Seizoen
FROM petanque.CompetitieDeelname cd
JOIN petanque.Competitie c ON cd.CompetitieId = c.id
JOIN petanque.Afdeling a ON c.AfdelingId = a.id
WHERE cd.isKampioen = 1 
  AND a.ReeksNiveau = 'Ere'
  AND c.Seizoen = '2025-2026'
  AND a.niveauType = 'Provinciaal'
  AND NOT EXISTS (
      SELECT 1 FROM petanque.Eindronde e 
      WHERE e.Provincie = a.Provincie 
        AND e.Seizoen = c.Seizoen
  );
