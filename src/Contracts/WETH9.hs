{-# LANGUAGE DataKinds             #-}
{-# LANGUAGE DeriveGeneric         #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE OverloadedStrings     #-}
{-# LANGUAGE QuasiQuotes           #-}

module Contracts.WETH9 where

import           Network.Ethereum.Web3
import           Network.Ethereum.Web3.TH

[abiFrom|data/WETH9.json|]
