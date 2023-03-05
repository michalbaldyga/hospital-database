USE SZPITAL

-- 1. Podczas operacji pacjentki Lucyny Zalewskiej dnia 2021-03-19 dosz�o do reakcji toksycznej po podaniu znieczulenia. 
-- Sprawd� jakie leki przyjmowa�a w tym czasie (wypisuj�c ich substancje czynne).

SELECT SUBSTANCJA_CZYNNA								-- Wybieramy substancje czynne na podstawie lek�w
	FROM LEKI
	WHERE NAZWA_LEKU IN
	(SELECT NAZWA_LEKU									-- Wybieramy wszystkie leki, kt�re pacjentka przyjmowa�a w dniu poddania si� operacji
		FROM LECZENIE
		WHERE DATA_ROZPOCZECIA_LECZENIA <= '2021-03-19' 
		AND DATA_ZAKONCZENIA_LECZENIA >= '2021-03-19' 
		AND ID_PACJENTA = 
		(SELECT ID_PACJENTA								-- Wybieramy id pacjenta, na podstawie id osoby
			FROM PACJENCI
			WHERE DANE_PACJENTA =
			(SELECT ID_OSOBY							-- Wybieramy id osoby, kt�ra nazywa si� Lucyna Zalewska
				FROM OSOBY
				WHERE IMIE='Lucyna' 
				AND	NAZWISKO='Zalewska')))


-- 2. W szpitalu zwolni�o si� kilka sal. Wypisz malej�co 5 najbardziej zape�nionych sal, w celu przeniesienia cz�ci pacjent�w.

SELECT TOP (5) ID_SALI, COUNT(ID_PACJENTA) AS ILOSC_OSOB	-- Wybieramy id sal i przypisujemy im akutaln� ilo�� os�b
	FROM PACJENCI
	GROUP BY ID_SALI										-- Grupujemy wiersze w tabeli PACJENCI, kt�re maj� to samo id sali
	ORDER BY COUNT(ID_PACJENTA) DESC						-- Sortujemy w porz�dku malej�cym


-- 3. Sprawd� czy w salach, w kt�rych przebywaj� osoby z chorob� covid-19 (icd_10 = U07.2), nie przebywaj� pacjenci, 
-- kt�rzy nie posiadaj� tej choroby (wypisuj�c identyfikatory sal i pacjent�w oraz icd_10 chor�b).

SELECT PACJENCI.ID_SALI, PACJENCI.ID_PACJENTA, CHOROBY.ICD_10	-- Wybieramy sale oraz pacjent�w wraz z ich chorobami, kt�rzy na nich przebywaj�
	FROM PACJENCI
	JOIN STAN_ZDROWIA ON PACJENCI.ID_PACJENTA=STAN_ZDROWIA.ID_PACJENTA	-- ��czymy tabel� STAN_ZDROWIA na podstawie id pacjenta
	JOIN CHOROBY ON STAN_ZDROWIA.ID_CHOROBY=CHOROBY.ID_CHOROBY			-- ��czymy tabel� CHOROBY na podstawie id choroby
	WHERE PACJENCI.ID_SALI IN
	(SELECT ID_SALI								-- Wybieramy id wszystkich sal, na kt�rych akutalnie przebywaj� osoby z dan� chorob�
		FROM PACJENCI
		WHERE ID_PACJENTA IN
		(SELECT ID_PACJENTA						-- Wybieramy id wszystkich pacjent�w, kt�rzy maj� dan� chorob�
			FROM STAN_ZDROWIA
			WHERE ID_CHOROBY IN
			(SELECT ID_CHOROBY					-- Wybieramy id choroby, kt�ra ma przyporz�dkowany numer ICD_10 = U07.2
				FROM CHOROBY
				WHERE ICD_10 = 'U07.2')))
	ORDER BY PACJENCI.ID_SALI ASC


-- 4. �wiatowa Organizacja Zdrowia zbiera informacje na temat najpopularniejszych chor�b w ubieg�ym roku. 
-- Sporz�d� zestawienie 5 najcz�stszych chor�b, kt�re by�y diagnozowane w tym okresie.

SELECT TOP(5) ICD_10, COUNT(ICD_10) AS ILOSC_PACJENTOW
	FROM RANKING_CHOROB							-- RANKING_CHOROB powsta� przez CREATE VIEW
	GROUP BY ICD_10								-- Grupujemy wszystkie wiersze, kt�re maj� tak� sam� warto�� pola icd 10
	ORDER BY COUNT(ICD_10) DESC					-- Zliczamy je i na podstawie ilo�ci wyst�pie� sortujemy


