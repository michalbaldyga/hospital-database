USE SZPITAL

-- 1. Podczas operacji pacjentki Lucyny Zalewskiej dnia 2021-03-19 dosz³o do reakcji toksycznej po podaniu znieczulenia. 
-- SprawdŸ jakie leki przyjmowa³a w tym czasie (wypisuj¹c ich substancje czynne).

SELECT SUBSTANCJA_CZYNNA								-- Wybieramy substancje czynne na podstawie leków
	FROM LEKI
	WHERE NAZWA_LEKU IN
	(SELECT NAZWA_LEKU									-- Wybieramy wszystkie leki, które pacjentka przyjmowa³a w dniu poddania siê operacji
		FROM LECZENIE
		WHERE DATA_ROZPOCZECIA_LECZENIA <= '2021-03-19' 
		AND DATA_ZAKONCZENIA_LECZENIA >= '2021-03-19' 
		AND ID_PACJENTA = 
		(SELECT ID_PACJENTA								-- Wybieramy id pacjenta, na podstawie id osoby
			FROM PACJENCI
			WHERE DANE_PACJENTA =
			(SELECT ID_OSOBY							-- Wybieramy id osoby, która nazywa siê Lucyna Zalewska
				FROM OSOBY
				WHERE IMIE='Lucyna' 
				AND	NAZWISKO='Zalewska')))


-- 2. W szpitalu zwolni³o siê kilka sal. Wypisz malej¹co 5 najbardziej zape³nionych sal, w celu przeniesienia czêœci pacjentów.

SELECT TOP (5) ID_SALI, COUNT(ID_PACJENTA) AS ILOSC_OSOB	-- Wybieramy id sal i przypisujemy im akutaln¹ iloœæ osób
	FROM PACJENCI
	GROUP BY ID_SALI										-- Grupujemy wiersze w tabeli PACJENCI, które maj¹ to samo id sali
	ORDER BY COUNT(ID_PACJENTA) DESC						-- Sortujemy w porz¹dku malej¹cym


-- 3. SprawdŸ czy w salach, w których przebywaj¹ osoby z chorob¹ covid-19 (icd_10 = U07.2), nie przebywaj¹ pacjenci, 
-- którzy nie posiadaj¹ tej choroby (wypisuj¹c identyfikatory sal i pacjentów oraz icd_10 chorób).

SELECT PACJENCI.ID_SALI, PACJENCI.ID_PACJENTA, CHOROBY.ICD_10	-- Wybieramy sale oraz pacjentów wraz z ich chorobami, którzy na nich przebywaj¹
	FROM PACJENCI
	JOIN STAN_ZDROWIA ON PACJENCI.ID_PACJENTA=STAN_ZDROWIA.ID_PACJENTA	-- £¹czymy tabelê STAN_ZDROWIA na podstawie id pacjenta
	JOIN CHOROBY ON STAN_ZDROWIA.ID_CHOROBY=CHOROBY.ID_CHOROBY			-- £¹czymy tabelê CHOROBY na podstawie id choroby
	WHERE PACJENCI.ID_SALI IN
	(SELECT ID_SALI								-- Wybieramy id wszystkich sal, na których akutalnie przebywaj¹ osoby z dan¹ chorob¹
		FROM PACJENCI
		WHERE ID_PACJENTA IN
		(SELECT ID_PACJENTA						-- Wybieramy id wszystkich pacjentów, którzy maj¹ dan¹ chorobê
			FROM STAN_ZDROWIA
			WHERE ID_CHOROBY IN
			(SELECT ID_CHOROBY					-- Wybieramy id choroby, która ma przyporz¹dkowany numer ICD_10 = U07.2
				FROM CHOROBY
				WHERE ICD_10 = 'U07.2')))
	ORDER BY PACJENCI.ID_SALI ASC


-- 4. Œwiatowa Organizacja Zdrowia zbiera informacje na temat najpopularniejszych chorób w ubieg³ym roku. 
-- Sporz¹dŸ zestawienie 5 najczêstszych chorób, które by³y diagnozowane w tym okresie.

