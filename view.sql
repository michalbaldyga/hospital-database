CREATE VIEW [RANKING_CHOROB] AS
	SELECT STAN_ZDROWIA.ID_CHOROBY, STAN_ZDROWIA.ID_PACJENTA, CHOROBY.ICD_10
	FROM STAN_ZDROWIA
	JOIN CHOROBY ON STAN_ZDROWIA.ID_CHOROBY=CHOROBY.ID_CHOROBY
	WHERE DATA_ROZPOZNANIA_CHOROBY >= '01.01.2021' 
	AND DATA_ROZPOZNANIA_CHOROBY < '01.01.2022'