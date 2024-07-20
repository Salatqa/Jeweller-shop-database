use Warsztat_jubilerski

----------------ZAPYTANIE 1----------------
--SCENARIUSZ: W³aœciciel chce daæ podwy¿kê 3 pracownikom (rzemieœlnikom), którzy pracuj¹ w warsztacie d³u¿ej ni¿ rok oraz wytworzyli najwiêcej produktów
--ZAPYTANIE W JÊZYKU NATURALNYM: Utwórz zestawienie 3 pracowników, których okres zatrudnienia jest wiêkszy równy rok (12 miesiêcy) i wytworzyli oni najwiêcej produktów, 
--posortuj malej¹co po liczbie wytworzonych produktów

SELECT TOP 3 Pracownicy.PESEL, Ludzie.Imiê, Ludzie.Nazwisko, Pracownicy.Stanowisko, Pracownicy.Data_zatrudnienia, COUNT(PracownikWyrób.ID_produktu) AS Liczba_Produktow
FROM Pracownicy
JOIN PracownikWyrób ON Pracownicy.PESEL = PracownikWyrób.ID_pracownika
JOIN Ludzie ON Pracownicy.ID_osoby = Ludzie.ID_osoby
WHERE DATEDIFF(month, Pracownicy.Data_zatrudnienia, GETDATE()) >= 12 AND Pracownicy.Zatrudniony='tak'
GROUP BY Pracownicy.PESEL, Ludzie.Imiê, Ludzie.Nazwisko, Pracownicy.Stanowisko, Pracownicy.Data_zatrudnienia
ORDER BY Liczba_Produktow DESC;

--demonstracja danych
SELECT Pracownicy.PESEL, Ludzie.Imiê, Ludzie.Nazwisko, Pracownicy.Stanowisko, Pracownicy.Data_zatrudnienia, COUNT(PracownikWyrób.ID_produktu) AS Liczba_Produktow
FROM Pracownicy
JOIN PracownikWyrób ON Pracownicy.PESEL = PracownikWyrób.ID_pracownika
JOIN Ludzie ON Pracownicy.ID_osoby = Ludzie.ID_osoby
GROUP BY Pracownicy.PESEL, Ludzie.Imiê, Ludzie.Nazwisko, Pracownicy.Stanowisko, Pracownicy.Data_zatrudnienia
ORDER BY Data_zatrudnienia DESC;


----------------ZAPYTANIE 2----------------
--SCENARIUSZ: W³aœcicielowi przychodzi bardzo du¿y rachunek za pr¹d, wiêc chcia³by dowiedzieæ siê, który z pracowników zu¿ywa go najwiêcej.
--ZAPYTANIE W JÊZYKU NATURALNYM: Utwórz zestawienie rzemieœlinków, którzy wytwarzaj¹c produkty wykorzystuj¹ najwiêcej pr¹du i posortuj ich w kolejnoœci malej¹cej.

DROP VIEW IF EXISTS Zu¿yciePr¹duPracowników;

GO
CREATE VIEW Zu¿yciePr¹duPracowników AS
SELECT Pracownicy.PESEL, Ludzie.Imiê, Ludzie.Nazwisko, 
FORMAT(SUM(DATEDIFF(minute, PracownikStanowisko.Data_rozpoczêcia_zajmowania_stanowiska, PracownikStanowisko.Data_zakoñczenia_zajmowania_stanowiska) * Stanowiska.Zu¿ycie_pr¹du/60), 'N2') 
AS Zu¿yty_pr¹d --FORMAT pozwala wyœwietliæ tylko z dwoma cyframi po przecinku
FROM Pracownicy
JOIN PracownikStanowisko ON Pracownicy.PESEL = PracownikStanowisko.ID_pracownika
JOIN Stanowiska ON PracownikStanowisko.Numer_stanowiska = Stanowiska.Numer_stanowiska
JOIN Ludzie ON Pracownicy.ID_osoby = Ludzie.ID_osoby
GROUP BY Pracownicy.PESEL, Ludzie.Imiê, Ludzie.Nazwisko;
GO