SELECT TOP(5) ICD_10, COUNT(ICD_10) AS ILOSC_PACJENTOW
	FROM RANKING_CHOROB							-- RANKING_CHOROB powsta³ przez CREATE VIEW
	GROUP BY ICD_10								-- Grupujemy wszystkie wiersze, które maj¹ tak¹ sam¹ wartoœæ pola icd 10
	ORDER BY COUNT(ICD_10) DESC					-- Zliczamy je i na podstawie iloœci wyst¹pieñ sortujemy


-- 5. G³ówny ordynator oddzia³u kardiologii przechodzi na emeryturê. 
-- ZnajdŸ lekarza (imiê i nazwisko) o tej specjalizacji z najwiêkszym doœwiadczeniem, aby móg³ on go zast¹piæ.

SELECT IMIE, NAZWISKO							-- Wybieramy imiê i nazwisko lekarza, na podstawie id
	FROM OSOBY
	WHERE ID_OSOBY =
	(SELECT TOP(1) DANE_LEKARZA					-- Wybieramy dane lekarza, który jest kardiologiem i ma najwiêksze doœwiadczenie
		FROM LEKARZE 
		WHERE SPECJALIZACJA = 'Kardiologia' 
		ORDER BY DOSWIADCZENIE DESC)


-- 6. Szpital chce daæ premiê dla swoich najlepszych lekarzy. 
-- Sporz¹dŸ zestawienie lekarzy, którzy w ci¹gu ostatniego roku wykonywali operacje o poziomie skomplikowania >= 9.

SELECT OSOBY.IMIE, OSOBY.NAZWISKO, OSOBY.PESEL
	FROM OSOBY
	WHERE ID_OSOBY IN
	(SELECT DANE_LEKARZA									-- Wybieramy dane lekarza, na podstawie jego id
		FROM LEKARZE
		WHERE ID_LEKARZA IN
		(SELECT ID_LEKARZA									-- Wybieramy id lekarzy, na podstawie id operacji, które przeprowadzili
			FROM ZESPOLY_LEKARSKIE
			WHERE ID_OPERACJI IN
			(SELECT ID_OPERACJI								-- Wybieramy wszystkie id operacji, które by³y przeprowadzone w 2021 r.
				FROM OPERACJE
				WHERE POZIOM_SKOMPLIKOWANIA >= 9 
				AND DATA_OPERACJI >= '01.01.2021'
				AND DATA_OPERACJI < '01.01.2022')))


-- 7. Szpital planuje z³o¿yæ zamówienie na leki. Sporz¹dŸ zestawienie 3 leków, 
-- na które aktualnie jest najwiêksze zapotrzebowanie (wypisuj¹c nazwê leku oraz iloœæ pacjentów go przyjmuj¹cych).

SELECT TOP (3) NAZWA_LEKU, COUNT(ID_LECZENIA) AS ILOSC
	FROM LECZENIE
	WHERE DATA_ZAKONCZENIA_LECZENIA IS NULL			-- NULL oznacza, ¿e pacjent jeszcze przyjmuje lek
	GROUP BY NAZWA_LEKU								-- Grupujemy wszystkie wiersze, które maj¹ tak¹ sam¹ wartoœæ pola NAZWA_LEKU
	ORDER BY COUNT(ID_LECZENIA) DESC				-- Zliczamy je i na podstawie iloœci wyst¹pieñ sortujemy


-- 8. Podczas operacji Billrotha dnia 2021-03-19 pope³niono b³¹d, przez który pacjent (Alexander Mazurek) móg³ zgin¹æ. 
-- SprawdŸ jaki zespó³ lekarski wykonywa³ operacjê.

SELECT LEKARZE.ID_LEKARZA, OSOBY.IMIE, OSOBY.NAZWISKO, OSOBY.PESEL, LEKARZE.SPECJALIZACJA  -- Na podstawie id lekarzy, identifikujemy ich
	FROM LEKARZE
	JOIN OSOBY ON LEKARZE.DANE_LEKARZA=OSOBY.ID_OSOBY		-- £¹czymy tabelê OSOBY na podstawie id lekarza
	WHERE ID_LEKARZA IN
	(SELECT ID_LEKARZA										-- Wybieramy id lekarzy, którzy przeprowadzili dan¹ operacjê
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