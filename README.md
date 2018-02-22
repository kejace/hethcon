# hethcon

![logo](https://github.com/kejace/hethcon/raw/master/images/logo.gif?raw=true)
[![Build Status](https://travis-ci.org/kejace/hethcon.svg?branch=master)](https://travis-ci.org/kejace/hethcon)

## try it!

+ REST API is [here](http://petstore.swagger.io/?url=http://ec2-52-26-52-30.us-west-2.compute.amazonaws.com:31502/)
+ graphql is [here](http://ec2-52-26-52-30.us-west-2.compute.amazonaws.com:31500/graphiql?query={%20allOrders%20{%20edges%20{%20node%20{%20exchangeorderExchangeContractAddress%20exchangeorderMaker%20exchangeorderTaker%20exchangeorderMakerTokenAddress%20exchangeorderTakerTokenAddress%20exchangeorderMakerTokenAmount%20exchangeorderTakerTokenAmount%20exchangeorderMakerFee%20exchangeorderTakerFee%20exchangeorderFeeRecipient%20exchangeorderExpirationUnixTimestampSec%20}%20}%20}%20})
+ connect postgres like this: `psql -h ec2-52-26-52-30.us-west-2.compute.amazonaws.com -p 31501 -U postgres erc20`

## about

Not to be confused with 
```
Hencon Vacuum Technologies designs, manufactures, supplies and supports a complete range of heavy-duty vacuum systems for industrial, plant and mining applications.
```

+ ![REST API](https://github.com/kejace/hethcon/raw/master/images/restapi.png?raw=true)

+ ![graphql](https://github.com/kejace/hethcon/raw/master/images/graphql.png?raw=true)


+ ![graphql](https://github.com/kejace/hethcon/raw/master/images/graphql2.png?raw=true)


This is a one-click deploy `docker` image that automatically indexes all order events from `0x` and all its `SRA` compliant relay nodes' orderbooks into a `postgres` database.

This database is also connected to a `graphql` and a `REST` API for easy consumption.

Contracts are [here](https://0xproject.com/wiki#Deployed-Addresses)

## run (dockerized)
```bash
> make docker0x
```

## building

### local
```bash
> make all
```

### run (localhost)

Yopu need a `postgres` server running (`localhost` by default). Suggested to run is
```bash
> docker run --rm -it -p 5432:5432 sheerun/awesome-postgres:9.5
```

```bash
> make 0x
```
