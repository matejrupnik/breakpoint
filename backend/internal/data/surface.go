package data

import (
	"context"
	"database/sql"
	"time"
)

type Surface struct {
	Id        string  `json:"id"`
	Type      string  `json:"type"`
	Longitude float64 `json:"longitude"`
	Latitude  float64 `json:"latitude"`
}

type SurfaceReading struct {
	Id                string    `json:"id"`
	CreatedAt         time.Time `json:"created_at"`
	DeviceFingerprint string    `json:"device_fingerprint"`
	SurfaceReading    float64   `json:"surface_reading"`
	Longitude         float64   `json:"longitude"`
	Latitude          float64   `json:"latitude"`
}

type SurfaceReadingModel struct {
	DB *sql.DB
}

func (m SurfaceReadingModel) Insert(surfaceReading *SurfaceReading) error {
	query := `WITH sensitivity_value AS (
				SELECT sensitivity_value
				FROM cars
				WHERE device_fingerprint = $1
			)
			INSERT INTO surface_readings (car_id, surface_reading, location) 
				SELECT $1, $2 - sensitivity_value.sensitivity_value, ST_MAKEPOINT($3, $4)
				FROM sensitivity_value
				RETURNING id, created_at`

	args := []any{surfaceReading.DeviceFingerprint, surfaceReading.SurfaceReading, surfaceReading.Longitude, surfaceReading.Latitude}

	ctx, cancel := context.WithTimeout(context.Background(), 3*time.Second)
	defer cancel()

	return m.DB.QueryRowContext(ctx, query, args...).Scan(&surfaceReading.Id, &surfaceReading.CreatedAt)
}