SELECT * FROM Zu¿yciePr¹duPracowników
ORDER BY Zu¿yty_pr¹d DESC;

--demonstracja danych
SELECT Pracownicy.PESEL, Ludzie.Imiê, Ludzie.Nazwisko, PracownikStanowisko.Data_rozpoczêcia_zajmowania_stanowiska, PracownikStanowisko.Data_zakoñczenia_zajmowania_stanowiska, 
Stanowiska.Zu¿ycie_pr¹du, FORMAT(SUM(DATEDIFF(minute, PracownikStanowisko.Data_rozpoczêcia_zajmowania_stanowiska, PracownikStanowisko.Data_zakoñczenia_zajmowania_stanowiska)), 'N2') 
AS Czas_zajmowania_stanowiska_w_minutach
FROM Pracownicy
JOIN PracownikStanowisko ON Pracownicy.PESEL = PracownikStanowisko.ID_pracownika
JOIN Stanowiska ON PracownikStanowisko.Numer_stanowiska = Stanowiska.Numer_stanowiska
JOIN Ludzie ON Pracownicy.ID_osoby = Ludzie.ID_osoby
GROUP BY Pracownicy.PESEL, Ludzie.Imiê, Ludzie.Nazwisko, PracownikStanowisko.Data_rozpoczêcia_zajmowania_stanowiska, PracownikStanowisko.Data_zakoñczenia_zajmowania_stanowiska, 
Stanowiska.Zu¿ycie_pr¹du;


----------------ZAPYTANIE 3----------------
--SCENARIUSZ: Cena produktu nie jest przechowywana w tabeli "Wyroby_jubilerskie", poniewa¿ mo¿e zostaæ obliczona na podstawie innych danych, jakimi dysponuje baza. Cena jest jednak 
--niezbêdnym elementem, aby wiedzieæ za ile sprzedawaæ dane produkty, tworzymy widok, aby móc póŸniej korzystaæ z wyliczonej ceny, a nie wyliczaæ j¹ osobno za ka¿dym razem
--ZAPYTANIE W JÊZYKU NATURALNYM: Utwórz widok z zestawieniem produktów (ich id i typów) wraz z wyliczon¹ cen¹, uwzglêdniaj¹c koszt materia³ów zu¿ytych do ich produkcji, czas wytwarzania produktu 
-- i wynagrodzenie praciwników, którzy wytwarzali dany produkt

DROP VIEW IF EXISTS Zestawienie_produktów_z_cenami;

GO 
CREATE VIEW Zestawienie_produktów_z_cenami AS
SELECT Wyroby_jubilerskie.ID_produktu, Wyroby_jubilerskie.Typ_produktu, ROUND(SUM((PracownikWyrób.Czas_wytwrzania_produktu_przez_pracownika * Pracownicy.Wynagrodzenie/(22*8)) 
	--dzielimy na 22, bo 22 to œrednia iloœæ dni pracy w miesi¹cu oraz przez 8, bo pracownicy pracuj¹ po 8h; uzyskujemy stawkê godzinow¹
    + (Wyroby_jubilerskie.Waga_produktu * Surowce.Wartoœæ_pieniê¿na/1000)),2) AS Cena_produktu --dzielimy przez tysi¹c, aby uzyskaæ cenê za gram
FROM Wyroby_jubilerskie
JOIN PracownikWyrób ON Wyroby_jubilerskie.ID_produktu = PracownikWyrób.ID_produktu
JOIN Pracownicy ON PracownikWyrób.ID_pracownika = Pracownicy.PESEL
JOIN Surowce ON Wyroby_jubilerskie.ID_partii = Surowce.ID_partii
GROUP BY Wyroby_jubilerskie.ID_produktu, Wyroby_jubilerskie.Typ_produktu;
GO

SELECT * FROM Zestawienie_produktów_z_cenami 
ORDER BY ID_produktu;

