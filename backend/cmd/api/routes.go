package main

import (
	"encoding/json"
	"log"
	"net/http"
)

func (app *application) routes() http.Handler {
	api := http.NewServeMux()

	api.HandleFunc("POST /api/test", func(w http.ResponseWriter, r *http.Request) {

		type Test struct {
			Test string `json:"test"`
		}

		var test Test
		err := json.NewDecoder(r.Body).Decode(&test)
		if err != nil {
			panic("test")
		}

		jsonResponse, err := json.MarshalIndent(test, "", "\t")
		if err != nil {
			log.Println(err)
		}

		jsonResponse = append(jsonResponse, '\n')

		w.Header().Set("Content-Type", "application/json")

		_, err = w.Write(jsonResponse)
		if err != nil {
			log.Println(err)
		}
	})

	return api
}
