CREATE DATABASE [Warsztat_jubilerski];
GO

USE Warsztat_jubilerski;

CREATE TABLE Adresy (
    ID_adresu INT IDENTITY(1,1) PRIMARY KEY,
    Nazwa_ulicy VARCHAR(40) CHECK (Nazwa_ulicy LIKE '[A-Z��ʣ�ӌ��][a-z����󜟿]%' OR Nazwa_ulicy LIKE '[0-9]%[A-Z��ʣ�ӌ��][a-z����󜟿]%') NOT NULL,
    Numer_budynku VARCHAR(6) CHECK (Numer_budynku LIKE '%[0-9]%' OR Numer_budynku LIKE '%[0-9]%[a-z]%' OR Numer_budynku LIKE '%[0-9]%-%[0-9]%' OR Numer_budynku LIKE '%[0-9]%-%[0-9]%[a-z]' OR Numer_budynku LIKE '%[IVXLCDM]%')  NOT NULL,
    Numer_lokalu VARCHAR(4) CHECK (Numer_lokalu LIKE '%[0-9]%'),
    Kod_pocztowy CHAR(6) CHECK (Kod_pocztowy LIKE '[0-9][0-9]-[0-9][0-9][0-9]') NOT NULL,
	Miejscowo�� VARCHAR(30) NOT NULL
); 

