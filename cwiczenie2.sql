CREATE EXTENSION postgis;

-- 1. Zapoznaj się dokumentacją dotyczącą plików shapefile: https://en.wikipedia.org/wiki/Shapefile
--DONE

-- 2. Pobierz przykładowe dane dotyczące Alaski (po rozpakowaniu korzystaj z folderu shapefiles):
-- https://qgis.org/downloads/data/qgis_sample_data.zip
--DONE

-- 3. Zaimportuj pliki shapefile do bazy danych wykorzystując wtyczkę PostGIS DBF Loader.
-- DONE

-- 4. Wyznacz liczbę budynków (tabela: popp, atrybut: f_codedesc, reprezentowane, jako punkty)
-- położonych w odległości mniejszej niż 1000 m od głównych rzek. Budynki spełniające to
-- kryterium zapisz do osobnej tabeli tableB.


CREATE TABLE tableB(like popp);

INSERT INTO tableB
SELECT * FROM popp
WHERE ST_Distance(geom, (SELECT ST_Collect(geom) FROM majrivers)) < 1000 AND f_codedesc = 'Building';

SELECT * FROM tableB;

DROP TABLE IF EXISTS tableB;

-- 5. Utwórz tabelę o nazwie airportsNew. Z tabeli airports do zaimportuj nazwy lotnisk, ich
-- geometrię, a także atrybut elev, reprezentujący wysokość n.p.m.

CREATE TABLE airportsNew(name varchar(50), geom geometry, elev numeric);

INSERT INTO airportsNew
SELECT name, geom, elev FROM airports;

SELECT * FROM airportsNew;

DROP TABLE IF EXISTS airportsNew;

-- a) Znajdź lotnisko, które położone jest najbardziej na zachód i najbardziej na wschód.
--ZACHÓD
SELECT name, elev, ST_Y(geom) AS dlugosc_geograficzna 
FROM airportsNew 
ORDER BY ST_X(geom) 
LIMIT 1;

--WSCHÓD
SELECT name, elev, ST_Y(geom) AS dlugosc_geograficzna 
FROM airportsNew 
ORDER BY ST_X(geom) 
DESC LIMIT 1; 


-- b) Do tabeli airportsNew dodaj nowy obiekt - lotnisko, które położone jest w punkcie
-- środkowym drogi pomiędzy lotniskami znalezionymi w punkcie a. Lotnisko nazwij airportB.
-- Wysokość n.p.m. przyjmij dowolną.



INSERT INTO airportsNew (name, geom, elev)
VALUES
	('airportB',
	(SELECT * FROM ST_LineInterpolatePoint
	 ( 
		(
			SELECT * FROM ST_MakeLine
		      (
			      (
					  SELECT geom AS dlugosc_geo FROM airportsNew ORDER BY ST_X(geom) 
				      LIMIT 1
				  ),
			     (
					 SELECT geom AS dlugosc_geo FROM airportsNew 
					 ORDER BY ST_X(geom)
					 DESC LIMIT 1
				 )
			  )
		), 0.5
	 )
	),
	0);

SELECT * FROM airportsNew;


DELETE FROM airportsNew WHERE name = 'airportB';

-- 6. Wyznacz pole powierzchni obszaru, który oddalony jest mniej niż 1000 jednostek od najkrótszej
-- linii łączącej jezioro o nazwie ‘Iliamna Lake’ i lotnisko o nazwie „AMBLER”



SELECT * FROM ST_Area( 
    ST_Buffer( 
        (SELECT * FROM ST_ShortestLine( 
            (SELECT geom FROM lakes WHERE names = 'Iliamna Lake'),
            (SELECT geom FROM airports WHERE name = 'AMBLER'))), 
        1000));


-- 7. Napisz zapytanie, które zwróci sumaryczne pole powierzchni poligonów reprezentujących
-- poszczególne typy drzew znajdujących się na obszarze tundry i bagien (swamps).

SELECT trees.vegdesc, SUM(ST_Area(trees.geom)) 
FROM trees, tundra, swamp
WHERE ST_Contains(trees.geom, swamp.geom) AND ST_Contains(trees.geom, tundra.geom) GROUP BY trees.vegdesc;