-- 5. G��wny ordynator oddzia�u kardiologii przechodzi na emerytur�. 
-- Znajd� lekarza (imi� i nazwisko) o tej specjalizacji z najwi�kszym do�wiadczeniem, aby m�g� on go zast�pi�.

SELECT IMIE, NAZWISKO							-- Wybieramy imi� i nazwisko lekarza, na podstawie id
	FROM OSOBY
	WHERE ID_OSOBY =
	(SELECT TOP(1) DANE_LEKARZA					-- Wybieramy dane lekarza, kt�ry jest kardiologiem i ma najwi�ksze do�wiadczenie
		FROM LEKARZE 
		WHERE SPECJALIZACJA = 'Kardiologia' 
		ORDER BY DOSWIADCZENIE DESC)


-- 6. Szpital chce da� premi� dla swoich najlepszych lekarzy. 
-- Sporz�d� zestawienie lekarzy, kt�rzy w ci�gu ostatniego roku wykonywali operacje o poziomie skomplikowania >= 9.

SELECT OSOBY.IMIE, OSOBY.NAZWISKO, OSOBY.PESEL
	FROM OSOBY
	WHERE ID_OSOBY IN
	(SELECT DANE_LEKARZA									-- Wybieramy dane lekarza, na podstawie jego id
		FROM LEKARZE
		WHERE ID_LEKARZA IN
		(SELECT ID_LEKARZA									-- Wybieramy id lekarzy, na podstawie id operacji, kt�re przeprowadzili
			FROM ZESPOLY_LEKARSKIE
			WHERE ID_OPERACJI IN
			(SELECT ID_OPERACJI								-- Wybieramy wszystkie id operacji, kt�re by�y przeprowadzone w 2021 r.
				FROM OPERACJE
				WHERE POZIOM_SKOMPLIKOWANIA >= 9 
				AND DATA_OPERACJI >= '01.01.2021'
				AND DATA_OPERACJI < '01.01.2022')))


-- 7. Szpital planuje z�o�y� zam�wienie na leki. Sporz�d� zestawienie 3 lek�w, 
-- na kt�re aktualnie jest najwi�ksze zapotrzebowanie (wypisuj�c nazw� leku oraz ilo�� pacjent�w go przyjmuj�cych).

SELECT TOP (3) NAZWA_LEKU, COUNT(ID_LECZENIA) AS ILOSC
	FROM LECZENIE
	WHERE DATA_ZAKONCZENIA_LECZENIA IS NULL			-- NULL oznacza, �e pacjent jeszcze przyjmuje lek
	GROUP BY NAZWA_LEKU								-- Grupujemy wszystkie wiersze, kt�re maj� tak� sam� warto�� pola NAZWA_LEKU
	ORDER BY COUNT(ID_LECZENIA) DESC				-- Zliczamy je i na podstawie ilo�ci wyst�pie� sortujemy


-- 8. Podczas operacji Billrotha dnia 2021-03-19 pope�niono b��d, przez kt�ry pacjent (Alexander Mazurek) m�g� zgin��. 
-- Sprawd� jaki zesp� lekarski wykonywa� operacj�.

SELECT LEKARZE.ID_LEKARZA, OSOBY.IMIE, OSOBY.NAZWISKO, OSOBY.PESEL, LEKARZE.SPECJALIZACJA  -- Na podstawie id lekarzy, identifikujemy ich
	FROM LEKARZE
	JOIN OSOBY ON LEKARZE.DANE_LEKARZA=OSOBY.ID_OSOBY		-- ��czymy tabel� OSOBY na podstawie id lekarza
	WHERE ID_LEKARZA IN
	(SELECT ID_LEKARZA										-- Wybieramy id lekarzy, kt�rzy przeprowadzili dan� operacj�
		FROM ZESPOLY_LEKARSKIE
		WHERE ID_OPERACJI =
		(SELECT ID_OPERACJI									-- Wybieramy id operacji na podstawie nazwy operacji, daty przeprowadzenia oraz id pacjenta
			FROM OPERACJE
			WHERE NAZWA_OPERACJI='operacja Billrotha'
			AND DATA_OPERACJI='2021-03-19'
			AND ID_PACJENTA =
			(SELECT ID_PACJENTA								-- Wybieramy id pacjenta na podstawie danych pacjenta
				FROM PACJENCI
				WHERE DANE_PACJENTA =
				(SELECT ID_OSOBY							-- Wybieramy id osoby Alexander Mazurek
					FROM OSOBY
					WHERE IMIE='Alexander' AND NAZWISKO='Mazurek'))))