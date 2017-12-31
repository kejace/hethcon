{-# LANGUAGE DataKinds         #-}
{-# LANGUAGE OverloadedStrings #-}
{-# OPTIONS_GHC -fno-warn-orphans #-}

module Main where

import qualified Contracts.ERC20           as ERC20
import           Control.Concurrent        (ThreadId, threadDelay)
import           Control.Error
import           Control.Monad             (void)
import           Control.Monad.IO.Class    (liftIO)
import           Data.String               (IsString (..))
import qualified Data.Text                 as T
import           Database.Selda
import qualified Database.Selda.Generic    as SG
import           Database.Selda.PostgreSQL
import           Network.Ethereum.Web3
import           Orphans                   ()
import           System.Environment        (getEnv, lookupEnv)
import qualified Text.Read                 as T


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

-- config utils

readEnvVar :: Read a => String -> ExceptT String IO a
readEnvVar var = do
  str <- lookupEnv var !? ("Missing Environment Variable: " ++ var)
  T.readMaybe str ?? ("Couldn't Parse Environment Variable: " ++ str)

getEnvVar :: String -> ExceptT String IO String
getEnvVar var = lookupEnv var !? ("Missing Environment Variable: " ++ var)

data Config =
  Config { pg           :: PGConnectInfo
         , erc20Address :: Address
         }

mkConfig :: IO Config
mkConfig = do
  ec <- runExceptT $ do
    host <- T.pack <$> getEnvVar "PG_HOST"
    port <- readEnvVar "PG_PORT"
    user <- T.pack <$> getEnvVar "PG_USER"
    pass <- T.pack <$> getEnvVar "PG_PASSWORD"
    db <- T.pack <$> getEnvVar "PG_DATABASE"
    let pgConn = PGConnectInfo { pgHost = host
                               , pgPort = port
                               , pgUsername = Just user
                               , pgPassword = Just pass
                               , pgDatabase = db
                               }
    addr <- fromString <$> getEnvVar "CONTRACT_ADDRESS"
    return $ Config pgConn addr
  either error return ec

data HttpProvider

instance Provider HttpProvider where
  rpcUri = liftIO $ getEnv "NODE_URL"
