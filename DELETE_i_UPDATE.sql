USE Warsztat_jubilerski;

--usuwanie kaskadowe 1
SELECT * FROM Sprzedaże WHERE Data_sprzedaży = '2024-01-09 08:58:59';
SELECT * FROM WyróbSprzedaż;

DELETE FROM Sprzedaże WHERE Data_sprzedaży = '2024-01-09 08:58:59';

SELECT * FROM Sprzedaże WHERE Data_sprzedaży = '2024-01-09 08:58:59';
SELECT * FROM WyróbSprzedaż

--usuwanie kaskadowe 2
SELECT * FROM Surowce WHERE ID_partii = 20;
SELECT * FROM Wyroby_jubilerskie;
SELECT * FROM PracownikWyrób;

DELETE FROM Surowce WHERE ID_partii = 20;

SELECT * FROM Surowce WHERE ID_partii = 20;
SELECT * FROM Wyroby_jubilerskie;
SELECT * FROM PracownikWyrób;


--updatowanie kaskadowe
SELECT * FROM Pracownicy WHERE PESEL='67089123456';
SELECT * FROM PracownikWyrób;
SELECT * FROM PracownikStanowisko;


UPDATE Pracownicy
SET PESEL = '76089123456'
WHERE PESEL='67089123456';


SELECT * FROM Pracownicy WHERE PESEL='67089123456';
SELECT * FROM Pracownicy WHERE PESEL='76089123456';
SELECT * FROM PracownikWyrób;
SELECT * FROM PracownikStanowisko;