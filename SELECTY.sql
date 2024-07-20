use Warsztat_jubilerski

----------------ZAPYTANIE 1----------------
--SCENARIUSZ: W�a�ciciel chce da� podwy�k� 3 pracownikom (rzemie�lnikom), kt�rzy pracuj� w warsztacie d�u�ej ni� rok oraz wytworzyli najwi�cej produkt�w
--ZAPYTANIE W J�ZYKU NATURALNYM: Utw�rz zestawienie 3 pracownik�w, kt�rych okres zatrudnienia jest wi�kszy r�wny rok (12 miesi�cy) i wytworzyli oni najwi�cej produkt�w, 
--posortuj malej�co po liczbie wytworzonych produkt�w

SELECT TOP 3 Pracownicy.PESEL, Ludzie.Imi�, Ludzie.Nazwisko, Pracownicy.Stanowisko, Pracownicy.Data_zatrudnienia, COUNT(PracownikWyr�b.ID_produktu) AS Liczba_Produktow
FROM Pracownicy
JOIN PracownikWyr�b ON Pracownicy.PESEL = PracownikWyr�b.ID_pracownika
JOIN Ludzie ON Pracownicy.ID_osoby = Ludzie.ID_osoby
WHERE DATEDIFF(month, Pracownicy.Data_zatrudnienia, GETDATE()) >= 12 AND Pracownicy.Zatrudniony='tak'
GROUP BY Pracownicy.PESEL, Ludzie.Imi�, Ludzie.Nazwisko, Pracownicy.Stanowisko, Pracownicy.Data_zatrudnienia
ORDER BY Liczba_Produktow DESC;

--demonstracja danych
SELECT Pracownicy.PESEL, Ludzie.Imi�, Ludzie.Nazwisko, Pracownicy.Stanowisko, Pracownicy.Data_zatrudnienia, COUNT(PracownikWyr�b.ID_produktu) AS Liczba_Produktow
FROM Pracownicy
JOIN PracownikWyr�b ON Pracownicy.PESEL = PracownikWyr�b.ID_pracownika
JOIN Ludzie ON Pracownicy.ID_osoby = Ludzie.ID_osoby
GROUP BY Pracownicy.PESEL, Ludzie.Imi�, Ludzie.Nazwisko, Pracownicy.Stanowisko, Pracownicy.Data_zatrudnienia
ORDER BY Data_zatrudnienia DESC;


----------------ZAPYTANIE 2----------------
--SCENARIUSZ: W�a�cicielowi przychodzi bardzo du�y rachunek za pr�d, wi�c chcia�by dowiedzie� si�, kt�ry z pracownik�w zu�ywa go najwi�cej.
--ZAPYTANIE W J�ZYKU NATURALNYM: Utw�rz zestawienie rzemie�link�w, kt�rzy wytwarzaj�c produkty wykorzystuj� najwi�cej pr�du i posortuj ich w kolejno�ci malej�cej.

DROP VIEW IF EXISTS Zu�yciePr�duPracownik�w;

GO
CREATE VIEW Zu�yciePr�duPracownik�w AS
SELECT Pracownicy.PESEL, Ludzie.Imi�, Ludzie.Nazwisko, 
FORMAT(SUM(DATEDIFF(minute, PracownikStanowisko.Data_rozpocz�cia_zajmowania_stanowiska, PracownikStanowisko.Data_zako�czenia_zajmowania_stanowiska) * Stanowiska.Zu�ycie_pr�du/60), 'N2') 
AS Zu�yty_pr�d --FORMAT pozwala wy�wietli� tylko z dwoma cyframi po przecinku
FROM Pracownicy
JOIN PracownikStanowisko ON Pracownicy.PESEL = PracownikStanowisko.ID_pracownika
JOIN Stanowiska ON PracownikStanowisko.Numer_stanowiska = Stanowiska.Numer_stanowiska
JOIN Ludzie ON Pracownicy.ID_osoby = Ludzie.ID_osoby
GROUP BY Pracownicy.PESEL, Ludzie.Imi�, Ludzie.Nazwisko;
GO

