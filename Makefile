db-up:
	docker-compose up -d

db-down:
	docker-compose down

psql:
	docker-compose exec postgres psql -U user -d mydb
