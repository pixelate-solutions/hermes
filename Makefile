up:
	docker compose up --build -d

down:
	docker compose down

api-migrate:
	docker compose run --rm -w /workspace/services/api api alembic upgrade head

worker:
	docker compose up worker

flutter-dev:
	cd hermes_flutter && flutter run -d chrome --web-port 8080

flutter-test:
	cd hermes_flutter && flutter analyze && flutter test

flutter-build-web:
	cd hermes_flutter && flutter build web --release
