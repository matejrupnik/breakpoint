CREATE TABLE IF NOT EXISTS surface_readings
(
    id         UUID PRIMARY KEY                     DEFAULT uuid_generate_v4(),
    created_at TIMESTAMP(0) WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,

    car_id         UUID                        NOT NULL REFERENCES cars ON DELETE CASCADE,
    surface_reading DOUBLE PRECISION NOT NULL,
    location GEOGRAPHY(POINT)
);

CREATE INDEX IF NOT EXISTS idx_surface_readings_car_id ON surface_readings (car_id);
CREATE INDEX idx_surface_readings_surface_reading ON surface_readings (surface_reading);