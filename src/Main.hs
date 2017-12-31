{-# LANGUAGE DataKinds #-}
{-# LANGUAGE OverloadedStrings #-}
{-# OPTIONS_GHC -fno-warn-orphans #-}

module Main where

import Control.Concurrent (ThreadId, threadDelay)
import Control.Monad (void)
import Database.Selda
import Database.Selda.PostgreSQL
import qualified Database.Selda.Generic as SG
import Network.Ethereum.Web3

import qualified Contracts.ERC20 as ERC20
import Orphans ()

transfers :: SG.GenTable ERC20.Transfer
transfers = SG.genTable "transfer" []

pg :: PGConnectInfo
pg = "erc20" `on` "localhost"

erc20Address :: Address
erc20Address = undefined

main :: IO ()
main = do
    withPostgreSQL pg . createTable $ SG.gen transfers
    void . runWeb3' $ eventLoop
    loop
  where
    loop :: IO ()
    loop = do
      _ <- threadDelay 1000000
      loop
    eventLoop :: Web3 DefaultProvider ThreadId
    eventLoop = event erc20Address $ \t@(ERC20.Transfer{}) -> do
      liftIO . print $ "Got transfer : " ++ show t
      _ <- liftIO . withPostgreSQL pg $ SG.insertGen_ transfers [t]
      return ContinueEvent
