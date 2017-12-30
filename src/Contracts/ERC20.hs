{-# LANGUAGE QuasiQuotes #-}
{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE DataKinds #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE MultiParamTypeClasses #-}

module Contracts.ERC20 where

import Network.Ethereum.Web3
import Network.Ethereum.Web3.TH

[abiFrom|data/ERC20.json|]
