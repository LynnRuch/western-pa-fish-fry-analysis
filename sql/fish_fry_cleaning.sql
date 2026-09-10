-- WESTERN PENNSYLVANIA FISH FRY DATA CLEANING
-- PostgreSQL

-- Prepares public-source Western Pennsylvania fish fry data
-- for analysis and visualization in Tableau.


-- 1. CREATE RAW STAGING TABLE
-- Preserve source fields as provided for profiling and transformation.

DROP TABLE IF EXISTS fish_fry_raw;

CREATE TABLE fish_fry_raw (
    _id INTEGER,
    validated TEXT,
    venue_name TEXT,
    venue_type TEXT,
    venue_address TEXT,
    website TEXT,
    events TEXT,
    etc TEXT,
    menu_url TEXT,
    menu_text TEXT,
    venue_notes TEXT,
    phone TEXT,
    email TEXT,
    homemade_pierogies TEXT,
    take_out TEXT,
    alcohol TEXT,
    lunch TEXT,
    handicap TEXT,
    publish TEXT,
    id TEXT,
    latitude REAL,
    longitude REAL,
    events_json TEXT
);


-- 2. VERIFY RAW DATA IMPORT

SELECT COUNT(*) AS raw_row_count
FROM fish_fry_raw;


-- 3. CREATE CLEAN DATASET
-- Limit locations to a 30-mile radius of Pittsburgh.
-- Standardize venue types and convert source flags to Yes/No.

DROP TABLE IF EXISTS fish_fry_clean;

CREATE TABLE fish_fry_clean AS

WITH distances AS (
    SELECT *,
        3958.8 * ACOS(
            COS(RADIANS(40.4406)) * COS(RADIANS(latitude))
            * COS(RADIANS(longitude) - RADIANS(-79.9959))
            + SIN(RADIANS(40.4406)) * SIN(RADIANS(latitude))
        ) AS distance_from_pittsburgh
    FROM fish_fry_raw
    WHERE latitude IS NOT NULL
        AND longitude IS NOT NULL
),

in_scope AS (
    SELECT *
    FROM distances
    WHERE distance_from_pittsburgh <= 30
)

SELECT
    _id,
    TRIM(venue_name) AS venue_name,

-- Standardize venue categories and preserve manually reviewed classifications.

CASE
    WHEN _id IN (5391, 5497, 5514, 5540, 5544, 5546, 5571)
        THEN 'Church'

    WHEN _id IN (5331, 5336, 5352, 5470, 5479, 5486, 5548, 5561, 5568, 5576)
        THEN 'Restaurant'

    WHEN _id IN (
        5324, 5335, 5353, 5354, 5409, 5423, 5443, 5458, 5469, 5474,
        5476, 5493, 5504, 5513, 5516, 5530, 5531, 5533, 5534, 5550,
        5555, 5558, 5563, 5565, 5577, 5579, 5580, 5582, 5585, 5588
    ) THEN 'Social Org'

    WHEN venue_type = 'Community Organization' THEN 'Social Org'
    WHEN venue_type IN ('VFW', 'Veteran''s Organization') THEN 'Social Org'
    WHEN venue_type = 'Fire Department' THEN 'Fire Dept'
    WHEN venue_type IN ('Food Truck', 'Market') THEN 'Restaurant'

    ELSE venue_type
END AS venue_type,

    CASE WHEN homemade_pierogies = 't' THEN 'Yes' ELSE 'No' END
        AS homemade_pierogies,

    -- Use venue notes when the structured take-out field is missing.
    CASE
        WHEN take_out = 't'
            OR venue_notes ILIKE '%take out%'
            OR venue_notes ILIKE '%take-out%'
        THEN 'Yes'
        ELSE 'No'
    END AS take_out,

    CASE WHEN alcohol = 't' THEN 'Yes' ELSE 'No' END AS alcohol,
    CASE WHEN handicap = 't' THEN 'Yes' ELSE 'No' END AS handicap

FROM in_scope;


-- 4. VALIDATE CLEAN DATASET

SELECT COUNT(*) AS clean_row_count
FROM fish_fry_clean;

WITH validation AS (
    SELECT 'venue_type' AS field_name, venue_type AS field_value
    FROM fish_fry_clean

    UNION ALL

    SELECT 'homemade_pierogies', homemade_pierogies
    FROM fish_fry_clean

    UNION ALL

    SELECT 'take_out', take_out
    FROM fish_fry_clean

    UNION ALL

    SELECT 'alcohol', alcohol
    FROM fish_fry_clean

    UNION ALL

    SELECT 'handicap', handicap
    FROM fish_fry_clean
)

SELECT
    field_name,
    field_value,
    COUNT(*) AS record_count
FROM validation
GROUP BY field_name, field_value
ORDER BY field_name, field_value;


-- 5. CREATE FINAL ANALYSIS-READY DATASET
-- Combine SQL-cleaned attributes with manually reviewed geographic data.

DROP TABLE IF EXISTS fish_fry_final;

CREATE TABLE fish_fry_final AS

SELECT
    f._id,
    f.venue_name,
    f.venue_type,
    g.venue_address,
    g."City" AS city,
    f.homemade_pierogies,
    f.take_out,
    f.alcohol,
    f.handicap,
    g.latitude,
    g.longitude
FROM fish_fry_clean AS f
LEFT JOIN fish_fry_geography AS g
    ON f._id = g._id;

-- 6. VIEW FINAL DATASET

SELECT *
FROM fish_fry_final
ORDER BY city, venue_name;