--demonstracja danych
SELECT Wyroby_jubilerskie.ID_produktu, Wyroby_jubilerskie.Typ_produktu, PracownikWyrób.Czas_wytwrzania_produktu_przez_pracownika, 
	Pracownicy.PESEL, FORMAT(Pracownicy.Wynagrodzenie/(22*8),'N2') AS Stawka_godzinowa_pracownika
FROM Wyroby_jubilerskie
JOIN PracownikWyrób ON Wyroby_jubilerskie.ID_produktu = PracownikWyrób.ID_produktu
JOIN Pracownicy ON PracownikWyrób.ID_pracownika = Pracownicy.PESEL
GROUP BY Wyroby_jubilerskie.ID_produktu, Wyroby_jubilerskie.Typ_produktu, PracownikWyrób.Czas_wytwrzania_produktu_przez_pracownika, Pracownicy.PESEL, Pracownicy.Wynagrodzenie, Wyroby_jubilerskie.Waga_produktu
ORDER BY ID_produktu;

SELECT Wyroby_jubilerskie.ID_produktu, Wyroby_jubilerskie.Typ_produktu, Wyroby_jubilerskie.Waga_produktu, FORMAT(Surowce.Wartoœæ_pieniê¿na/1000,'N2') AS Cena_surowca_za_gram
FROM Wyroby_jubilerskie
JOIN PracownikWyrób ON Wyroby_jubilerskie.ID_produktu = PracownikWyrób.ID_produktu
JOIN Surowce ON Wyroby_jubilerskie.ID_partii = Surowce.ID_partii
GROUP BY Wyroby_jubilerskie.ID_produktu, Wyroby_jubilerskie.Typ_produktu, Wyroby_jubilerskie.Waga_produktu, Surowce.Wartoœæ_pieniê¿na
ORDER BY ID_produktu;


----------------ZAPYTANIE 4----------------
--SCENARIUSZ: Rzemieœlnik ma za zadanie zaprojektowaæ nowy model kolczyków. Wie, ¿e chce je wykonaæ z czarnego z³ota próby 375, natomiast nie wie jeszcze ile surowca zu¿yje. 
--Chcemy wiêc obliczyæ ile gramów takiego z³ota dodatkowo zamówiæ, tak, aby starczy³o na kilka prototypów tego modelu. Wagê kolczyków szacujemy na podstawie wag wszystkich kolczyków w ofercie 
--o tych samych parametrach, aby obliczyæ przybli¿one zapotrzebowanie na surowiec i przyjmujemy, ¿e kupujemy z³oto na 10 par kolczyków o takiej œredniej wadze (aby wykonaæ 
--kilka prototypów plus mieæ zapas).
--ZAPYTANIE W JÊZYKU NATURALNYM: Wybierz wagi wszystkich kolczyków z czarnego z³ota o próbie 375 i oblicz ich œredni¹.

SELECT 10 * AVG(Waga_produktu) AS Potrzebna_waga_surowca
FROM (
    SELECT Wyroby_jubilerskie.Waga_produktu
    FROM Wyroby_jubilerskie
    JOIN Surowce ON Wyroby_jubilerskie.ID_partii = Surowce.ID_partii
    WHERE Wyroby_jubilerskie.Typ_produktu = 'kolczyki'
    AND Surowce.Próba_z³ota = '375'
    AND Surowce.Kolor = 'czarny'
) AS Szukana_waga;

--demonstracja danych
SELECT Wyroby_jubilerskie.ID_produktu, Wyroby_jubilerskie.Waga_produktu, Wyroby_jubilerskie.Typ_produktu, Surowce.Próba_z³ota, Surowce.Kolor
FROM Wyroby_jubilerskie
JOIN Surowce ON Wyroby_jubilerskie.ID_partii = Surowce.ID_partii
WHERE Wyroby_jubilerskie.Typ_produktu = 'kolczyki'
AND Surowce.Próba_z³ota = '375'
AND Surowce.Kolor = 'czarny';


