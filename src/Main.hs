{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE QuasiQuotes #-}
{-# LANGUAGE DataKinds #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE TemplateHaskell #-}

module Main where

import Network.Ethereum.Web3
import Network.Ethereum.Web3.TH

[abiFrom|data/ERC20.json|]

{-
-- generated event types and instances

data Approval
  = Approval {-# NOUNPACK #-} !Address {-# NOUNPACK #-} !Address {-# NOUNPACK #-} !Integer
  deriving (Show, Eq, Ord, GHC.Generics.Generic)
instance Generic Approval

data Transfer
   = Transfer {-# NOUNPACK #-} !Address {-# NOUNPACK #-} !Address {-# NOUNPACK #-} !Integer
   deriving (Show, Eq, Ord, GHC.Generics.Generic)
 instance Generic Transfer

-}

main :: IO ()
main = do
  putStrLn "hello world"
