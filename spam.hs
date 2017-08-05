import Control.Concurrent
import Control.Monad

import Data.ByteString.Char8 (isPrefixOf)

import XHotkey
import BoX11.Basic
import BoX11.X (portKM)

main = runX $ do
    win <- currentWindow
    win' <- liftIO $ getForeground
    cls <- liftIO $ getClass win'
    when ("GxWindow" `isPrefixOf` cls) $ do
        setTargets [win]
        _grabKeyboard
        let getkm = do
            km <- waitKM
            if keyUp km then
                getkm
            else
                return km
        km <- getkm
        _ungrabKeyboard
        (mods, vk) <- portKM km
        bind [km] exitX

        mvar <- liftIO $ newEmptyMVar

        let parLoop = do
            withPosted mods win' (postKey vk win')
            threadDelay 125000
            parLoop

        liftIO $ forkIO $ parLoop
        mainLoop
        liftIO $ putMVar mvar ()

