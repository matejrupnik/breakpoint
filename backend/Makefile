.PHONY: deploy
deploy:
	docker context use default
	docker build --platform linux/amd64 -t matejrupnik/breakpoint:latest .
	docker push matejrupnik/breakpoint:latest
	docker context use digitalocean
	docker compose -f docker-compose.yml pull
	docker compose -f docker-compose.yml up
	docker context use default

.PHONY: update
update:
	docker context use default
	docker build --platform linux/amd64 -t matejrupnik/breakpoint:local .
	docker context use default

.PHONY: run
run: update
	docker context use default
	docker compose down
	docker compose -f docker-compose.local.yml up
	docker context use default

.PHONY: fresh
fresh:
	docker context use default
	docker compose down --volumes
	rm -rf ./database/postgres-data
	docker context use default
	make run

.PHONY: deploy/fresh
deploy/fresh:
	docker context use digitalocean
	docker compose down --volumes --remove-orphans
	docker volume rm -f backend_postgres-data
	rm -rf ./database/postgres-data
	docker context use digitalocean
	make deploy