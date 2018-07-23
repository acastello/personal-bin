#!/usr/bin/env runhaskell

import Control.Concurrent
import Control.Monad

import Data.List as L

import System.IO
import Text.Parsec

data Color = Black | Red | Green | Yellow | Blue | Magenta | Cyan | White
    deriving (Show, Eq)

data Mod = Color Color | Bold | Underlined
    deriving (Show, Eq)

-- type Token = ([Mod], Lexeme)
-- 
data Scheme = Scheme
  { sChar   :: [Mod]
  , sString :: [Mod]
  , sNumber :: [Mod]
  , sSynt   :: [Mod]
  , sPunc   :: [Mod]
  , sIdent  :: [Mod]
  , sSymbol :: [Mod]
  , sKWords :: [Mod]
  , sComms  :: [Mod]
  , sAddons :: [((String -> Bool), Mod)]
  }

hscolour :: Scheme
hscolour = Scheme 
    [Color Magenta]             [Color Magenta]             [Color Magenta]
    [Color Cyan]                [Color Red]                 [Bold]            
    [Color Cyan]                [Color Green, Underlined]   [Color Blue]      
    []

modN :: Mod -> Int
modN m = case m of
    Color Black ->    90
    Color Red ->      91
    Color Green ->    92
    Color Yellow ->   93
    Color Blue ->     94
    Color Magenta ->  95
    Color Cyan ->     96
    Color White ->    97
    Bold ->           1
    Underlined ->     4

esc :: [Int] -> String
esc ms = "\ESC[" ++ foldl1 (\s s' -> s ++ ";" ++ s') (show <$> ms) ++ "m\STX"

escR :: String 
escR = "\ESC[0m\STX"

colorize :: [Mod] -> String -> String
colorize ms str = esc (modN <$> ms) ++ str ++ escR

type P = Parsec String ()

recol :: Scheme -> P String
recol sch = choice
  [ do -- Syntax symbols: ::, =>, -<, lambda
      try $ coldel (sPunc sch) (choice (try . string <$> puncs)) (oneOf symbols)
  , do -- Keywords
      try $ col (sKWords sch) (choice (try . string <$> keywords))
  , do -- Operators and their combinations: >>=, <>, ||
      col (sSymbol sch) (many1 $ oneOf symbols)
  , do -- skip unknown
      liftM2 (:) anyChar r
  , do
      eof
      return []
  ] where

  r :: P String
  r = recol sch

  col :: [Mod] -> P String -> P String
  col mods op = liftM2 (\a b -> colorize mods a ++ b) op r

  coldel :: Show a => [Mod] -> P String -> P a -> P String
  coldel mods op outs = do
      a <- op
      notFollowedBy outs
      col mods (return a) 
  

keywords :: [String]
keywords = [ "data", "type", "newtype", "instance", "class", "where", "let"
           , "family", "role", "if", "then", "else", "case", "of" ]

puncs :: [String]
puncs = L.sortOn (negate . length) 
        ["#", "@", "|", "=", "\\", "->", "<-", "-<", "::", "=>", "->"]

symbols :: [Char]
symbols = "~!$%^*-+=|&/.><"

fLine :: (String -> String) -> IO ()
fLine f = fl "" where
    fl str = do
        c <- hLookAhead stdin
        if c == '\n' then do
            threadDelay 10000
            putStrLn (f str)
            void getLine
            fLine f
        else do
            _ <- hGetChar stdin
            fl (str ++ [c])

intlines :: (String -> String) -> IO ()
intlines f = do
    ls <- lines <$> (sequence (repeat getChar))
    forM_ ls $ \l -> do
        forM_ (f <$> words l) putStr
        putStrLn ""


main :: IO ()
main = do
    hSetBuffering stdout NoBuffering
    forever (getChar >>= \c -> threadDelay 1000 >> putChar c)
    -- intlines (\s -> either (pure s) id $ parse (recol hscolour) "" s)
