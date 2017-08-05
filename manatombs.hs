import Control.Concurrent
import Control.Monad

import Data.ByteString.Char8 (isPrefixOf)

import System.Environment

import XHotkey
import BoX11.Basic
import BoX11.X (portKM)
import WoW.Wotlk.Core
import WoW.Wotlk.Box

main = do
    args <- getArgs
    if any (== "-X") args then return ()
        -- wows <- getWins byClassEx "GxWindowClass.*"
        -- print wows
        -- liftIO $ forM wows $ forkIO . parLoop
        -- runX $ do
            -- bind ["2"] exitX
            -- mainLoop
    else runX $ do
        win <- currentWindow
        win' <- liftIO $ getForeground
        cls <- liftIO $ getClass win'
        when ("GxWindow" `isPrefixOf` cls) $ do
            setTargets [win]
            Just pid <- liftIO $ currentWoW

            bind ["2"] exitX
            liftIO $ forkIO $ parLoop win' pid
            mainLoop

parLoop win pid = do
    let d = 3700000
    runWoW' pid $ tpRefreshed $ Point (Just $ -110.25) (Just $ -254.33) (Just $ 14.80) (Just $ -pi/2) Nothing Nothing
    postKey (vk_num 5) win
    threadDelay 1000000
    runWoW' pid $ tpRefreshed $ Point (Just $ -91.1) (Just $ -260.63) (Just $ 14.80) (Just $ -pi/2) Nothing Nothing
    replicateM 5 $ do
        postKey (vk_num 6) win
        threadDelay d
    parLoop win pid
