--1. Utwórz tabelę obiekty. W tabeli umieść nazwy i geometrie obiektów przedstawionych poniżej. Układ odniesienia
--ustal jako niezdefiniowany. Definicja geometrii powinna odbyć się za pomocą typów złożonych, właściwych dla EWKT.

DROP TABLE IF EXISTS obiekty;

CREATE TABLE obiekty
(
id INT PRIMARY KEY,
nazwa VARCHAR(9),
geom GEOMETRY
)

--obiekt 1

INSERT INTO obiekty VALUES(
	1, 'obiekt1', ST_GeomFromEWKT('COMPOUNDCURVE((0 1, 1 1), CIRCULARSTRING(1 1, 2 0, 3 1), CIRCULARSTRING(3 1, 4 2, 5 1), (5 1, 6 1))')
);

--obiekt 2
									 
INSERT INTO obiekty VALUES(
	2, 'obiekt2', ST_GeomFromEWKT('CURVEPOLYGON
								     (COMPOUNDCURVE(
								        (10 6, 14 6), 
								        CIRCULARSTRING(14 6, 16 4, 14 2), CIRCULARSTRING(14 2, 12 0, 10 2),
								        (10 2, 10 6)),
								  CIRCULARSTRING(11 2,12 1,13 2,12 3,11 2)
								     )' 
								 ));

--obiekt 3



INSERT INTO obiekty VALUES(
	3, 'obiekt3', ST_GeomFromEWKT('COMPOUNDCURVE((7 15, 10 17, 12 13, 7 15))')
);	


--obiekt 4

INSERT INTO obiekty VALUES(
	4, 'obiekt4', ST_GeomFromEWKT('COMPOUNDCURVE((20 20, 25 25, 27 24, 25 22, 26 21, 22 19, 20.5 19.5))')
);


--obiekt 5

INSERT INTO obiekty VALUES(5,'obiekt5',ST_GeomFromEWKT('MULTIPOINT Z(38 32 234,30 30 59)')
);


-- obiekt 6


INSERT INTO obiekty VALUES(6,'obiekt6', ST_Collect(ST_GeomFromEWKT('LINESTRING(1 1,3 2)'),ST_GeomFromEWKT('POINT(4 2)'))
);
	
	
--2. 
-- a) Wyznacz pole powierzchni bufora o wielkości 5 jednostek, który został utworzony wokół najkrótszej linii łączącej
-- obiekt 3 i 4.

SELECT ST_Area(ST_Buffer(ST_Shortestline(obiekt3.geom, obiekt4.geom),5)) 
FROM obiekty AS obiekt3, obiekty AS obiekt4
WHERE 
    obiekt3.nazwa='obiekt3' 
  AND 
    obiekt4.nazwa='obiekt4';



-- b) Zamień obiekt4 na poligon. Jaki warunek musi być spełniony, aby można było wykonać to zadanie? Zapewnij te
-- warunki.

	UPDATE obiekty 
	SET geom = ST_MakePolygon(ST_AddPoint(ST_CurveToLine(geom), ST_StartPoint(geom)))
	WHERE nazwa = 'obiekt4'
	
	
	
		   
-- c) W tabeli obiekty, jako obiekt7 zapisz obiekt złożony z obiektu 3 i obiektu 4.

INSERT INTO obiekty
VALUES(7,'obiekt7',(SELECT st_collect(obiekt3.geom, obiekt4.geom) 
					FROM obiekty AS obiekt3, obiekty AS obiekt4
					WHERE obiekt3.nazwa='obiekt3' AND obiekt4.nazwa='obiekt4'))
					
SELECT * from obiekty
					
					
-- d) Wyznacz pole powierzchni wszystkich buforów o wielkości 5 jednostek, które zostały utworzone wokół obiektów nie
-- zawierających łuków.


SELECT
	ST_Area(ST_Buffer(geom, 5))
FROM obiekty
WHERE 
	ST_HasArc(geom) = 'false'	














	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
								 
								 
								 
								 
								 
								 
								 
								 
								 
								 
								 
								 
								 
								 
								 
								 
								 


















