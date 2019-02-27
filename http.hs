#!/bin/runhaskell
module Main where

import Control.Monad
import qualified Data.ByteString.Char8 as BS
import System.IO

main :: IO ()
main = do
    forever $ do
        c <- BS.hGet stdin 1
        BS.hPut stderr (BS.drop 1 $ BS.init $ BS.pack $ show c)
