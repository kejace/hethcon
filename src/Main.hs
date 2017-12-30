{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE QuasiQuotes #-}
{-# LANGUAGE DataKinds #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE TypeOperators #-}
{-# LANGUAGE TypeFamilies #-}
{-# OPTIONS_GHC -fno-warn-orphans #-}

module Main where

import Data.Maybe
import Database.Selda
import Database.Selda.Backend
import GHC.TypeLits
import Network.Ethereum.Web3
import Network.Ethereum.Web3.Encoding
import Network.Ethereum.Web3.TH
import Network.Ethereum.Web3.Address (toText, fromText)

[abiFrom|data/ERC20.json|]

{-
-- generated transfer event type

{ "anonymous": false,
  "inputs": [
    {
      "indexed": true,
      "name": "_from",
      "type": "address"
    },
    {
      "indexed": true,
      "name": "_to",
      "type": "address"
    },
    {
      "indexed": false,
      "name": "_value",
      "type": "uint256"
    }
  ],
  "name": "Transfer",
  "type": "event"
}

data Transfer
   = Transfer {-# NOUNPACK #-} !Address {-# NOUNPACK #-} !Address {-# NOUNPACK #-} !Integer
   deriving (Show, Eq, Ord, GHC.Generics.Generic)
 instance Generic Transfer

-}

-- these instances would be defined in a central library
instance SqlType Address where
  mkLit = LCustom . LText . toText
  sqlType _ = TText
  fromSql (SqlString x) = fromRight . fromText $ x
  fromSql v          = error $ "fromSql: address column with non-address value: " ++ show v
  defaultValue = error "No default value for Address type"

instance SqlType Integer where
  mkLit = LCustom . LText . toData
  sqlType _ = TText
  fromSql (SqlString x) = fromJust . fromData $ x
  fromSql v          = error $ "fromSql: int column with non-int value: " ++ show v
  defaultValue = error "No default value for UIntN type"

type family ToTable a :: * where
  ToTable (SOP I '[as]) = ToRow as

type family ToRow as :: * where
  ToRow '[a] = a
  ToRow (a : as) = a :*: ToRow as

-- transfers table definition, possible to generate automatically, easy to generalize with type family
transfers :: Table (ToTable (Rep Transfer))
transfers = table "transfer" $ required "_to" :*: required "_from" :*: required "_value"

main :: IO ()
main = do
  putStrLn "hello world"

fromRight :: Either a b -> b
fromRight (Right b) = b
