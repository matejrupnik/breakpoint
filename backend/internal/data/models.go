package data

import (
	"database/sql"
)

type Models struct {
	Heatmap         HeatmapModel
	SurfaceReadings SurfaceReadingModel
}

func NewModels(db *sql.DB) Models {
	return Models{
		Heatmap:         HeatmapModel{DB: db},
		SurfaceReadings: SurfaceReadingModel{DB: db},
	}
}
