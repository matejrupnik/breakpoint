package data

import (
	"context"
	"database/sql"
	"log"
	"time"
)

type Heatmap struct {
	Surfaces []Surface `json:"surfaces"`
}

type HeatmapModel struct {
	DB *sql.DB
}

func (m HeatmapModel) GetByLocation(longitude float64, latitude float64) (*Heatmap, error) {
	query := `SELECT sr.id AS surface_reading_id, st.id, ST_X(sr.location::GEOMETRY), ST_Y(sr.location::GEOMETRY)
				FROM surface_types AS st
				LEFT JOIN surface_readings AS sr ON st.min_value < sr.surface_reading AND st.max_value > sr.surface_reading
     			WHERE (sr.created_at > CURRENT_TIMESTAMP - INTERVAL '30 DAYS')
				AND ST_DWithin(sr.location, ST_MAKEPOINT($1, $2), 30000)`

	var heatmap Heatmap

	ctx, cancel := context.WithTimeout(context.Background(), 3*time.Second)
	defer cancel()

	rows, err := m.DB.QueryContext(ctx, query, longitude, latitude)
	if err != nil {
		log.Println(longitude, latitude, err)
		return nil, err
	}

	for rows.Next() {
		var surface Surface

		err := rows.Scan(&surface.Id, &surface.Type, &surface.Longitude, &surface.Latitude)
		if err != nil {
			return nil, err
		}

		heatmap.Surfaces = append(heatmap.Surfaces, surface)
	}

	if err := rows.Err(); err != nil {
		return nil, err
	}

	return &heatmap, nil
}