SELECT * FROM Zu�yciePr�duPracownik�w
ORDER BY Zu�yty_pr�d DESC;

--demonstracja danych
SELECT Pracownicy.PESEL, Ludzie.Imi�, Ludzie.Nazwisko, PracownikStanowisko.Data_rozpocz�cia_zajmowania_stanowiska, PracownikStanowisko.Data_zako�czenia_zajmowania_stanowiska, 
Stanowiska.Zu�ycie_pr�du, FORMAT(SUM(DATEDIFF(minute, PracownikStanowisko.Data_rozpocz�cia_zajmowania_stanowiska, PracownikStanowisko.Data_zako�czenia_zajmowania_stanowiska)), 'N2') 
AS Czas_zajmowania_stanowiska_w_minutach
FROM Pracownicy
JOIN PracownikStanowisko ON Pracownicy.PESEL = PracownikStanowisko.ID_pracownika
JOIN Stanowiska ON PracownikStanowisko.Numer_stanowiska = Stanowiska.Numer_stanowiska
JOIN Ludzie ON Pracownicy.ID_osoby = Ludzie.ID_osoby
GROUP BY Pracownicy.PESEL, Ludzie.Imi�, Ludzie.Nazwisko, PracownikStanowisko.Data_rozpocz�cia_zajmowania_stanowiska, PracownikStanowisko.Data_zako�czenia_zajmowania_stanowiska, 
Stanowiska.Zu�ycie_pr�du;


----------------ZAPYTANIE 3----------------
--SCENARIUSZ: Cena produktu nie jest przechowywana w tabeli "Wyroby_jubilerskie", poniewa� mo�e zosta� obliczona na podstawie innych danych, jakimi dysponuje baza. Cena jest jednak 
--niezb�dnym elementem, aby wiedzie� za ile sprzedawa� dane produkty, tworzymy widok, aby m�c p�niej korzysta� z wyliczonej ceny, a nie wylicza� j� osobno za ka�dym razem
--ZAPYTANIE W J�ZYKU NATURALNYM: Utw�rz widok z zestawieniem produkt�w (ich id i typ�w) wraz z wyliczon� cen�, uwzgl�dniaj�c koszt materia��w zu�ytych do ich produkcji, czas wytwarzania produktu 
-- i wynagrodzenie praciwnik�w, kt�rzy wytwarzali dany produkt

DROP VIEW IF EXISTS Zestawienie_produkt�w_z_cenami;

GO 
CREATE VIEW Zestawienie_produkt�w_z_cenami AS
SELECT Wyroby_jubilerskie.ID_produktu, Wyroby_jubilerskie.Typ_produktu, ROUND(SUM((PracownikWyr�b.Czas_wytwrzania_produktu_przez_pracownika * Pracownicy.Wynagrodzenie/(22*8)) 
	--dzielimy na 22, bo 22 to �rednia ilo�� dni pracy w miesi�cu oraz przez 8, bo pracownicy pracuj� po 8h; uzyskujemy stawk� godzinow�
    + (Wyroby_jubilerskie.Waga_produktu * Surowce.Warto��_pieni�na/1000)),2) AS Cena_produktu --dzielimy przez tysi�c, aby uzyska� cen� za gram
FROM Wyroby_jubilerskie
JOIN PracownikWyr�b ON Wyroby_jubilerskie.ID_produktu = PracownikWyr�b.ID_produktu
JOIN Pracownicy ON PracownikWyr�b.ID_pracownika = Pracownicy.PESEL
JOIN Surowce ON Wyroby_jubilerskie.ID_partii = Surowce.ID_partii
GROUP BY Wyroby_jubilerskie.ID_produktu, Wyroby_jubilerskie.Typ_produktu;
GO

SELECT * FROM Zestawienie_produkt�w_z_cenami 
ORDER BY ID_produktu;

--demonstracja danych
SELECT Wyroby_jubilerskie.ID_produktu, Wyroby_jubilerskie.Typ_produktu, PracownikWyr�b.Czas_wytwrzania_produktu_przez_pracownika, 
	Pracownicy.PESEL, FORMAT(Pracownicy.Wynagrodzenie/(22*8),'N2') AS Stawka_godzinowa_pracownika
