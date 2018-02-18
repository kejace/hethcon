{-# LANGUAGE DataKinds #-}
{-# LANGUAGE FlexibleInstances #-}
{-# OPTIONS_GHC -fno-warn-orphans #-}

module Orphans where

import           Database.Selda
import           Database.Selda.Backend
import           Data.Maybe                     (fromJust)
import           Data.Text                      (unpack, pack)
import           Network.Ethereum.Web3
import           Network.Ethereum.Web3.Encoding (ABIDecode(..))
import           Network.Ethereum.Web3.Address  (fromText, toText)

-- these instances would be defined in a central library
instance SqlType Address where
  mkLit = LCustom . LText . toText
  sqlType _ = TText
  fromSql (SqlString x) = fromRight . fromText $ x
  fromSql v          = error $ "fromSql: address column with non-address value: " ++ show v
  defaultValue = error "No default value for Address type"

instance SqlType (UIntN 256) where
  mkLit = LCustom . LInteger . unUIntN
  sqlType _ = TInteger
  fromSql (SqlString x) = fromJust . uIntNFromInteger . read . unpack $ x
  fromSql v          = error $ "fromSql: (UIntN 256) column with non-address value: " ++ show v
  defaultValue = error "No default value for (UIntN 256) type"

instance SqlType (BytesN 32) where
  mkLit = LCustom . LText . pack . show --unBytesN
  sqlType _ = TText
  fromSql (SqlString x) = fromJust . fromData $ x
  fromSql v          = error $ "fromSql: (BytesN 32) column with non-address value: " ++ show v
  defaultValue = error "No default value for (BytesN 32) type"


fromRight :: Either a b -> b
fromRight (Right b) = b
fromRight _         = error "fromRight"
