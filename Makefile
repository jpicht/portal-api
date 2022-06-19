default: help
help:
	echo nope

SHELL=bash

clean: container-mysql-delete

################################################################################
## MySQL
################################################################################

MYSQL_CONTAINER=portal_mysql

MYSQL=docker exec -i $(MYSQL_CONTAINER) mysql
MYSQLDUMP=docker exec -i $(MYSQL_CONTAINER) mysqldump

init-db-contianer: container-mysql-start migrate

container-mysql-start:
	docker run -p 3306:3306 \
		--name $(MYSQL_CONTAINER) \
		-v $(PWD)/dev/my.cnf:/root/.my.cnf \
		-e MYSQL_ROOT_PASSWORD=dbpass \
		-e MYSQL_DATABASE=portal \
		-d mysql:latest
	while ! $(MYSQL) -e 'SELECT 1' 2>/dev/null | grep -q 1; do \
		sleep 1; \
	done

container-mysql-delete:
	if docker ps | grep -q $(MYSQL_CONTAINER); then \
		docker rm -f $(MYSQL_CONTAINER); \
	fi

need-mysql-container:
	if ! docker ps | grep -q $(MYSQL_CONTAINER); then \
		make container-mysql-start; \
	fi

reset-db:
	$(MYSQL) -e 'DROP DATABASE IF EXISTS portal'

migrate:
	$(MYSQL) -e 'CREATE DATABASE IF NOT EXISTS portal'
	migrate -database mysql://root:dbpass@/portal -path migrations/db up

mysql:
	docker exec -it $(MYSQL_CONTAINER) mysql

mysql_bash:
	docker exec -it $(MYSQL_CONTAINER) bash -l

################################################################################
## Legacy database
################################################################################
#
# Due to obvious privacy issues, the legacy data will not be provided in this
# repository.
#

need-legacy-db: need-mysql-container
	if ! $(MYSQL) -e 'SHOW DATABASES' | grep -q legacy; then \
		make import-legacy-db; \
	fi

import-legacy-db:
	$(MYSQL) -e 'DROP DATABASE IF EXISTS legacy'
	$(MYSQL) -e 'CREATE USER IF NOT EXISTS "summer-hannover"'
	$(MYSQL) -e 'CREATE DATABASE legacy'
	$(MYSQL) -B legacy < legacy/data.sql

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