----------------ZAPYTANIE 5----------------
--SCENARIUSZ: W³aœciciel chce otworzyæ nowy punkt sprzeda¿y stacjonarnej w jak najbardziej op³acalnej lokalizacji, dlatego 
--musi sprawdziæ z jakich miejscowoœci pochodzi najwiêcej zamówieñ w ci¹gu ostatniego roku
--ZAPYTANIE W JÊZYKU NATURALNYM: Utwórz zestawienie miejscowoœci wed³ug iloœci zamówieñ i posortuj te miejscowoœci malej¹co na podstawie iloœci zamówieñ

SELECT Adresy.Miejscowoœæ, COUNT(Sprzeda¿e.Numer_transakcji) AS Iloœæ_zamówieñ, SUM(WyróbSprzeda¿.Zakupiona_iloœæ) AS Iloœæ_sprzedanych_produktów
FROM Sprzeda¿e
JOIN WyróbSprzeda¿ ON Sprzeda¿e.Numer_transakcji = WyróbSprzeda¿.Numer_transakcji
JOIN Adresy ON Sprzeda¿e.ID_adresu = Adresy.ID_adresu
WHERE DATEDIFF(month, Sprzeda¿e.Data_sprzeda¿y, GETDATE())<=12
GROUP BY Adresy.Miejscowoœæ
ORDER BY Iloœæ_sprzedanych_produktów DESC;

--demonstracja danych
SELECT Adresy.Miejscowoœæ, Sprzeda¿e.Numer_transakcji, WyróbSprzeda¿.Zakupiona_iloœæ 
FROM Sprzeda¿e
JOIN WyróbSprzeda¿ ON Sprzeda¿e.Numer_transakcji = WyróbSprzeda¿.Numer_transakcji
JOIN Adresy ON Sprzeda¿e.ID_adresu = Adresy.ID_adresu;


----------------ZAPYTANIE 6----------------
--SCENARIUSZ: Dostaliœmy du¿¹ dostawê ¿ó³tego z³ota. Chcemy znaleŸæ w bazie klientów, którzy w przesz³oœci kupili bi¿uteriê z ¿ó³tego z³ota, aby wys³aæ im mailowo reklamê 
--i zachêciæ do zakupu.
--ZAPYTANIE W JÊZYKU NATURALNYM: Wyœwietl imiona, nazwiska oraz adresy e-mail osób, które kupi³y kiedyœ bi¿uteriê z ¿ó³tego z³ota.

SELECT DISTINCT --DISTINCT po to, ¿eby siê nie powtarza³y osoby (jeœli kilka razy zamawia³y produkty)
    Ludzie.Imiê,Ludzie.Nazwisko, Ludzie.Adres_email
FROM Ludzie
JOIN Sprzeda¿e ON Ludzie.ID_osoby = Sprzeda¿e.ID_osoby
JOIN WyróbSprzeda¿ ON Sprzeda¿e.Numer_transakcji = WyróbSprzeda¿.Numer_transakcji
JOIN Wyroby_jubilerskie ON WyróbSprzeda¿.ID_produktu = Wyroby_jubilerskie.ID_produktu
JOIN Surowce ON Wyroby_jubilerskie.ID_partii = Surowce.ID_partii
WHERE Surowce.Kolor = '¿ó³ty';

--demonstracja danych
SELECT DISTINCT Ludzie.Imiê,Ludzie.Nazwisko, Surowce.Kolor
FROM Ludzie
JOIN Sprzeda¿e ON Ludzie.ID_osoby = Sprzeda¿e.ID_osoby
JOIN WyróbSprzeda¿ ON Sprzeda¿e.Numer_transakcji = WyróbSprzeda¿.Numer_transakcji
JOIN Wyroby_jubilerskie ON WyróbSprzeda¿.ID_produktu = Wyroby_jubilerskie.ID_produktu
JOIN Surowce ON Wyroby_jubilerskie.ID_partii = Surowce.ID_partii