CREATE TABLE Ludzie (
    ID_osoby INT IDENTITY(1,1) PRIMARY KEY,
    Imi� VARCHAR(20) NOT NULL CHECK (Imi� LIKE '[A-Z��ʣ�ӌ��][a-z����󜟿]%'),
    Nazwisko VARCHAR(30) NOT NULL CHECK (Nazwisko LIKE '[A-Z��ʣ�ӌ��][a-z����󜟿]%' OR Nazwisko LIKE '[A-Z��ʣ�ӌ��][a-z����󜟿]%-[A-Z��ʣ�ӌ��][a-z����󜟿]%'),
    Adres_email VARCHAR(40) CHECK (Adres_email LIKE '%@%.%') NOT NULL UNIQUE,
    Numer_telefonu CHAR(9) CHECK (Numer_telefonu LIKE '%[0-9]%') NOT NULL UNIQUE,
	ID_adresu INT NOT NULL,
    FOREIGN KEY (ID_adresu)
		REFERENCES Adresy (ID_adresu)
		ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE Magazyny (
    Numer_magazynu INT IDENTITY(1,1) PRIMARY KEY,
    Powierzchnia DECIMAL(6,3) NOT NULL CHECK (Powierzchnia BETWEEN 20 AND 500), --3 miejsca po przeciku, ��cznie maks 6 cyfr
    Typ_magazynu VARCHAR(24) NOT NULL CHECK (Typ_magazynu in ('magazyn z�ota', 'magazyn wyrob�w gotowych')),
	ID_adresu INT NOT NULL UNIQUE,
    FOREIGN KEY (ID_adresu)
		REFERENCES Adresy (ID_adresu)
		ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE Stanowiska (
    Numer_stanowiska INT IDENTITY(1,1) PRIMARY KEY,
    Typ_stanowiska VARCHAR(15) NOT NULL CHECK (Typ_stanowiska in ('szlifowanie', 'cyzelowanie', 'grawerowanie', 'odlewanie', 'wyt�aczanie', 'przetapianie', 'spawanie', 'lutowanie', 'granulacja', 'filigranowanie', 'bejcowanie', 'kszta�towanie')),
	Zu�ycie_pr�du DECIMAL (4,2) NOT NULL CHECK (Zu�ycie_pr�du>0)
);

CREATE TABLE Sprzeda�e (
    Numer_transakcji INT IDENTITY(1,1) PRIMARY KEY,
    Data_sprzeda�y DATETIME DEFAULT GETDATE() NOT NULL,
    Wysy�ka VARCHAR(3) CHECK(Wysy�ka IN ('tak', 'nie')) DEFAULT NULL,
    Koszty_wysy�ki DECIMAL(3,1) CHECK (Koszty_wysy�ki>=0 AND Koszty_wysy�ki<=15.9),
    ID_adresu INT,
    ID_osoby INT,
    FOREIGN KEY (ID_adresu)
        REFERENCES Adresy (ID_adresu)
        ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (ID_osoby) 
        REFERENCES Ludzie (ID_osoby)
        ON DELETE NO ACTION ON UPDATE NO ACTION
);

CREATE TABLE Surowce (
    ID_partii INT IDENTITY(1,1) PRIMARY KEY,
    Pr�ba_z�ota CHAR(3) CHECK(Pr�ba_z�ota IN (333, 375, 500, 585, 750, 960)) NOT NULL,
    Waga_partii DECIMAL(7,3) CHECK (Waga_partii>0) NOT NULL,
    Data_dostarczenia DATETIME DEFAULT GETDATE() NOT NULL,
	Warto��_pieni�na DECIMAL(8,2) NOT NULL,
	Urz�d_probierczy CHAR(1) CHECK(Urz�d_probierczy IN ('A','B','C','H','K','�','P','V','W','Z')) NOT NULL,
	Kolor VARCHAR(6) CHECK(Kolor IN ('��ty','bia�y','r�owy','czarny')) NOT NULL,
    Numer_magazynu INT,
    FOREIGN KEY (Numer_magazynu) 
        REFERENCES Magazyny (Numer_magazynu)
        ON DELETE NO ACTION ON UPDATE NO ACTION
);

CREATE TABLE Wyroby_jubilerskie (
	ID_produktu INT IDENTITY(1,1) PRIMARY KEY,
	Typ_produktu VARCHAR(11) CHECK(Typ_produktu IN ('kolczyki','naszyjnik','bransoletka','pier�cionek')) NOT NULL,
	Ilo��_na_stanie SMALLINT CHECK(Ilo��_na_stanie>=0) NOT NULL,
	Waga_produktu DECIMAL(5,2) CHECK (Waga_produktu BETWEEN 1 AND 100) NOT NULL,
	Numer_magazynu INT,
    ID_partii INT NOT NULL,
	FOREIGN KEY (Numer_magazynu) 
        REFERENCES Magazyny (Numer_magazynu)
        ON DELETE NO ACTION ON UPDATE NO ACTION,
    FOREIGN KEY (ID_partii) 
        REFERENCES Surowce (ID_partii)
        ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE Wyr�bSprzeda� (
	ID_produktu INT,
	Numer_transakcji INT NOT NULL,
	Zakupiona_ilo�� INT CHECK (Zakupiona_ilo��>0) NOT NULL,
	FOREIGN KEY (ID_produktu) 
        REFERENCES Wyroby_jubilerskie (ID_produktu)
        ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (Numer_transakcji) 
        REFERENCES Sprzeda�e (Numer_transakcji)
        ON DELETE CASCADE ON UPDATE CASCADE,
	PRIMARY KEY (ID_produktu, Numer_transakcji)
);

CREATE TABLE Pracownicy (
	ID_osoby INT,
	Stanowisko VARCHAR(24) CHECK(Stanowisko IN ('w�a�ciciel','kierownik','rzemie�lnik','magazynier','sprzedawca stacjonarny','sprzedawca internetowy', 'ksi�gowy')) NOT NULL,
	Wynagrodzenie DECIMAL(7,2) CHECK (Wynagrodzenie BETWEEN 3600 AND 17000) NOT NULL,
	Data_zatrudnienia DATE DEFAULT GETDATE() NOT NULL,
	PESEL CHAR(11) NOT NULL CHECK (PESEL LIKE '%[0-9]%') UNIQUE,
	Zatrudniony char(3) CHECK (Zatrudniony IN ('tak', 'nie')) NOT NULL DEFAULT 'tak',
	Numer_rachunku_bankowego CHAR(26) NOT NULL CHECK (Numer_rachunku_bankowego LIKE '%[0-9]%') UNIQUE,
	Numer_magazynu INT,
	ID_szefa CHAR(11),
	PRIMARY KEY(PESEL),
	FOREIGN KEY (ID_osoby) 
        REFERENCES Ludzie (ID_osoby),
	FOREIGN KEY (Numer_magazynu ) 
        REFERENCES Magazyny (Numer_magazynu)
        ON DELETE SET NULL ON UPDATE CASCADE,
	FOREIGN KEY (ID_szefa) 
        REFERENCES Pracownicy (PESEL)
);

CREATE TABLE PracownikStanowisko (
	ID_pracownika CHAR(11),
	Numer_stanowiska INT NOT NULL,
	Data_rozpocz�cia_zajmowania_stanowiska DATETIME NOT NULL,
	Data_zako�czenia_zajmowania_stanowiska DATETIME NOT NULL,
	FOREIGN KEY (ID_pracownika) 
        REFERENCES Pracownicy (PESEL)
        ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (Numer_stanowiska) 
        REFERENCES Stanowiska (Numer_stanowiska)
        ON DELETE CASCADE ON UPDATE CASCADE,
	PRIMARY KEY (ID_pracownika, Data_rozpocz�cia_zajmowania_stanowiska)
);


CREATE TABLE PracownikWyr�b (
	ID_pracownika CHAR(11),
	ID_produktu INT,
	Czas_wytwrzania_produktu_przez_pracownika DECIMAL(4,2) CHECK (Czas_wytwrzania_produktu_przez_pracownika>0) NOT NULL,
	FOREIGN KEY (ID_pracownika) 
        REFERENCES Pracownicy (PESEL)
        ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (ID_produktu) 
        REFERENCES Wyroby_jubilerskie (ID_produktu)
        ON DELETE CASCADE ON UPDATE CASCADE,
	PRIMARY KEY (ID_pracownika, ID_produktu)
);