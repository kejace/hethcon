{-# LANGUAGE DataKinds             #-}
{-# LANGUAGE DeriveGeneric         #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE OverloadedStrings     #-}
{-# LANGUAGE QuasiQuotes           #-}

module Contracts.ERC20 where

import           Network.Ethereum.Web3
import           Network.Ethereum.Web3.TH

[abiFrom|data/ERC20.json|]
