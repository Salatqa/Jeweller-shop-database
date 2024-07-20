USE Warsztat_jubilerski;

DROP TABLE PracownikWyrób; 
DROP TABLE PracownikStanowisko;
DROP TABLE Pracownicy;
DROP TABLE WyróbSprzeda¿;
DROP TABLE Wyroby_jubilerskie;
DROP TABLE Surowce;
DROP TABLE Sprzeda¿e;
DROP TABLE Stanowiska;
DROP TABLE Magazyny;
DROP TABLE Ludzie;
DROP TABLE Adresy;

USE master;
ALTER DATABASE [Warsztat_jubilerski]
SET SINGLE_USER 
WITH ROLLBACK IMMEDIATE;
GO
DROP DATABASE [Warsztat_jubilerski];
GO