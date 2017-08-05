import Control.Concurrent
import Control.Monad

import Data.ByteString.Char8 (isPrefixOf)

import System.Environment

import XHotkey
import BoX11.Basic
import BoX11.X (portKM)

main = do
    args <- getArgs
    if any (== "-X") args then do
        wows <- getWins byClassEx "GxWindowClass.*"
        print wows
        liftIO $ forM wows $ forkIO . parLoop
        runX $ do
            bind ["6"] exitX
            mainLoop
    else runX $ do
        win <- currentWindow
        win' <- liftIO $ getForeground
        cls <- liftIO $ getClass win'
        when ("GxWindow" `isPrefixOf` cls) $ do
            setTargets [win]

            bind ["6"] exitX
            liftIO $ forkIO $ parLoop win'
            mainLoop

parLoop win = do
    postKey (vk_num 6) win
    threadDelay 500000
    clickProp 1 0.5 0.5 win
    threadDelay 9000000
    parLoop win
