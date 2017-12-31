NODE_URL ?= "http://geth-rinkeby-deploy.foam.svc.cluster.local:8545"
PG_HOST ?= "localhost"
PG_PORT ?= "5432"
PG_USER ?= "postgres"
PG_DATABASE ?= "erc20"
PG_PASSWORD ?= "password"

all: stack

stack:
	stack install

clean:
	stack clean

hlint:
	find ./src -name "*.hs" | xargs hlint "--ignore=Parse error" ;

stylish:
	find ./src -name "*.hs" | xargs stylish-haskell -c ./.stylish_haskell.yaml -i;

transfer-indexer: stack
	NODE_URL=$(NODE_URL) \
	CONTRACT_ADDRESS=$(CONTRACT_ADDRESS) \
	PG_HOST=$(PG_HOST) \
	PG_PORT=$(PG_PORT) \
	PG_USER=$(PG_USER) \
	PG_DATABASE=$(PG_DATABASE) \
	PG_PASSWORD=$(PG_PASSWORD) \
	web3-psql


