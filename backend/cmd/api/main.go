package main

import (
	"breakpoint.matejrupnik.com/internal/data"
	"context"
	"database/sql"
	"fmt"
	_ "github.com/lib/pq"
	"os"
	"strconv"
	"sync"
	"time"
)

type config struct {
	port int
	env  string
	db   struct {
		dsn          string
		maxOpenConns int
		maxIdleConns int
		maxIdleTime  string
	}
}

type application struct {
	config    config
	models    data.Models
	waitGroup sync.WaitGroup
}

func main() {
	var cfg config

	port, err := strconv.Atoi(os.Getenv("BREAKPOINT_PORT"))
	cfg.port = port
	cfg.env = os.Getenv("BREAKPOINT_ENV")

	cfg.db.dsn = fmt.Sprintf("postgres://%s:%s@db/%s?sslmode=disable", os.Getenv("BREAKPOINT_DB_USER"), os.Getenv("BREAKPOINT_DB_PASSWORD"), os.Getenv("BREAKPOINT_DB"))

	maxOpenConns, err := strconv.Atoi(os.Getenv("BREAKPOINT_DB_MAX_OPEN_CONNS"))
	cfg.db.maxOpenConns = maxOpenConns
	maxIdleConns, err := strconv.Atoi(os.Getenv("BREAKPOINT_DB_MAX_IDLE_CONNS"))
	cfg.db.maxIdleConns = maxIdleConns
	cfg.db.maxIdleTime = os.Getenv("BREAKPOINT_DB_MAX_IDLE_TIME")

	if err != nil {
		panic(err)
	}

	db, err := openDB(cfg)
	if err != nil {
		fmt.Println(err)
		os.Exit(1)
	}

	defer db.Close()

	app := &application{
		config: cfg,
		models: data.NewModels(db),
	}

	err = app.serve()
	if err != nil {
		fmt.Println(err)
		os.Exit(1)
	}
}

func openDB(cfg config) (*sql.DB, error) {
	db, err := func() (*sql.DB, error) {
		for {
			db, err := sql.Open("postgres", cfg.db.dsn)
			if err != nil {
				return nil, err
			}

			err = db.Ping()
			if err == nil {
				return db, nil
			}

			time.Sleep(1 * time.Second)
			continue
		}
	}()

	duration, err := time.ParseDuration(cfg.db.maxIdleTime)
	if err != nil {
		return nil, err
	}

	db.SetMaxOpenConns(cfg.db.maxOpenConns)
	db.SetMaxIdleConns(cfg.db.maxIdleConns)
	db.SetConnMaxIdleTime(duration)

	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()

	err = db.PingContext(ctx)
	if err != nil {
		return nil, err
	}

	return db, nil
}
