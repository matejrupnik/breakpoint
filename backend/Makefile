.PHONY: deploy
deploy:
	docker context use default
	docker build --platform linux/amd64 -t matejrupnik/breakpoint:latest .
	docker push matejrupnik/breakpoint:latest
	docker context use digitalocean
	export $(cat .env) > /dev/null 2>&1; docker stack deploy -c docker-compose.yml breakpoint
	docker context use default

.PHONY: update
update:
	docker context use default
	docker build --platform linux/amd64 -t matejrupnik/breakpoint:local .
	docker context use default

.PHONY: run
run: update
	docker context use default
	docker compose -f docker-compose.local.yml up
	docker context use default