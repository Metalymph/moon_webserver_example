native-dev:
	moon run cmd/main --target native
native-watch:
	watchexec -r -e mbt,mod.json,pkg.json moon run cmd/main --target native
native-prod:
	moon run cmd/main --target native --release
docker-build:
	docker build -t moonmocketexample:latest .
docker-stop:
	docker stop $(docker ps -q --filter ancestor=moonmocketexample:latest)
docker-clean:
	lsof -ti:4000 | xargs kill -9
docker-run:
	docker run --rm -d -p 4000:4000 moonmocketexample:latest