import Control.Concurrent
import Control.Monad

import Data.ByteString.Char8 (isPrefixOf)
import Data.List hiding (isPrefixOf)

import XHotkey
import BoX11.Basic
import BoX11.X (portKM)

import System.Environment

main = do
    args <- drop 1 <$> getArgs
    case args of
        "-f" : strs -> do
            w <- getForeground
            forev (vkt . read <$> init strs) (vkt $ read $ last strs) w
        _ -> runX $ do
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

forev :: [Key] -> Key -> HWND -> IO ()
forev mods k w = do
    withPosted mods w (postKey k w)
    threadDelay 125000
    forev mods k w
