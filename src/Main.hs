{-# LANGUAGE DataKinds         #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TypeOperators     #-}
{-# LANGUAGE TypeApplications  #-}
{-# LANGUAGE RankNTypes        #-}
{-# OPTIONS_GHC -fno-warn-orphans #-}

module Main where

import qualified Contracts.ERC20           as ERC20
import qualified Contracts.ERC721          as ERC721
import qualified Contracts.UPort           as UPort
import qualified Contracts.A               as A
import qualified Contracts.Exchange        as Exchange
import qualified Contracts.WETH9           as WETH9
import qualified Contracts.CryptoKitties   as CK
import qualified Contracts.KittyCore       as KC
import           Control.Concurrent        (ThreadId, threadDelay)
import           Control.Monad             (void)
import           Data.Default              (def)
import           Data.Proxy                (Proxy(..))
import           GHC.TypeLits              (KnownSymbol, symbolVal)
import           Database.Selda            hiding (def)
import qualified Database.Selda.Generic    as SG
import           Database.Selda.PostgreSQL
import           Network.Ethereum.Web3
import           Network.Ethereum.Web3.Contract (Event(..))
import           Network.Ethereum.Web3.Types (Call (..), TxHash)

import           Config
import           Orphans                   ()

aa :: SG.GenTable A.AA
aa = SG.genTable "aa" []

filled :: SG.GenTable Exchange.Filled
filled = SG.genTable "filled" []

canceled :: SG.GenTable Exchange.Canceled
canceled = SG.genTable "canceled" []

transfer :: SG.GenTable KC.Transfer
transfer = SG.genTable "transfer" []

auctionCreated :: SG.GenTable CK.AuctionCreated
auctionCreated = SG.genTable "auction_created" []

-- mkTable :: forall proxy e
--          . (Event e)
--         => e
--         -> SG.GenTable e
-- mkTable e = SG.genTable (symbolVal e) []

eventLoop :: forall proxy e
           . (Event e)
          => proxy e
          -> PGConnectInfo
          -> Address
          -> Web3 HttpProvider ()
eventLoop e conn addr = do
  let eventType = Proxy :: Proxy e
  let fltr = eventFilter addr
  void $ event fltr $ \event@eventType -> do
    liftIO . print $ "Got Filled: " ++ show event
    _ <- liftIO . withPostgreSQL conn $ SG.insertGen_ filled [event]
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
    withPostgreSQL pgConn . tryCreateTable $ SG.gen auctionCreated
    --let theCall = callFromTo "0x0000000000" (aAddress config)
    --_ <- runWeb3' $ A.aFunction theCall (aAddress config) (fromIntegral $ 123)
    _ <- runWeb3' $ eventLoop (Proxy :: Proxy CK.AuctionCreated) pgConn (contractAddress config)
    loop
  where
    -- this is dumb, but needed to keep the process alive.
    loop = do
      _ <- threadDelay 1000000000
      loop
