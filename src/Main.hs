{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE QuasiQuotes #-}
{-# LANGUAGE DataKinds #-}
{-# LANGUAGE OverloadedStrings #-}
{-# OPTIONS_GHC -fno-warn-orphans #-}

module Main where

import Control.Concurrent (ThreadId)
import Control.Monad (void)
import Data.Maybe
import Database.Selda
import Database.Selda.Backend
import Database.Selda.PostgreSQL

import qualified Database.Selda.Generic as SG
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

transfers :: SG.GenTable Transfer
transfers = SG.genTable "transfer" []

erc20Address :: Address
erc20Address = "0x1234567890123456789012345678901234567890"

pg :: PGConnectInfo
pg = "erc20" `on` "localhost"

main :: IO ()
main = do
    void . runWeb3' $ eventLoop
  where
    eventLoop :: Web3 DefaultProvider ThreadId
    eventLoop = event erc20Address $ \t@(Transfer _ _ _) -> do
      _ <- liftIO . withPostgreSQL pg $ SG.insertGen_ transfers [t]
      return ContinueEvent

fromRight :: Either a b -> b
fromRight (Right b) = b
fromRight _ = error "fromRight"
