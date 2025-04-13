package main

import (
	"encoding/json"
	"log"
	"net/http"
	"strconv"
)

func (app *application) showHeatmapHandler(w http.ResponseWriter, r *http.Request) {
	var input struct {
		Longitude float64
		Latitude  float64
	}

	queryString := r.URL.Query()

	var err error
	input.Longitude, err = strconv.ParseFloat(queryString.Get("longitude"), 64)
	input.Latitude, err = strconv.ParseFloat(queryString.Get("latitude"), 64)

	if err != nil || input.Longitude == 0.0 && input.Latitude == 0.0 {
		log.Println(err)
		return
	}

	heatmap, err := app.models.Heatmap.GetByLocation(input.Longitude, input.Latitude)
	if err != nil {
		log.Println(err)
		return
	}

	jsonResponse, err := json.MarshalIndent(map[string]any{"heatmap": heatmap}, "", "\t")
	if err != nil {
		log.Println(err)
		return
	}

	jsonResponse = append(jsonResponse, '\n')

	w.Header().Set("Content-Type", "application/json")

	_, err = w.Write(jsonResponse)

	if err != nil {
		log.Println(err)
		return
	}
}
