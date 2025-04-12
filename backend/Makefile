.PHONY: run
run:
	docker compose down
	docker compose -f docker-compose.local.yml up --build

.PHONY: fresh
fresh:
	docker compose down --volumes
	rm -rf ./database/postgres-data
	make run

.PHONY: deploy/run
deploy/run:
	docker compose down
	docker compose -f docker-compose.yml up --build

.PHONY: deploy/fresh
deploy/fresh:
	docker compose down --volumes
	rm -rf ./database/postgres-data
	make deploy/run