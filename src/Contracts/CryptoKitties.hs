{-# LANGUAGE DataKinds             #-}
{-# LANGUAGE DeriveGeneric         #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE OverloadedStrings     #-}
{-# LANGUAGE QuasiQuotes           #-}

module Contracts.CryptoKitties where

import           Network.Ethereum.Web3
import           Network.Ethereum.Web3.TH

[abiFrom|data/CryptoKitties.json|]
