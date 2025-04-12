package main

import (
	"net/http"
)

func (app *application) routes() http.Handler {
	api := http.NewServeMux()

	api.HandleFunc("GET /api/heatmap", app.showHeatmapHandler)
	api.HandleFunc("POST /api/surface", app.createSurfaceReadingHandler)

	return api
}