FROM Wyroby_jubilerskie
JOIN PracownikWyr�b ON Wyroby_jubilerskie.ID_produktu = PracownikWyr�b.ID_produktu
JOIN Pracownicy ON PracownikWyr�b.ID_pracownika = Pracownicy.PESEL
GROUP BY Wyroby_jubilerskie.ID_produktu, Wyroby_jubilerskie.Typ_produktu, PracownikWyr�b.Czas_wytwrzania_produktu_przez_pracownika, Pracownicy.PESEL, Pracownicy.Wynagrodzenie, Wyroby_jubilerskie.Waga_produktu
ORDER BY ID_produktu;

SELECT Wyroby_jubilerskie.ID_produktu, Wyroby_jubilerskie.Typ_produktu, Wyroby_jubilerskie.Waga_produktu, FORMAT(Surowce.Warto��_pieni�na/1000,'N2') AS Cena_surowca_za_gram
FROM Wyroby_jubilerskie
JOIN PracownikWyr�b ON Wyroby_jubilerskie.ID_produktu = PracownikWyr�b.ID_produktu
JOIN Surowce ON Wyroby_jubilerskie.ID_partii = Surowce.ID_partii
GROUP BY Wyroby_jubilerskie.ID_produktu, Wyroby_jubilerskie.Typ_produktu, Wyroby_jubilerskie.Waga_produktu, Surowce.Warto��_pieni�na
ORDER BY ID_produktu;


----------------ZAPYTANIE 4----------------
--SCENARIUSZ: Rzemie�lnik ma za zadanie zaprojektowa� nowy model kolczyk�w. Wie, �e chce je wykona� z czarnego z�ota pr�by 375, natomiast nie wie jeszcze ile surowca zu�yje. 
--Chcemy wi�c obliczy� ile gram�w takiego z�ota dodatkowo zam�wi�, tak, aby starczy�o na kilka prototyp�w tego modelu. Wag� kolczyk�w szacujemy na podstawie wag wszystkich kolczyk�w w ofercie 
--o tych samych parametrach, aby obliczy� przybli�one zapotrzebowanie na surowiec i przyjmujemy, �e kupujemy z�oto na 10 par kolczyk�w o takiej �redniej wadze (aby wykona� 
--kilka prototyp�w plus mie� zapas).
--ZAPYTANIE W J�ZYKU NATURALNYM: Wybierz wagi wszystkich kolczyk�w z czarnego z�ota o pr�bie 375 i oblicz ich �redni�.

SELECT 10 * AVG(Waga_produktu) AS Potrzebna_waga_surowca
FROM (
    SELECT Wyroby_jubilerskie.Waga_produktu
    FROM Wyroby_jubilerskie
    JOIN Surowce ON Wyroby_jubilerskie.ID_partii = Surowce.ID_partii
    WHERE Wyroby_jubilerskie.Typ_produktu = 'kolczyki'
    AND Surowce.Pr�ba_z�ota = '375'
    AND Surowce.Kolor = 'czarny'
) AS Szukana_waga;

--demonstracja danych
SELECT Wyroby_jubilerskie.ID_produktu, Wyroby_jubilerskie.Waga_produktu, Wyroby_jubilerskie.Typ_produktu, Surowce.Pr�ba_z�ota, Surowce.Kolor
FROM Wyroby_jubilerskie
JOIN Surowce ON Wyroby_jubilerskie.ID_partii = Surowce.ID_partii
WHERE Wyroby_jubilerskie.Typ_produktu = 'kolczyki'
AND Surowce.Pr�ba_z�ota = '375'
AND Surowce.Kolor = 'czarny';


----------------ZAPYTANIE 5----------------
--SCENARIUSZ: W�a�ciciel chce otworzy� nowy punkt sprzeda�y stacjonarnej w jak najbardziej op�acalnej lokalizacji, dlatego 
--musi sprawdzi� z jakich miejscowo�ci pochodzi najwi�cej zam�wie� w ci�gu ostatniego roku
--ZAPYTANIE W J�ZYKU NATURALNYM: Utw�rz zestawienie miejscowo�ci wed�ug ilo�ci zam�wie� i posortuj te miejscowo�ci malej�co na podstawie ilo�ci zam�wie�

