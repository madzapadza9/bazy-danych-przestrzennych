CREATE DATABASE cwiczenie1;

CREATE EXTENSION postgis;

CREATE TABLE buildings
(
	id INTEGER PRIMARY KEY,
	geometry GEOMETRY,
	name VARCHAR(25),
	height FLOAT
);

CREATE TABLE roads
(
	id INTEGER PRIMARY KEY,
	geometry GEOMETRY,
	name VARCHAR(25)
);

CREATE TABLE pktinfo
(
	id INTEGER PRIMARY KEY,
	geometry GEOMETRY,
	name VARCHAR(25),
	liczprac INTEGER
);
INSERT INTO buildings VALUES(1, ST_GeomFromText('POLYGON((8 4, 10.5 4, 10.5 1.5, 8 1.5, 8 4))', 0), 'BuildingA', 5);
INSERT INTO buildings VALUES(2, ST_GeomFromText('POLYGON((4 7, 6 7, 6 5, 4 5, 4 7))', 0), 'BuildingB', 8);
INSERT INTO buildings VALUES(3, ST_GeomFromText('POLYGON((3 8, 5 8, 5 6, 3 6, 3 8))', 0), 'BuildingC', 6);
INSERT INTO buildings VALUES(4, ST_GeomFromText('POLYGON((9 9, 10 9, 10 8, 9 8, 9 9))', 0), 'BuildingD', 10);
INSERT INTO buildings VALUES(5, ST_GeomFromText('POLYGON((1 2, 2 2, 2 1, 1 1, 1 2))', 0), 'BuildingF', 7);


INSERT INTO roads VALUES(1, ST_GeomFromText('LINESTRING(0 4.5, 12 4.5)', 0), 'RoadX');
INSERT INTO roads VALUES(2, ST_GeomFromText('LINESTRING(7.5 10.5, 7.5 0)', 0), 'RoadY');

INSERT INTO pktinfo VALUES(1, ST_GeomFromText('POINT(6 9.5)', 0), 'K', 1);
INSERT INTO pktinfo VALUES(2, ST_GeomFromText('POINT(6.5 6)', 0), 'J', 2);
INSERT INTO pktinfo VALUES(3, ST_GeomFromText('POINT(9.5 6)', 0), 'I', 3);
INSERT INTO pktinfo VALUES(4, ST_GeomFromText('POINT(5.5 1.5)', 0), 'H', 4);
INSERT INTO pktinfo VALUES(5, ST_GeomFromText('POINT(1 3.5)', 0), 'G', 5);

--1. Wyznacz całkowitą długość dróg w analizowanym mieście. 
SELECT SUM(ST_Length(geometry)) AS długość_drog 
FROM roads;

--2. Wypisz geometrię (WKT), pole powierzchni oraz obwód poligonu reprezentującego BuildingA. 
SELECT ST_AsText(buildings.geometry) AS WKT, ST_Area(buildings.geometry) AS pole_powierzchni, ST_Perimeter(buildings.geometry) AS obwod 
FROM buildings
WHERE buildings.name = 'BuildingA';

--3. Wypisz nazwy i pola powierzchni wszystkich poligonów w warstwie budynki. Wyniki posortuj alfabetycznie. 
SELECT name, ST_Area(buildings.geometry) AS pole_powierzchni 
FROM buildings 
ORDER BY name;

--4. Wypisz nazwy i obwody 2 budynków o największej powierzchni. 
SELECT name, ST_Perimeter(buildings.geometry) AS obwód 
FROM buildings 
ORDER BY ST_Area(buildings.geometry) DESC
LIMIT 2;

--5. Wyznacz najkrótszą odległość między budynkiem BuildingC a punktem G.
SELECT ST_Distance(buildings.geometry, pktinfo.geometry) AS odległość 
FROM buildings, pktinfo
WHERE buildings.name = 'BuildingC' AND pktinfo.name = 'G';

--6. Wypisz pole powierzchni tej części budynku BuildingC, która znajduje się w odległości większej niż 0.5 od budynku BuildingB.
SELECT ST_Area(
	ST_Difference((
		SELECT buildings.geometry FROM buildings WHERE buildings.name = 'BuildingC'),
		ST_BUFFER((SELECT buildings.geometry FROM buildings WHERE buildings.name = 'BuildingB'), 0.5)
	)) AS pole_powierzchni;

SELECT ST_Area(ST_Difference(a.geometry, ST_Buffer(b.geometry, 0.5))) AS pole_powierzchni 
FROM buildings a, buildings b
WHERE a.name = 'BuildingC' AND b.name = 'BuildingB';

--7. Wybierz te budynki, których centroid (ST_Centroid) znajduje się powyżej drogi RoadX. 
SELECT buildings.name 
FROM buildings
WHERE ST_Y(ST_Centroid(buildings.geometry)) > (SELECT ST_YMax(roads.geometry) FROM roads WHERE roads.name = 'RoadX');

--8. Oblicz pole powierzchni tych części budynku BuildingC i poligonu o współrzędnych (4 7, 6 7, 6 8, 4 8, 4 7), które nie są wspólne dla tych dwóch obiektów.
SELECT ST_Area(ST_SymDifference(buildings.geometry, ST_GeomFromText('POLYGON((4 7, 6 7, 6 8, 4 8, 4 7))', 0)))
FROM buildings
WHERE buildings.name = 'BuildingC';
						