-- 1. Pobierz dane o nazwie 1:250 000 Scale Colour Raster™ Free OS OpenData ze strony: 
-- https://osdatahub.os.uk/downloads/open
-- 2. Załaduj te dane do tabeli o nazwie uk_250k.
SELECT * FROM rasters.uk_250k;

-- 3. Połącz te dane (wszystkie kafle) w mozaikę, a następnie wyeksportuj jako GeoTIFF. 

SELECT ST_Union(r.rast) AS r 
INTO rasters.uk_250kunion
FROM rasters.uk_250k


-- 4. Pobierz dane o nazwie OS Open Zoomstack ze strony:
-- https://osdatahub.os.uk/downloads/open/OpenZoomstack
-- 5. Załaduj do bazy danych tabelę reprezentującą granice parków narodowych.
SELECT * FROM vectors.uk_national_parks;


-- 6. Utwórz nową tabelę o nazwie uk_lake_district, do której zaimportujesz mapy rastrowe 
-- z punktu 1., które zostaną przycięte do granic parku narodowego Lake District.


CREATE TABLE rasters.uk_lake_district AS
SELECT r.rid, ST_Clip(r.rast, u.wkb_geometry, true) AS rast, u.id
FROM rasters.uk_250k AS r, vectors.uk_national_parks AS u
WHERE ST_Intersects(r.rast, u.wkb_geometry) AND u.id = 1;

SELECT UpdateRasterSRID('rasters','uk_lake_district','rast',27700);

DROP TABLE rasters.uk_lake_district

-- 7. Wyeksportuj wyniki do pliku GeoTIFF.
-- 8. Pobierz dane z satelity Sentinel-2 wykorzystując portal: https://scihub.copernicus.eu
-- Wybierz dowolne zobrazowanie, które pokryje teren parku Lake District oraz gdzie parametr 
-- cloud coverage będzie poniżej 20%. 
-- 9. Załaduj dane z Sentinela-2 do bazy danych.
--10. Policz indeks NDWI oraz przytnij wyniki do granic Lake District.

WITH r AS (
	SELECT r.rid, r.rast AS rast
	FROM rasters.sentinel2 AS r
)
SELECT
	r.rid, ST_MapAlgebra(
		r.rast, 1,
		r.rast, 4,
		'([rast2.val] - [rast1.val]) / ([rast2.val] + [rast1.val])::float','32BF'
	) AS rast
FROM r;

-- 11. Wyeksportuj obliczony i przycięty wskaźnik NDWI do GeoTIFF.