----------------ZAPYTANIE 7----------------
--SCENARIUSZ: Klient szuka prezentu dla córek bliŸniaczek. Potrzebuje dwóch identycznych pierœcionków i chce, aby próba z³ota wynosi³a 375, 500 lub 585. Bud¿et jakim dysponuje
--na pojedynczy wyrób to miêdzy 250 a 600 z³, kolor jest mu obojêtny. Chcemy pokazaæ mu dostêpne opcje.
--ZAPYTANIE W JÊZYKU NATURALNYM: Wyœwietl wszystkie pierœcionki o próbie 375, 500 i 585, których s¹ co najmniej dwie sztuki na stanie, a ich przedzia³ cenowy to 250-600 z³ w³¹cznie.

SELECT Wyroby_jubilerskie.ID_produktu, Wyroby_jubilerskie.Typ_produktu, Surowce.Próba_z³ota,Surowce.Kolor, FORMAT((SELECT Zestawienie_produktów_z_cenami.Cena_produktu 
FROM Zestawienie_produktów_z_cenami WHERE Wyroby_jubilerskie.ID_produktu = Zestawienie_produktów_z_cenami.ID_produktu), 'N2') AS Cena_produktu, Wyroby_jubilerskie.Iloœæ_na_stanie
FROM Wyroby_jubilerskie
JOIN Surowce ON Wyroby_jubilerskie.ID_partii = Surowce.ID_partii
WHERE Wyroby_jubilerskie.Typ_produktu = 'pierœcionek' AND Surowce.Próba_z³ota IN ('375', '500', '585') AND Wyroby_jubilerskie.Iloœæ_na_stanie >= 2 
AND (SELECT Zestawienie_produktów_z_cenami.Cena_produktu FROM Zestawienie_produktów_z_cenami WHERE Wyroby_jubilerskie.ID_produktu = Zestawienie_produktów_z_cenami.ID_produktu) 
BETWEEN 250 AND 600;

--demonstracja danych
SELECT Wyroby_jubilerskie.ID_produktu, Wyroby_jubilerskie.Typ_produktu, Surowce.Próba_z³ota, Surowce.Kolor, FORMAT(Zestawienie_produktów_z_cenami.Cena_produktu, 'N2'), 
Wyroby_jubilerskie.Iloœæ_na_stanie
FROM Wyroby_jubilerskie
JOIN Zestawienie_produktów_z_cenami ON Wyroby_jubilerskie.ID_produktu = Zestawienie_produktów_z_cenami.ID_produktu
JOIN Surowce ON Wyroby_jubilerskie.ID_partii = Surowce.ID_partii;


----------------ZAPYTANIE 8----------------
--SCENARIUSZ: Firma znajduje siê w ciê¿kim okresie i jest zmuszona zwolniæ czêœæ pracowników. Zdecydowano, ¿e "na pierwszy ogieñ" pójd¹ pracownicy magazynów, poniewa¿ magazyny z surowcami
--maj¹ ich wiêcej ni¿ potrzeba. Nale¿y dowiedzieæ siê, które to magazyny, jaka jest ich powierzchnia oraz ile surowców siê w nich znajduje, w celu okreœlenia optymalnej liczby magazynierów.
--ZAPYTANIE W JÊZYKU NATURALNYM: Wyœwietl wszystkie magazyny przechowuj¹ce surowce, iloœæ zatrudnionych w nich osób, imiona i nazwiska tych pracowników, iloœæ i ³¹czn¹ wagê partii surowców w danych magazynach oraz powierzchniê.

WITH 
PracownicyMagazynu AS 
(SELECT Pracownicy.Numer_magazynu, COUNT(DISTINCT Pracownicy.PESEL) AS Liczba_pracownikow, 
STRING_AGG(CONCAT(Ludzie.Imiê, ' ', Ludzie.Nazwisko), ', ') AS Imiona_i_nazwiska_pracownikow FROM Pracownicy
JOIN Ludzie ON Pracownicy.ID_osoby = Ludzie.ID_osoby
GROUP BY Pracownicy.Numer_magazynu),

SurowceMagazynu AS 
(SELECT Surowce.Numer_magazynu, COUNT(DISTINCT Surowce.ID_partii) AS Iloœæ_partii_surowców, SUM(Surowce.Waga_partii) AS £¹czna_waga_surowców FROM Surowce GROUP BY Surowce.Numer_magazynu)

