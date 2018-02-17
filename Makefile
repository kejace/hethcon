EXCHANGE ?= "0x12459C951127e0c374FF9105DdA097662A027093"
ETHERTOKEN ?= "0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2"
NODE_URL ?= "http://parity-proxy.foam.svc.cluster.local:8545"
PG_HOST ?= "localhost"
PG_PORT ?= "5432"
PG_USER ?= "postgres"
PG_DATABASE ?= "erc20"
PG_PASSWORD ?= "password"

## Build binary and docker images
build:
	@stack build
	@BINARY_PATH=${BINARY_PATH_RELATIVE} docker-compose build

## Builds base image used for `stack image container`
build-base:
	@docker build -t fpco/myapp-base -f Dockerfile.base .

## Builds app using stack-native.yaml
build-stack-native: build-base
	@stack --stack-yaml stack-native.yaml build
	@stack --stack-yaml stack-native.yaml image container

## Run container built by `stack image container`
run-stack-native:
	@docker run -p 3000:3000 -it -w /opt/app ${IMAGE_NAME} myapp

all: stack

0x: stack
	createdb -h localhost -p 5432 -U postgres erc20 ; CONTRACT_ADDRESS=0x12459C951127e0c374FF9105DdA097662A027093 NODE_URL="http://parity-proxy.foam.svc.cluster.local:8545/" make transfer-indexer

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


