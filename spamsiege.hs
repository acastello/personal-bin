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
            bind ["2"] exitX
            mainLoop
    else runX $ do
        win <- currentWindow
        win' <- liftIO $ getForeground
        cls <- liftIO $ getClass win'
        when ("GxWindow" `isPrefixOf` cls) $ do
            setTargets [win]

            bind ["2"] exitX
            liftIO $ forkIO $ parLoop win'
            mainLoop

parLoop win = do
    let d = 30000
    postKey (vk_char 'T') win
    threadDelay d
    postKey (vk_num 2) win
    threadDelay d
    parLoop win
