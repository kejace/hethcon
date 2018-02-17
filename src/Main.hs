{-# LANGUAGE DataKinds         #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TypeOperators     #-}
{-# LANGUAGE TypeApplications  #-}
{-# LANGUAGE RankNTypes        #-}
{-# LANGAUGE FlexibleContexts  #-}
{-# OPTIONS_GHC -fno-warn-orphans #-}

module Main where

import qualified Contracts.ERC20           as ERC20
import qualified Contracts.ERC721          as ERC721
import qualified Contracts.Exchange        as Exchange
import qualified Contracts.WETH9           as WETH9

import           Control.Concurrent        (ThreadId, threadDelay)
import           Control.Monad             (void)
import           Data.Default              (def)
import           Data.String               (fromString)
import           Data.Proxy                (Proxy(..))
import           GHC.TypeLits              (KnownSymbol, symbolVal)
import           Database.Selda            hiding (def)
import qualified Database.Selda.Generic    as SG
import           Database.Selda.PostgreSQL
import           Network.Ethereum.Web3
import           Network.Ethereum.Web3.Contract (Event(..))
import           Network.Ethereum.Web3.Types (Call (..), TxHash)

import           GHC.Generics              (Generic(..))
import           Data.Typeable

import           Config
import           Orphans                   ()

filledData :: SG.GenTable Exchange.LogFill
filledData = SG.genTable "LogFill" []

eventLoop :: PGConnectInfo
          -> Address
          -> Web3 HttpProvider ()
eventLoop conn addr = do
  let fltr = eventFilter addr
  void $ event fltr $ \event@Exchange.LogFill{} -> do
    liftIO . print $ "Got LogFill: " ++ show event
    _ <- liftIO . withPostgreSQL conn $ SG.insertGen_ filledData [event]
    return ContinueEvent

lastOfThree :: (a :*: b :*: c) -> c
lastOfThree (_ :*: _ :*: c) = c

callFromTo from to =
         def { callFrom = Just from
             , callTo   = to
             , callGasPrice = Just 4000000000
             }

main :: IO ()
main = do
    config <- mkConfig
    let pgConn = pg config
    withPostgreSQL pgConn . tryCreateTable $ SG.gen filledData
    _ <- runWeb3' $ eventLoop pgConn (contractAddress config)
    loop
  where
    -- this is dumb, but needed to keep the process alive.
    loop = do
      _ <- threadDelay 1000000000
      loop
