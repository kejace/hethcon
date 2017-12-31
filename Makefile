NODE_URL?="http://geth-rinkeby-deploy.foam.svc.cluster.local:8545"
PGHOST ?= "localhost"
PGPORT ?= "5432"
PGUSER ?= "postgres"
PGDATABASE ?= "erc20"
PGPASSWORD ?= "password"

all: stack

stack:
	stack install

clean:
	stack clean

hlint:
	find ./src -name "*.hs" | xargs hlint "--ignore=Parse error" ;

stylish:
	find ./src -name "*.hs" | xargs stylish-haskell -c ./.stylish_haskell.yaml -i;

foam-db-process: stack
	NODE_URL=$(NODE_URL) \
	PGHOST=$(PGHOST)\
	PGPORT=$(PGPORT)\
	PGUSER=$(PGUSER)\
	PGDATABASE=$(PGDATABASE)\
	PGPASSWORD=$(PGPASSWORD)\
	PGPOOLSIZE=$(PGPOOLSIZE)\
	web3-psql