SELECT Adresy.Miejscowo��, COUNT(Sprzeda�e.Numer_transakcji) AS Ilo��_zam�wie�, SUM(Wyr�bSprzeda�.Zakupiona_ilo��) AS Ilo��_sprzedanych_produkt�w
FROM Sprzeda�e
JOIN Wyr�bSprzeda� ON Sprzeda�e.Numer_transakcji = Wyr�bSprzeda�.Numer_transakcji
JOIN Adresy ON Sprzeda�e.ID_adresu = Adresy.ID_adresu
WHERE DATEDIFF(month, Sprzeda�e.Data_sprzeda�y, GETDATE())<=12
GROUP BY Adresy.Miejscowo��
ORDER BY Ilo��_sprzedanych_produkt�w DESC;

--demonstracja danych
SELECT Adresy.Miejscowo��, Sprzeda�e.Numer_transakcji, Wyr�bSprzeda�.Zakupiona_ilo�� 
FROM Sprzeda�e
JOIN Wyr�bSprzeda� ON Sprzeda�e.Numer_transakcji = Wyr�bSprzeda�.Numer_transakcji
JOIN Adresy ON Sprzeda�e.ID_adresu = Adresy.ID_adresu;


----------------ZAPYTANIE 6----------------
--SCENARIUSZ: Dostali�my du�� dostaw� ��tego z�ota. Chcemy znale�� w bazie klient�w, kt�rzy w przesz�o�ci kupili bi�uteri� z ��tego z�ota, aby wys�a� im mailowo reklam� 
--i zach�ci� do zakupu.
--ZAPYTANIE W J�ZYKU NATURALNYM: Wy�wietl imiona, nazwiska oraz adresy e-mail os�b, kt�re kupi�y kiedy� bi�uteri� z ��tego z�ota.

SELECT DISTINCT --DISTINCT po to, �eby si� nie powtarza�y osoby (je�li kilka razy zamawia�y produkty)
    Ludzie.Imi�,Ludzie.Nazwisko, Ludzie.Adres_email
FROM Ludzie
JOIN Sprzeda�e ON Ludzie.ID_osoby = Sprzeda�e.ID_osoby
JOIN Wyr�bSprzeda� ON Sprzeda�e.Numer_transakcji = Wyr�bSprzeda�.Numer_transakcji
JOIN Wyroby_jubilerskie ON Wyr�bSprzeda�.ID_produktu = Wyroby_jubilerskie.ID_produktu
JOIN Surowce ON Wyroby_jubilerskie.ID_partii = Surowce.ID_partii
WHERE Surowce.Kolor = '��ty';

--demonstracja danych
SELECT DISTINCT Ludzie.Imi�,Ludzie.Nazwisko, Surowce.Kolor
FROM Ludzie
JOIN Sprzeda�e ON Ludzie.ID_osoby = Sprzeda�e.ID_osoby
JOIN Wyr�bSprzeda� ON Sprzeda�e.Numer_transakcji = Wyr�bSprzeda�.Numer_transakcji
JOIN Wyroby_jubilerskie ON Wyr�bSprzeda�.ID_produktu = Wyroby_jubilerskie.ID_produktu
JOIN Surowce ON Wyroby_jubilerskie.ID_partii = Surowce.ID_partii


----------------ZAPYTANIE 7----------------
--SCENARIUSZ: Klient szuka prezentu dla c�rek bli�niaczek. Potrzebuje dw�ch identycznych pier�cionk�w i chce, aby pr�ba z�ota wynosi�a 375, 500 lub 585. Bud�et jakim dysponuje
--na pojedynczy wyr�b to mi�dzy 250 a 600 z�, kolor jest mu oboj�tny. Chcemy pokaza� mu dost�pne opcje.
--ZAPYTANIE W J�ZYKU NATURALNYM: Wy�wietl wszystkie pier�cionki o pr�bie 375, 500 i 585, kt�rych s� co najmniej dwie sztuki na stanie, a ich przedzia� cenowy to 250-600 z� w��cznie.

