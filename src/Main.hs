{-# LANGUAGE DataKinds         #-}
{-# LANGUAGE OverloadedStrings #-}
{-# OPTIONS_GHC -fno-warn-orphans #-}

module Main where

import           Control.Error
import           Control.Concurrent        (ThreadId, threadDelay)
import           Control.Monad             (void)
import           Control.Monad.IO.Class    (liftIO)
import           Database.Selda
import qualified Database.Selda.Generic    as SG
import           Database.Selda.PostgreSQL
import           Data.String                (IsString (..))
import           Network.Ethereum.Web3
import qualified Contracts.ERC20           as ERC20
import           Orphans                   ()
import           System.Environment        (lookupEnv, getEnv)
import qualified Text.Read          as T


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
    eventLoop conn addr = event addr $ \t@(ERC20.Transfer{}) -> do
      liftIO . print $ "Got transfer : " ++ show t
      _ <- liftIO . withPostgreSQL conn $ SG.insertGen_ transfers [t]
      return ContinueEvent

-- config utils

readEnvVar :: Read a => String -> ExceptT String IO a
readEnvVar var = do
  str <- lookupEnv var !? ("Missing Environment Variable: " ++ var)
  T.readMaybe str ?? ("Couldn't Parse Environment Variable: " ++ str)

data Config =
  Config { pg :: PGConnectInfo
         , erc20Address :: Address
         }

mkConfig :: IO Config
mkConfig = do
  ec <- runExceptT $ do
    host <- readEnvVar "PGHOST"
    port <- readEnvVar "PGPORT"
    user <- readEnvVar "PGUSER"
    pass <- readEnvVar "PGPASSWORD"
    db <- readEnvVar "PGDATABASE"
    let pgConn = PGConnectInfo { pgHost = host
                               , pgPort = port
                               , pgUsername = user
                               , pgPassword = pass
                               , pgDatabase = db
                               }
    addr <- fromString <$> readEnvVar "CONTRACT_ADDRESS"
    return $ Config pgConn addr
  either error return ec

data HttpProvider

instance Provider HttpProvider where
  rpcUri = liftIO $ getEnv "NODE_URL"
