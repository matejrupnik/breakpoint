INSERT INTO surface_readings (car_id, surface_reading, location)
SELECT
    (SELECT device_fingerprint FROM cars ORDER BY RANDOM() LIMIT 1),
    ROUND((RANDOM() * 9.8 + 0.1)::numeric, 2),
    ST_MAKEPOINT(
            46.05 + (random() * 0.1 - 0.05),
            -14.50 + (random() * 0.1 - 0.05)
    )::GEOGRAPHY
FROM GENERATE_SERIES(1, 1000);