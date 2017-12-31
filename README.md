# web3-psql

Using the [selda](https://github.com/valderman/selda) and [hs-web3](https://github.com/f-o-a-m/hs-web3) libraries it should be possible to build something like foam.schema and foam.db for free using template haskell and generics. This is sort of a sketch pad for how we can imagine doing that. The generated event indexer wont be optimized, but it will make it easy to spin up a postgres backend for any smart contract that corresponds to the events emmited by that contract.

## Note
We do not have the ability to create filters on an infura node, and we are still in the process of syncing a new main net node. Until Ilya clears that node, you will need to use a contract on rinkeby, which you may have to deploy yourself. The abi used here is from zeppelin's [StandardToken.sol](https://github.com/OpenZeppelin/zeppelin-solidity/blob/master/contracts/token/StandardToken.sol)

## build
```bash
> make all
```

## run
```bash
> env CONTRACT_ADDRESS=<YOUR ERC20 ADDRESS> make transfer-indexer
```