SELECT Wyroby_jubilerskie.ID_produktu, Wyroby_jubilerskie.Typ_produktu, Surowce.Pr�ba_z�ota,Surowce.Kolor, FORMAT((SELECT Zestawienie_produkt�w_z_cenami.Cena_produktu 
FROM Zestawienie_produkt�w_z_cenami WHERE Wyroby_jubilerskie.ID_produktu = Zestawienie_produkt�w_z_cenami.ID_produktu), 'N2') AS Cena_produktu, Wyroby_jubilerskie.Ilo��_na_stanie
FROM Wyroby_jubilerskie
JOIN Surowce ON Wyroby_jubilerskie.ID_partii = Surowce.ID_partii
WHERE Wyroby_jubilerskie.Typ_produktu = 'pier�cionek' AND Surowce.Pr�ba_z�ota IN ('375', '500', '585') AND Wyroby_jubilerskie.Ilo��_na_stanie >= 2 
AND (SELECT Zestawienie_produkt�w_z_cenami.Cena_produktu FROM Zestawienie_produkt�w_z_cenami WHERE Wyroby_jubilerskie.ID_produktu = Zestawienie_produkt�w_z_cenami.ID_produktu) 
BETWEEN 250 AND 600;

--demonstracja danych
SELECT Wyroby_jubilerskie.ID_produktu, Wyroby_jubilerskie.Typ_produktu, Surowce.Pr�ba_z�ota, Surowce.Kolor, FORMAT(Zestawienie_produkt�w_z_cenami.Cena_produktu, 'N2'), 
Wyroby_jubilerskie.Ilo��_na_stanie
FROM Wyroby_jubilerskie
JOIN Zestawienie_produkt�w_z_cenami ON Wyroby_jubilerskie.ID_produktu = Zestawienie_produkt�w_z_cenami.ID_produktu
JOIN Surowce ON Wyroby_jubilerskie.ID_partii = Surowce.ID_partii;


----------------ZAPYTANIE 8----------------
--SCENARIUSZ: Firma znajduje si� w ci�kim okresie i jest zmuszona zwolni� cz�� pracownik�w. Zdecydowano, �e "na pierwszy ogie�" p�jd� pracownicy magazyn�w, poniewa� magazyny z surowcami
--maj� ich wi�cej ni� potrzeba. Nale�y dowiedzie� si�, kt�re to magazyny, jaka jest ich powierzchnia oraz ile surowc�w si� w nich znajduje, w celu okre�lenia optymalnej liczby magazynier�w.
--ZAPYTANIE W J�ZYKU NATURALNYM: Wy�wietl wszystkie magazyny przechowuj�ce surowce, ilo�� zatrudnionych w nich os�b, imiona i nazwiska tych pracownik�w, ilo�� i ��czn� wag� partii surowc�w w danych magazynach oraz powierzchni�.

WITH 
PracownicyMagazynu AS 
(SELECT Pracownicy.Numer_magazynu, COUNT(DISTINCT Pracownicy.PESEL) AS Liczba_pracownikow, 
STRING_AGG(CONCAT(Ludzie.Imi�, ' ', Ludzie.Nazwisko), ', ') AS Imiona_i_nazwiska_pracownikow FROM Pracownicy
JOIN Ludzie ON Pracownicy.ID_osoby = Ludzie.ID_osoby
GROUP BY Pracownicy.Numer_magazynu),

SurowceMagazynu AS 
(SELECT Surowce.Numer_magazynu, COUNT(DISTINCT Surowce.ID_partii) AS Ilo��_partii_surowc�w, SUM(Surowce.Waga_partii) AS ��czna_waga_surowc�w FROM Surowce GROUP BY Surowce.Numer_magazynu)

SELECT Magazyny.Numer_magazynu, PracownicyMagazynu.Liczba_pracownikow, PracownicyMagazynu.Imiona_i_nazwiska_pracownikow, SurowceMagazynu.Ilo��_partii_surowc�w, 
SurowceMagazynu.��czna_waga_surowc�w, Magazyny.Powierzchnia
FROM Magazyny
JOIN PracownicyMagazynu ON Magazyny.Numer_magazynu = PracownicyMagazynu.Numer_magazynu
JOIN SurowceMagazynu ON Magazyny.Numer_magazynu = SurowceMagazynu.Numer_magazynu;

