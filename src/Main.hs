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


import           Control.Concurrent.MVar   (newMVar, putMVar, takeMVar)
import           Control.Concurrent        (threadDelay, forkIO)
import           Control.Monad             (void, forM_)
import qualified Data.Set                  as S
import           Data.Monoid
import           Database.Selda            hiding (def)
import qualified Database.Selda.Generic    as SG
import           Database.Selda.PostgreSQL
import           Network.Ethereum.Web3
import           Network.Ethereum.Web3.Types (Filter(..), DefaultBlock(..))
import           Network.Ethereum.Web3.Address (toText)
import           Network.Ethereum.Web3.Contract (Event(..))
import           System.IO

import           Config
import           Orphans                   ()
import           Relay
import           Relay.DB                  (radarOrders, dexOrders)

filledData :: SG.GenTable Exchange.LogFill
filledData = SG.genTable "LogFill" []


eventLoop :: Config
          -> Web3 HttpProvider ()
eventLoop (Config conn addr relay) = do
    let fltr = (eventFilter addr  :: Filter Exchange.LogFill) {filterFromBlock = BlockWithNumber 4157011 }
    knownTokenPairs <- liftIO $ newMVar S.empty
    void $ eventMany' fltr 1000 $ \e@Exchange.LogFill{..} -> do
      liftIO . print $ "Got LogFill: " ++ show e
      _ <- liftIO . withPostgreSQL conn $ SG.insertGen_ filledData [e]
      pairs <- liftIO $ takeMVar knownTokenPairs
      let newPair@(makerToken, takerToken) = ("0x" <> toText logFillMakerToken_, "0x" <> toText logFillTakerToken_)
      if newPair `S.member` pairs
        then liftIO $ do
          print $ "Found Known Token Pair : " ++ show newPair
          putMVar knownTokenPairs pairs
        else liftIO $ do
          print $ "Found New Token Pair : " ++ show newPair
          setupRadarSocket conn makerToken takerToken
          setupDexSocket conn makerToken takerToken
          putMVar knownTokenPairs $ S.insert newPair pairs
      return ContinueEvent
  where
    setupRadarSocket pg makerAddr takerAddr = do
      let payload = WebsocketReqPayload makerAddr takerAddr True 100
          handler = \(OrderBook asks bids) -> do
            _ <- withPostgreSQL pg $ SG.insertGen_ radarOrders asks
            _ <- withPostgreSQL pg $ SG.insertGen_ radarOrders bids
            return True
      print $ "Forking Socket Client : " ++ show payload
      forkIO $ mkRadarClientApp payload handler

    setupDexSocket pg makerAddr takerAddr = do
      let payload = WebsocketReqPayload makerAddr takerAddr True 100
          handler o = do
            _ <- withPostgreSQL pg $ SG.insertGen_ dexOrders [o]
            return True
      print $ "Forking Socket Client : " ++ show payload
      forkIO $ mkERCDexClientApp payload handler

main :: IO ()
main = do
    hSetBuffering stdout LineBuffering
    hSetBuffering stderr LineBuffering

    putStrLn "Hello transfer-indexer"
    config <- mkConfig
    let pgConn = pg config
    withPostgreSQL pgConn . tryCreateTable $ SG.gen filledData
    withPostgreSQL pgConn . tryCreateTable $ SG.gen radarOrders
    withPostgreSQL pgConn . tryCreateTable $ SG.gen dexOrders
    _ <- runWeb3' $ eventLoop config
    loop
  where
    -- this is dumb, but needed to keep the process alive.
    loop = do
      _ <- threadDelay 1000000000
      loop
