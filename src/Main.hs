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
import Network.Ethereum.Web3.Address (toText, fromText)
import Network.Ethereum.Web3.Encoding

import qualified Contracts.ERC20 as ERC20

{-
-- generated transfer event type

data Transfer
  = Transfer {transfer_from :: {-# NOUNPACK #-} !Address,
              transfer_to :: {-# NOUNPACK #-} !Address,
              transfer_value :: {-# NOUNPACK #-} !Integer}
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

transfers :: SG.GenTable ERC20.Transfer
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
    eventLoop = event erc20Address $ \t@(ERC20.Transfer _ _ _) -> do
      _ <- liftIO . withPostgreSQL pg $ SG.insertGen_ transfers [t]
      return ContinueEvent

fromRight :: Either a b -> b
fromRight (Right b) = b
fromRight _ = error "fromRight"
