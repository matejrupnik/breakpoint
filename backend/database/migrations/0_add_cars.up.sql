CREATE TABLE IF NOT EXISTS cars
(
    device_fingerprint UUID PRIMARY KEY,
    created_at         TIMESTAMP(0) WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    sensitivity_value               DOUBLE PRECISION
);