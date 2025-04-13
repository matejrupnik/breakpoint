package main

import (
	"breakpoint.matejrupnik.com/internal/data"
	"encoding/json"
	"log"
	"net/http"
)

func (app *application) createSurfaceReadingHandler(w http.ResponseWriter, r *http.Request) {
	type input struct {
		DeviceFingerprint string  `json:"device_fingerprint"`
		SurfaceReading    float64 `json:"surface_reading"`
		Longitude         float64 `json:"longitude"`
		Latitude          float64 `json:"latitude"`
	}

	var inputData input
	err := json.NewDecoder(r.Body).Decode(&inputData)
	if err != nil {
		log.Println(err)
		return
	}

	surfaceReading := &data.SurfaceReading{
		DeviceFingerprint: inputData.DeviceFingerprint,
		SurfaceReading:    inputData.SurfaceReading,
		Longitude:         inputData.Longitude,
		Latitude:          inputData.Latitude,
	}

	err = app.models.SurfaceReadings.Insert(surfaceReading)
	if err != nil {
		log.Println(err)
		return
	}

	log.Println(surfaceReading)

	jsonResponse, err := json.MarshalIndent(map[string]any{"surface_reading": surfaceReading}, "", "\t")
	if err != nil {
		log.Println(err)
		return
	}

	jsonResponse = append(jsonResponse, '\n')

	w.Header().Set("Content-Type", "application/json")
	w.Header().Set("Access-Control-Allow-Origin", "*")
	w.Header().Set("Access-Control-Allow-Headers", "Content-Type")

	_, err = w.Write(jsonResponse)
	if err != nil {
		log.Println(err)
		return
	}
}
