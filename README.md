# hethcon

![logo](https://github.com/kejace/hethcon/raw/master/logo.gif?raw=true)

## try it!

+ graphql is [here](http://ec2-52-26-52-30.us-west-2.compute.amazonaws.com:3150/graphiql)
+ connect postgres like this: `psql -h ec2-52-26-52-30.us-west-2.compute.amazonaws.com -p 31501 -U postgres erc20`

Not to be confused with `Hencon Vacuum Technologies designs, manufactures, supplies and supports a complete range of heavy-duty vacuum systems for industrial, plant and mining applications.`


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
