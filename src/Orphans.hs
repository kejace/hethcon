{-# OPTIONS_GHC -fno-warn-orphans #-}

module Orphans where

import           Database.Selda
import           Database.Selda.Backend
import           Network.Ethereum.Web3
import           Network.Ethereum.Web3.Address  (fromText, toText)

-- these instances would be defined in a central library
instance SqlType Address where
  mkLit = LCustom . LText . toText
  sqlType _ = TText
  fromSql (SqlString x) = fromRight . fromText $ x
  fromSql v          = error $ "fromSql: address column with non-address value: " ++ show v
  defaultValue = error "No default value for Address type"

fromRight :: Either a b -> b
fromRight (Right b) = b
fromRight _         = error "fromRight"
