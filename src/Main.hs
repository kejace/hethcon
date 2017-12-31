{-# LANGUAGE DataKinds         #-}
{-# LANGUAGE OverloadedStrings #-}
{-# OPTIONS_GHC -fno-warn-orphans #-}

module Main where

import qualified Contracts.ERC20           as ERC20
import           Control.Concurrent        (ThreadId, threadDelay)
-- import           Control.Concurrent.Chan
import           Database.Selda
import qualified Database.Selda.Generic    as SG
import           Database.Selda.PostgreSQL
import           Network.Ethereum.Web3
-- import           System.IO.Unsafe          (unsafePerformIO)



import           Config
import           Orphans                   ()


transfers :: SG.GenTable ERC20.Transfer
transfers = SG.genTable "transfer" []

--transfersChan :: Chan ERC20.Transfer
--transfersChan = unsafePerformIO newChan
--{-# NOINLINE transfersChan #-}

eventLoop :: PGConnectInfo -> Address -> Web3 HttpProvider ThreadId
eventLoop conn addr = event addr $ \t@ERC20.Transfer{} -> do
  liftIO . print $ "Got transfer : " ++ show t
  _ <- liftIO . withPostgreSQL conn $ SG.insertGen_ transfers [t]
  return ContinueEvent

--transfersConsumer :: PGConnectInfo -> IO ()
--transfersConsumer conn = do
--  t <- readChan transfersChan
--  _ <- liftIO . withPostgreSQL conn $ SG.insertGen_ transfers [t]
--  threadDelay 1000000
--  transfersConsumer conn

main :: IO ()
main = do
    config <- mkConfig
    let pgConn = pg config
    withPostgreSQL pgConn . tryCreateTable $ SG.gen transfers
    _ <- runWeb3' $ eventLoop pgConn (erc20Address config)
    loop
  where
    loop = do
      _ <- threadDelay 1000000000
      loop
