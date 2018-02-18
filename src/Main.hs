{-# LANGUAGE DataKinds         #-}
{-# LANGUAGE RecordWildCards   #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TypeOperators     #-}
{-# LANGUAGE TypeApplications  #-}
{-# LANGUAGE RankNTypes        #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# OPTIONS_GHC -fno-warn-orphans #-}

module Main where

import qualified Contracts.Exchange        as Exchange

import           Control.Concurrent        (threadDelay)
import           Control.Monad             (void, forM_)
import           Database.Selda            hiding (def)
import qualified Database.Selda.Generic    as SG
import           Database.Selda.PostgreSQL
import           Network.Ethereum.Web3
import           Network.Ethereum.Web3.Types (Filter(..), DefaultBlock(..))
import           Network.Ethereum.Web3.Address (toText)
import           Network.Ethereum.Web3.Contract (Event(..))

import           Config
import           Orphans                   ()
import           Relay

filledData :: SG.GenTable Exchange.LogFill
filledData = SG.genTable "LogFill" []

eventLoop :: Config
          -> Web3 HttpProvider ()
eventLoop (Config conn addr relay) = do
  let fltr = (eventFilter addr  :: Filter Exchange.LogFill) {filterFromBlock = BlockWithNumber 4148002 }
  liftIO $ print $ show fltr
  void $ eventMany' fltr 1000 $ \e@Exchange.LogFill{..} -> do
    liftIO . print $ "Got LogFill: " ++ show e
    _ <- liftIO . withPostgreSQL conn $ SG.insertGen_ filledData [e]
    orders <- liftIO $ runClientM (getExchangeOrders (Just 10) (Just 1) [] [] [] [] [toText logFillMaker_] [toText logFillTaker_] [] []) relay
    case orders of
      Left err -> error $ show err
      Right os -> do
       if os == []
         then liftIO . print $ ("No ORDERS" :: String)
         else forM_ orders $ liftIO . print
    return ContinueEvent

main :: IO ()
main = do
    putStrLn "Hello transfer-indexer"
    config <- mkConfig
    let pgConn = pg config
    withPostgreSQL pgConn . tryCreateTable $ SG.gen filledData
    _ <- runWeb3' $ eventLoop config
    loop
  where
    -- this is dumb, but needed to keep the process alive.
    loop = do
      _ <- threadDelay 1000000000
      loop
