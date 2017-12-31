{-# OPTIONS_GHC -fno-warn-orphans #-}

module Orphans where

import Data.Maybe (fromJust)
import Database.Selda
import Database.Selda.Backend
import Network.Ethereum.Web3
import Network.Ethereum.Web3.Address (toText, fromText)
import Network.Ethereum.Web3.Encoding (toData, fromData)

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

fromRight :: Either a b -> b
fromRight (Right b) = b
fromRight _ = error "fromRight"