--demonstracja danych
SELECT Magazyny.Numer_magazynu, Magazyny.Powierzchnia
FROM Magazyny
WHERE Magazyny.Typ_magazynu = 'magazyn z�ota'

SELECT Ludzie.Imi�, Ludzie.Nazwisko, Pracownicy.Numer_magazynu
FROM Pracownicy
JOIN Ludzie ON Pracownicy.ID_osoby = Ludzie.ID_osoby
WHERE Pracownicy.Stanowisko = 'magazynier'

SELECT Surowce.ID_partii, Surowce.Waga_partii, Surowce.Numer_magazynu
FROM Surowce


----------------ZAPYTANIE 9----------------
--SCENARIUSZ: Ca�kowity koszt zam�wienia nie jest bezpo�rednio przechowywany w bazie, poniewa� mo�na go wyliczy� na podstawie posiadanych informacji. Jest jednak niezb�dny,
--aby np. wystawia� faktury czy kontrolowa� p�atno�ci
--ZAPYTANIE W J�ZYKU NATURALNYM: Utw�rz zestawienie transakcji (ich numer�w) wraz z ca�kowit� kwot�, ��cznie z kosztami przesy�ki

SELECT Sprzeda�e.Numer_transakcji, FORMAT(SUM(Wyr�bSprzeda�.Zakupiona_ilo�� * Zestawienie_produkt�w_z_cenami.Cena_produktu) + ISNULL(Sprzeda�e.Koszty_wysy�ki, 0), 'N2') 
AS Warto��_transakcji
FROM Sprzeda�e
JOIN Wyr�bSprzeda� ON Sprzeda�e.Numer_transakcji = Wyr�bSprzeda�.Numer_transakcji
JOIN Zestawienie_produkt�w_z_cenami  ON Wyr�bSprzeda�.ID_produktu = Zestawienie_produkt�w_z_cenami .ID_produktu
GROUP BY Sprzeda�e.Numer_transakcji, Sprzeda�e.Koszty_wysy�ki;

--demonstracja danych
SELECT Sprzeda�e.Numer_transakcji, Wyr�bSprzeda�.Zakupiona_ilo��, FORMAT(Zestawienie_produkt�w_z_cenami.Cena_produktu, 'N2'), ISNULL(Sprzeda�e.Koszty_wysy�ki, 0) AS Koszty_wysy�ki
FROM Sprzeda�e
JOIN Wyr�bSprzeda� ON Sprzeda�e.Numer_transakcji = Wyr�bSprzeda�.Numer_transakcji
JOIN Zestawienie_produkt�w_z_cenami  ON Wyr�bSprzeda�.ID_produktu = Zestawienie_produkt�w_z_cenami .ID_produktu
GROUP BY Sprzeda�e.Numer_transakcji, Wyr�bSprzeda�.Zakupiona_ilo��, Zestawienie_produkt�w_z_cenami.Cena_produktu, Sprzeda�e.Koszty_wysy�ki;


SELECT DISTINCT Magazyny.Numer_magazynu,
    COUNT(DISTINCT Ludzie.ID_osoby) AS Ilo��_pracownik�w,
    STRING_AGG(CONCAT(Ludzie.Imi�, ' ', Ludzie.Nazwisko), ', ') AS Pracownicy,
    COUNT(DISTINCT Surowce.ID_partii) AS Ilo��_surowc�w,
    Magazyny.Powierzchnia
FROM Magazyny
JOIN 
    Surowce ON Magazyny.Numer_magazynu = Surowce.Numer_magazynu
JOIN 
    Wyroby_jubilerskie ON Magazyny.Numer_magazynu = Wyroby_jubilerskie.Numer_magazynu
JOIN 
    Ludzie ON Wyroby_jubilerskie.ID_produktu = Ludzie.ID_osoby
GROUP BY 
    Magazyny.Numer_magazynu, Magazyny.Powierzchnia;

