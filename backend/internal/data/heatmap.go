package data

import (
	"context"
	"database/sql"
	"fmt"
	"log"
	"time"
)

type Heatmap struct {
	Idles    []Surface `json:"idle"`
	Asphalts []Surface `json:"asphalt"`
	Gravels  []Surface `json:"gravel"`
	Roughs   []Surface `json:"rough"`
	Potholes []Surface `json:"pothole"`
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

		fmt.Println(surface)
		fmt.Println(surface.Type)

		heatmap.Idles = append(heatmap.Idles, surface)

		//switch surface.Type {
		//case "fc005337-7691-4a26-8d48-3ff31eb767ce":
		//	heatmap.Idles = append(heatmap.Idles, surface)
		//case "7bf36d1a-70dc-4303-916c-445b0f251d5f":
		//	heatmap.Asphalts = append(heatmap.Asphalts, surface)
		//case "898a60b2-9eb4-4fb9-a73f-751a84362641":
		//	heatmap.Gravels = append(heatmap.Gravels, surface)
		//case "a7cf5742-c888-4812-b867-e44f680414ed":
		//	heatmap.Roughs = append(heatmap.Roughs, surface)
		//case "ab6646f7-12bf-47dc-94a1-ff84b1c1833f":
		//	heatmap.Potholes = append(heatmap.Potholes, surface)
		//}
	}

	if err := rows.Err(); err != nil {
		return nil, err
	}

	return &heatmap, nil
}
