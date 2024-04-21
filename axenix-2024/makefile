all: run

deploy_db: database.db
	scp database.db scp://${DATA_DEPLOY_PATH}

deploy_bin: bin/axenix-2024
	scp bin/axenix-2024 scp://${BIN_DEPLOY_PATH}

run: bin/axenix-2024 database.db
	./bin/axenix-2024

.PHONY: axenix-2024

bin/axenix-2024: bin apis sqlboiler
	go build -o bin/axenix-2024
	
apis: api.json
	npx -y @openapitools/openapi-generator-cli generate -i api.json -g go -o apis
	rm -rf ./apis/test ./apis/go.*

deploy_docs: api.json
	scp api.json scp://${DOCS_DEPLOY_PATH}

api.json: api.ts node_modules
	npx @airtasker/spot generate --generator openapi3 --out . -l json -c api.ts

node_modules: package.json package-lock.json
	npm i
bin:
	mkdir -p bin

# .PHONY: bin/seed
# 	go build -o bin/seed ./cmd/seed

# .PHONY: bin/big_seed
# bin/big_seed: bin sqlboiler
# 	go build -o bin ./cmd/big_seed

clean_db:
	-rm database.db

reinit_db: dbschema.sqlite.sql clean_db
	sqlite3 -table database.db -init dbschema.sqlite.sql .exit

database.db: clean_db reinit_db
	cat ./data.geojson | ./geojson.pl
clean_sqlboiler:
	-rm -rf models

sqlboiler: reinit_db clean_sqlboiler
	sqlboiler sqlite3

presentation.html: presentation.md presentation.css
	pandoc -c presentation.css -s -t revealjs -o presentation.html presentation.md

deploy_admin:
	scp admin/phpliteadmin.php ./phpliteadmin.config.php scp://${DATA_DEPLOY_PATH}
run_admin:
	php -S localhost:8080 ./admin/phpliteadmin.php 
