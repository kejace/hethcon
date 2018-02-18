module Config where


import           Control.Error
import           Control.Monad.IO.Class    (liftIO)
import           Data.String               (IsString (..))
import qualified Data.Text                 as T
import           Database.Selda.PostgreSQL
import           Network.Ethereum.Web3
import           System.Environment        (getEnv, lookupEnv)
import qualified Text.Read                 as T

import           Relay

readEnvVar :: Read a => String -> ExceptT String IO a
readEnvVar var = do
  str <- lookupEnv var !? ("Missing Environment Variable: " ++ var)
  T.readMaybe str ?? ("Couldn't Parse Environment Variable: " ++ str)

getEnvVar :: String -> ExceptT String IO String
getEnvVar var = lookupEnv var !? ("Missing Environment Variable: " ++ var)

data Config =
  Config { pg                  :: PGConnectInfo
         , contractAddress     :: Address
         , relayEnv            :: ClientEnv
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
    relay <- liftIO $ mkRelayClientEnv "api.radarrelay.com" "/0x/v0" 80
    return $ Config pgConn addr relay
  either error return ec

data HttpProvider

instance Provider HttpProvider where
  rpcUri = liftIO $ getEnv "NODE_URL"