SELECT Magazyny.Numer_magazynu, PracownicyMagazynu.Liczba_pracownikow, PracownicyMagazynu.Imiona_i_nazwiska_pracownikow, SurowceMagazynu.Iloœæ_partii_surowców, 
SurowceMagazynu.£¹czna_waga_surowców, Magazyny.Powierzchnia
FROM Magazyny
JOIN PracownicyMagazynu ON Magazyny.Numer_magazynu = PracownicyMagazynu.Numer_magazynu
JOIN SurowceMagazynu ON Magazyny.Numer_magazynu = SurowceMagazynu.Numer_magazynu;

--demonstracja danych
SELECT Magazyny.Numer_magazynu, Magazyny.Powierzchnia
FROM Magazyny
WHERE Magazyny.Typ_magazynu = 'magazyn z³ota'

SELECT Ludzie.Imiê, Ludzie.Nazwisko, Pracownicy.Numer_magazynu
FROM Pracownicy
JOIN Ludzie ON Pracownicy.ID_osoby = Ludzie.ID_osoby
WHERE Pracownicy.Stanowisko = 'magazynier'

SELECT Surowce.ID_partii, Surowce.Waga_partii, Surowce.Numer_magazynu
FROM Surowce


----------------ZAPYTANIE 9----------------
--SCENARIUSZ: Ca³kowity koszt zamówienia nie jest bezpoœrednio przechowywany w bazie, poniewa¿ mo¿na go wyliczyæ na podstawie posiadanych informacji. Jest jednak niezbêdny,
--aby np. wystawiaæ faktury czy kontrolowaæ p³atnoœci
--ZAPYTANIE W JÊZYKU NATURALNYM: Utwórz zestawienie transakcji (ich numerów) wraz z ca³kowit¹ kwot¹, ³¹cznie z kosztami przesy³ki

SELECT Sprzeda¿e.Numer_transakcji, FORMAT(SUM(WyróbSprzeda¿.Zakupiona_iloœæ * Zestawienie_produktów_z_cenami.Cena_produktu) + ISNULL(Sprzeda¿e.Koszty_wysy³ki, 0), 'N2') 
AS Wartoœæ_transakcji
FROM Sprzeda¿e
JOIN WyróbSprzeda¿ ON Sprzeda¿e.Numer_transakcji = WyróbSprzeda¿.Numer_transakcji
JOIN Zestawienie_produktów_z_cenami  ON WyróbSprzeda¿.ID_produktu = Zestawienie_produktów_z_cenami .ID_produktu
GROUP BY Sprzeda¿e.Numer_transakcji, Sprzeda¿e.Koszty_wysy³ki;

--demonstracja danych
SELECT Sprzeda¿e.Numer_transakcji, WyróbSprzeda¿.Zakupiona_iloœæ, FORMAT(Zestawienie_produktów_z_cenami.Cena_produktu, 'N2'), ISNULL(Sprzeda¿e.Koszty_wysy³ki, 0) AS Koszty_wysy³ki
FROM Sprzeda¿e
JOIN WyróbSprzeda¿ ON Sprzeda¿e.Numer_transakcji = WyróbSprzeda¿.Numer_transakcji
JOIN Zestawienie_produktów_z_cenami  ON WyróbSprzeda¿.ID_produktu = Zestawienie_produktów_z_cenami .ID_produktu
GROUP BY Sprzeda¿e.Numer_transakcji, WyróbSprzeda¿.Zakupiona_iloœæ, Zestawienie_produktów_z_cenami.Cena_produktu, Sprzeda¿e.Koszty_wysy³ki;


SELECT DISTINCT Magazyny.Numer_magazynu,
    COUNT(DISTINCT Ludzie.ID_osoby) AS Iloœæ_pracowników,
    STRING_AGG(CONCAT(Ludzie.Imiê, ' ', Ludzie.Nazwisko), ', ') AS Pracownicy,
    COUNT(DISTINCT Surowce.ID_partii) AS Iloœæ_surowców,
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

