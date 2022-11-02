
CREATE EXTENSION postgis;



-- 1. Zaimportuj następujące pliki shapefile do bazy, przyjmij wszędzie układ WGS84:
-- - T2018_KAR_BUILDINGS
-- - T2019_KAR_BUILDINGS
-- Pliki te przedstawiają zabudowę miasta Karlsruhe w latach 2018 i 2019.
-- Znajdź budynki, które zostały wybudowane lub wyremontowane na przestrzeni roku (zmiana
-- pomiędzy 2018 a 2019).



SELECT * FROM public.t2018_kar_buildings
SELECT * FROM public.t2019_kar_buildings



SELECT T2019_KAR_BUILDINGS.*
FROM T2019_KAR_BUILDINGS
LEFT JOIN T2018_KAR_BUILDINGS 
ON T2019_KAR_BUILDINGS.polygon_id = T2018_KAR_BUILDINGS.polygon_id
WHERE ST_Equals(T2019_KAR_BUILDINGS.geom, T2018_KAR_BUILDINGS.geom) = FALSE AND T2019_KAR_BUILDINGS.polygon_id = T2018_KAR_BUILDINGS.polygon_id
OR T2018_KAR_BUILDINGS.polygon_id IS NULL;




-- 2. Zaimportuj dane dotyczące POIs (Points of Interest) z obu lat:
-- - T2018_KAR_POI_TABLE
-- - T2019_KAR_POI_TABLE
-- Znajdź ile nowych POI pojawiło się w promieniu 500 m od wyremontowanych lub
-- wybudowanych budynków, które znalezione zostały w zadaniu 1. Policz je wg ich kategorii.

SELECT COUNT(*), T2019_KAR_POI_TABLE.type FROM T2019_KAR_POI_TABLE  LEFT JOIN T2018_KAR_POI_TABLE 
ON T2019_KAR_POI_TABLE.poi_id = T2018_KAR_POI_TABLE.poi_id 
WHERE T2018_KAR_POI_TABLE.poi_id IS NULL AND ST_Within(T2019_KAR_POI_TABLE.geom,ST_Buffer(ST_Union
(ARRAY(SELECT T2019_KAR_POI_TABLE.geom FROM T2019_KAR_POI_TABLE INNER JOIN T2018_KAR_POI_TABLE 
ON T2019_KAR_POI_TABLE.polygon_id = T2018_KAR_POI_TABLE.polygon_id 
WHERE ST_Equals(T2019_KAR_POI_TABLE.geom, T2018_KAR_POI_TABLE.geom) != true)), 500)) GROUP BY T2019_KAR_POI_TABLE.type






-- 3. Utwórz nową tabelę o nazwie ‘streets_reprojected’, która zawierać będzie dane z tabeli
-- T2019_KAR_STREETS przetransformowane do układu współrzędnych DHDN.Berlin/Cassini.



CREATE TABLE streets_reprojected AS SELECT * FROM T2019_KAR_STREETS;
UPDATE streets_reprojected SET geom = ST_Transform(ST_SetSRID(geom, 4326), 3068);



SELECT * FROM streets_reprojected;
DROP TABLE IF EXISTS streets_reprojected;




-- 4. Stwórz tabelę o nazwie ‘input_points’ i dodaj do niej dwa rekordy o geometrii punktowej.
-- Użyj następujących współrzędnych:
-- X Y
-- 8.36093 49.03174
-- 8.39876 49.00644
-- Przyjmij układ współrzędnych GPS.




CREATE TABLE input_points(id integer, geom geometry);

INSERT INTO input_points VALUES(1, ST_GeomFromText('POINT(8.36093 49.03174)', 4326)); 
INSERT INTO input_points VALUES(2,ST_GeomFromText ('POINT(8.36093 49.03174)', 4326));

	 
SELECT * FROM input_points;
DROP TABLE IF EXISTS input_points;


-- 5. Zaktualizuj dane w tabeli ‘input_points’ tak, aby punkty te były w układzie współrzędnych
-- DHDN.Berlin/Cassini. Wyświetl współrzędne za pomocą funkcji ST_AsText().


UPDATE input_points SET geom = ST_Transform(geom,3068);
SELECT id, ST_ASText(geom) FROM input_points;



SELECT * FROM input_points;



										  
-- 7. Policz jak wiele sklepów sportowych (‘Sporting Goods Store’ - tabela POIs) znajduje się
-- w odległości 300 m od parków (LAND_USE_A).



SELECT * FROM T2019_KAR_POI_TABLE;
SELECT * FROM T2019_KAR_LAND_USE_A;
SELECT * FROM t2019_kar_poi_table WHERE t2019_kar_poi_table.type='Sporting Goods Store';



SELECT distinct t2019_kar_poi_table.* FROM t2019_kar_poi_table 
CROSS JOIN t2019_kar_land_use_a 
WHERE t2019_kar_poi_table.type='Sporting Goods Store' 
AND ST_Distance(t2019_kar_poi_table.geom,  t2019_kar_land_use_a.geom) <= 300





-- 8. Znajdź punkty przecięcia torów kolejowych (RAILWAYS) z ciekami (WATER_LINES). Zapisz
-- znalezioną geometrię do osobnej tabeli o nazwie ‘T2019_KAR_BRIDGES’.

CREATE TABLE T2019_KAR_BRIDGES AS 
SELECT distinct ST_Intersection(T2019_KAR_RAILWAYS.geom,T2019_KAR_WATER_LINES.geom) FROM T2019_KAR_RAILWAYS,T2019_KAR_WATER_LINES;

SELECT * FROM T2019_KAR_BRIDGES;

DROP TABLE IF EXISTS T2019_KAR_BRIDGES;


