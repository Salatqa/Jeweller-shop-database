USE Warsztat_jubilerski;

--usuwanie kaskadowe 1
SELECT * FROM Sprzeda�e WHERE Data_sprzeda�y = '2024-01-09 08:58:59';
SELECT * FROM Wyr�bSprzeda�;

DELETE FROM Sprzeda�e WHERE Data_sprzeda�y = '2024-01-09 08:58:59';

SELECT * FROM Sprzeda�e WHERE Data_sprzeda�y = '2024-01-09 08:58:59';
SELECT * FROM Wyr�bSprzeda�

--usuwanie kaskadowe 2
SELECT * FROM Surowce WHERE ID_partii = 20;
SELECT * FROM Wyroby_jubilerskie;
SELECT * FROM PracownikWyr�b;

DELETE FROM Surowce WHERE ID_partii = 20;

SELECT * FROM Surowce WHERE ID_partii = 20;
SELECT * FROM Wyroby_jubilerskie;
SELECT * FROM PracownikWyr�b;


--updatowanie kaskadowe
SELECT * FROM Pracownicy WHERE PESEL='67089123456';
SELECT * FROM PracownikWyr�b;
SELECT * FROM PracownikStanowisko;


UPDATE Pracownicy
SET PESEL = '76089123456'
WHERE PESEL='67089123456';


SELECT * FROM Pracownicy WHERE PESEL='67089123456';
SELECT * FROM Pracownicy WHERE PESEL='76089123456';
SELECT * FROM PracownikWyr�b;
SELECT * FROM PracownikStanowisko;