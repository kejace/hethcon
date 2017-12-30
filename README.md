# web3-psql

Using the [selda](https://github.com/valderman/selda) and [hs-web3](https://github.com/f-o-a-m/hs-web3) libraries it should be possible to build something like foam.schema and foam.db for free using template haskell and generics. This is sort of a sketch pad for how we can imagine doing that. The generated event indexer wont be optimized, but it will make it easy to spin up a postgres backend for any smart contract that corresponds to the events emmited by that contract.
