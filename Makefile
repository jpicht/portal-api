default: help
help:
	echo nope

SHELL=bash
MYSQL=docker exec -i mysql mysql -u root -pdbpass
MYSQLDUMP=docker exec -i mysql mysqldump -u root -pdbpass

init-db-contianer: start-container create-db

start-container:
	docker run -p 3306:3306 --name mysql -e MYSQL_ROOT_PASSWORD=dbpass -e MYSQL_DATABASE=portal  -d mysql:latest

create-db:
	$(MYSQL) -e 'CREATE DATABASE IF NOT EXISTS portal'

reset-db:
	$(MYSQL) -e 'DROP DATABASE IF EXISTS portal'

need-legacy-db:
	if ! $(MYSQL) -e 'SHOW DATABASES' | grep -q legacy; then \
		make import-legacy-db; \
	fi

import-legacy-db:
	$(MYSQL) -e 'DROP DATABASE IF EXISTS legacy'
	$(MYSQL) -e 'CREATE USER IF NOT EXISTS "summer-hannover"'
	$(MYSQL) -e 'CREATE DATABASE legacy'
	$(MYSQL) -B legacy < legacy/data.sql

migrate:
	migrate -database mysql://root:dbpass@/portal -path migrations/db up

test-legacy-migrate: need-legacy-db
	$(MYSQL) -e 'DROP DATABASE IF EXISTS migrate'
	$(MYSQL) -e 'DROP DATABASE IF EXISTS clean'
	$(MYSQL) -e 'CREATE DATABASE migrate'
	$(MYSQL) -e 'CREATE DATABASE clean'
	migrate -database mysql://root:dbpass@/clean -path migrations/db up
	migrate -database mysql://root:dbpass@/migrate -path migrations/legacy up
	diff -uw \
		<( $(MYSQLDUMP) --compact --no-data clean | sed 's/ AUTO_INCREMENT=[0-9]*//g' ) \
		<( $(MYSQLDUMP) --compact --no-data migrate | sed 's/ AUTO_INCREMENT=[0-9]*//g' )

mysql:
	docker exec -it mysql mysql -u root -pdbpass portal
