CREATE DATABASE [Warsztat_jubilerski];
GO

USE Warsztat_jubilerski;

CREATE TABLE Adresy (
    ID_adresu INT IDENTITY(1,1) PRIMARY KEY,
    Nazwa_ulicy VARCHAR(40) CHECK (Nazwa_ulicy LIKE '[A-Z¥ÆÊ£ÑÓŒ¯][a-z¹æê³ñóœŸ¿]%' OR Nazwa_ulicy LIKE '[0-9]%[A-Z¥ÆÊ£ÑÓŒ¯][a-z¹æê³ñóœŸ¿]%') NOT NULL,
    Numer_budynku VARCHAR(6) CHECK (Numer_budynku LIKE '%[0-9]%' OR Numer_budynku LIKE '%[0-9]%[a-z]%' OR Numer_budynku LIKE '%[0-9]%-%[0-9]%' OR Numer_budynku LIKE '%[0-9]%-%[0-9]%[a-z]' OR Numer_budynku LIKE '%[IVXLCDM]%')  NOT NULL,
    Numer_lokalu VARCHAR(4) CHECK (Numer_lokalu LIKE '%[0-9]%'),
    Kod_pocztowy CHAR(6) CHECK (Kod_pocztowy LIKE '[0-9][0-9]-[0-9][0-9][0-9]') NOT NULL,
	Miejscowoœæ VARCHAR(30) NOT NULL
); 

CREATE TABLE Ludzie (
    ID_osoby INT IDENTITY(1,1) PRIMARY KEY,
    Imiê VARCHAR(20) NOT NULL CHECK (Imiê LIKE '[A-Z¥ÆÊ£ÑÓŒ¯][a-z¹æê³ñóœŸ¿]%'),
    Nazwisko VARCHAR(30) NOT NULL CHECK (Nazwisko LIKE '[A-Z¥ÆÊ£ÑÓŒ¯][a-z¹æê³ñóœŸ¿]%' OR Nazwisko LIKE '[A-Z¥ÆÊ£ÑÓŒ¯][a-z¹æê³ñóœŸ¿]%-[A-Z¥ÆÊ£ÑÓŒ¯][a-z¹æê³ñóœŸ¿]%'),
    Adres_email VARCHAR(40) CHECK (Adres_email LIKE '%@%.%') NOT NULL UNIQUE,
    Numer_telefonu CHAR(9) CHECK (Numer_telefonu LIKE '%[0-9]%') NOT NULL UNIQUE,
	ID_adresu INT NOT NULL,
    FOREIGN KEY (ID_adresu)
		REFERENCES Adresy (ID_adresu)
		ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE Magazyny (
    Numer_magazynu INT IDENTITY(1,1) PRIMARY KEY,
    Powierzchnia DECIMAL(6,3) NOT NULL CHECK (Powierzchnia BETWEEN 20 AND 500), --3 miejsca po przeciku, ³¹cznie maks 6 cyfr
    Typ_magazynu VARCHAR(24) NOT NULL CHECK (Typ_magazynu in ('magazyn z³ota', 'magazyn wyrobów gotowych')),
	ID_adresu INT NOT NULL UNIQUE,
    FOREIGN KEY (ID_adresu)
		REFERENCES Adresy (ID_adresu)
		ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE Stanowiska (
    Numer_stanowiska INT IDENTITY(1,1) PRIMARY KEY,
    Typ_stanowiska VARCHAR(15) NOT NULL CHECK (Typ_stanowiska in ('szlifowanie', 'cyzelowanie', 'grawerowanie', 'odlewanie', 'wyt³aczanie', 'przetapianie', 'spawanie', 'lutowanie', 'granulacja', 'filigranowanie', 'bejcowanie', 'kszta³towanie')),
	Zu¿ycie_pr¹du DECIMAL (4,2) NOT NULL CHECK (Zu¿ycie_pr¹du>0)
);

CREATE TABLE Sprzeda¿e (
    Numer_transakcji INT IDENTITY(1,1) PRIMARY KEY,
    Data_sprzeda¿y DATETIME DEFAULT GETDATE() NOT NULL,
    Wysy³ka VARCHAR(3) CHECK(Wysy³ka IN ('tak', 'nie')) DEFAULT NULL,
    Koszty_wysy³ki DECIMAL(3,1) CHECK (Koszty_wysy³ki>=0 AND Koszty_wysy³ki<=15.9),
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
    Próba_z³ota CHAR(3) CHECK(Próba_z³ota IN (333, 375, 500, 585, 750, 960)) NOT NULL,
    Waga_partii DECIMAL(7,3) CHECK (Waga_partii>0) NOT NULL,
    Data_dostarczenia DATETIME DEFAULT GETDATE() NOT NULL,
	Wartoœæ_pieniê¿na DECIMAL(8,2) NOT NULL,
	Urz¹d_probierczy CHAR(1) CHECK(Urz¹d_probierczy IN ('A','B','C','H','K','£','P','V','W','Z')) NOT NULL,
	Kolor VARCHAR(6) CHECK(Kolor IN ('¿ó³ty','bia³y','ró¿owy','czarny')) NOT NULL,
    Numer_magazynu INT,
    FOREIGN KEY (Numer_magazynu) 
        REFERENCES Magazyny (Numer_magazynu)
        ON DELETE NO ACTION ON UPDATE NO ACTION
);

CREATE TABLE Wyroby_jubilerskie (
	ID_produktu INT IDENTITY(1,1) PRIMARY KEY,
	Typ_produktu VARCHAR(11) CHECK(Typ_produktu IN ('kolczyki','naszyjnik','bransoletka','pierœcionek')) NOT NULL,
	Iloœæ_na_stanie SMALLINT CHECK(Iloœæ_na_stanie>=0) NOT NULL,
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

CREATE TABLE WyróbSprzeda¿ (
	ID_produktu INT,
	Numer_transakcji INT NOT NULL,
	Zakupiona_iloœæ INT CHECK (Zakupiona_iloœæ>0) NOT NULL,
	FOREIGN KEY (ID_produktu) 
        REFERENCES Wyroby_jubilerskie (ID_produktu)
        ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (Numer_transakcji) 
        REFERENCES Sprzeda¿e (Numer_transakcji)
        ON DELETE CASCADE ON UPDATE CASCADE,
	PRIMARY KEY (ID_produktu, Numer_transakcji)
);

CREATE TABLE Pracownicy (
	ID_osoby INT,
	Stanowisko VARCHAR(24) CHECK(Stanowisko IN ('w³aœciciel','kierownik','rzemieœlnik','magazynier','sprzedawca stacjonarny','sprzedawca internetowy', 'ksiêgowy')) NOT NULL,
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
	Data_rozpoczêcia_zajmowania_stanowiska DATETIME NOT NULL,
	Data_zakoñczenia_zajmowania_stanowiska DATETIME NOT NULL,
	FOREIGN KEY (ID_pracownika) 
        REFERENCES Pracownicy (PESEL)
        ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (Numer_stanowiska) 
        REFERENCES Stanowiska (Numer_stanowiska)
        ON DELETE CASCADE ON UPDATE CASCADE,
	PRIMARY KEY (ID_pracownika, Data_rozpoczêcia_zajmowania_stanowiska)
);


CREATE TABLE PracownikWyrób (
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