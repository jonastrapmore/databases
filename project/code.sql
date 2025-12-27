/*
create schema Robbe;
go
create schema Maxim;
go


create table Club (
id int identity(1,1),
provincie nvarchar(50) not null,
naam nvarchar(100) not null,
adres nvarchar(50) not null,
huisnummer nvarchar(10) not null,
postcode nvarchar(50) not null,
gemeente nvarchar(50) not null,
aantalTerreinen int not null default (0),
gebouwGoedgekeurd bit not null default (0),
tshirtVerplicht bit not null default(0),
licentieNummer nvarchar(50) null, 
oprichtingsDatum date not null default(getdate()),
constraint PK_Club primary key (id),
constraint CK_aantalTerreinen  check (aantalTerreinen in(0,3,6,9,12)),
constraint CK_licentieNummer check (gebouwgoedgekeurd = 1),
constraint CK_Provincie check (provincie in ('Oost Vlaanderen','West Vlaanderen','Limburg'))
constraint UQ_Naam UNIQUE (naam)
);

create table Club (
id int identity(1,1),
provincie nvarchar(50) not null,
naam nvarchar(100) not null,
adres nvarchar(50) not null,
huisnummer nvarchar(10) not null,
postcode nvarchar(10) not null,
gemeente nvarchar(50) not null,
aantalTerreinen int not null,
gebouwGoedgekeurd bit not null default (0),
tshirtVerplicht bit not null default(0),
licentieNummer nvarchar(50) null, 
oprichtingsDatum date not null default(getdate()),
constraint PK_Club primary key (id),
constraint CK_aantalTerreinen  check (aantalTerreinen in(3,6,9,12)),
constraint CK_licentieNummer check (gebouwGoedgekeurd = 0 OR (gebouwGoedgekeurd = 1 AND licentieNummer IS NOT NULL)),
constraint CK_Provincie check (provincie in ('Oost Vlaanderen','West Vlaanderen','Limburg','Vlaams Brabant','Antwerpen')),
constraint UQ_Naam UNIQUE (naam)
);

insert into Club (provincie,naam,adres,huisnummer,postcode,gemeente,aantalTerreinen,gebouwGoedgekeurd,tshirtVerplicht,licentienummer)
values('West Vlaanderen','Jonas zijn Clubje','kerkstraat','3','2300','Ergensdorp',3,1,1,'123456A');
insert into Club (provincie,naam,adres,huisnummer,postcode,gemeente,aantalTerreinen,gebouwGoedgekeurd,tshirtVerplicht)
values('West Vlaanderen','Corne zijn Clubje','dorpstraat','3','2300','Onsdorp',3,0,1);
insert into Club (provincie,naam,adres,huisnummer,postcode,gemeente,aantalTerreinen,gebouwGoedgekeurd,tshirtVerplicht)
values('Antwerpen','Maxim zijn Clubje','dorpstraat','3','2300','Onsdorp',3,0,1);

create table Terrein (
id int identity(1,1),
clubId int not null,
nummer int not null,
lengte_cm int not null,
breedte_cm int not null,
Constraint PK_Terrein primary Key (id),
Constraint FK_Terrein_Club foreign Key (clubId) references Club (id) on delete cascade,
);

insert into Terrein (ClubId,nummer,lengte_cm,breedte_cm)
values(5,1,1100,250);

--delete from club where id = 5;
1..1 <---> 1..*
Foreign Key = not null {NNA}

1..1 <---> 0..*
Foreign Key = null {NA}

*/

--create table Club (


--drop table club;