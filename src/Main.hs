{-# LANGUAGE DataKinds         #-}
{-# LANGUAGE OverloadedStrings #-}
{-# OPTIONS_GHC -fno-warn-orphans #-}

module Main where

import qualified Contracts.ERC20           as ERC20
import           Control.Concurrent        (ThreadId, threadDelay)
import           Control.Monad             (void)
import           Database.Selda
import qualified Database.Selda.Generic    as SG
import           Database.Selda.PostgreSQL
import           Network.Ethereum.Web3

import           Config
import           Orphans                   ()


transfers :: SG.GenTable ERC20.Transfer
transfers = SG.genTable "transfer" []

main :: IO ()
main = do
    config <- mkConfig
    let pgConn = pg config
    withPostgreSQL pgConn . createTable $ SG.gen transfers
    void . runWeb3' $ eventLoop pgConn (erc20Address config)
    loop
  where
    loop :: IO ()
    loop = do
      _ <- threadDelay 1000000
      loop
    eventLoop :: PGConnectInfo -> Address -> Web3 HttpProvider ThreadId
    eventLoop conn addr = event addr $ \t@ERC20.Transfer{} -> do
      liftIO . print $ "Got transfer : " ++ show t
      _ <- liftIO . withPostgreSQL conn $ SG.insertGen_ transfers [t]
      return ContinueEvent
