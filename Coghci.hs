#!/usr/bin/env runhaskell

{-# LANGUAGE OverloadedStrings #-}

import Control.Monad

import Data.ByteString.Char8 as B
import qualified Data.ByteString.Lazy.Char8 as BL
import Data.List as L

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
    [Color Red]                 [Color Cyan]                 [Bold]            
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

esc :: [Int] -> ByteString
esc ms = B.pack $ 
        "\ESC[" ++ L.foldl1 (\s s' -> s ++ ";" ++ s') (show <$> ms) ++ "m\STX"

escR :: ByteString 
escR = "\ESC[0m\STX"

colorize :: [Mod] -> ByteString -> ByteString
colorize ms str = esc (modN <$> ms) `B.append` str `B.append` escR

type P = Parsec ByteString ()

recol :: Scheme -> P ByteString
recol sch = choice
  [ do -- Punctuation symbols: (,),{,,
      col (sPunc sch) (many1 $ oneOf puncs)
  , do -- Syntax symbols: ::, =>, -<, lambda
      try $ coldel (sSynt sch) (choice (try . string <$> synts)) (oneOf symbols)
  , do -- Keywords
      try $ col (sKWords sch) (choice (try . string <$> keywords))
  , do -- Operators and their combinations: >>=, <>, ||
      col (sSymbol sch) (many1 $ oneOf symbols)
  , do -- skip unknown
      liftM2 B.append (B.singleton <$> anyChar) r
  , do
      eof
      return ""
  ] where

  r :: P ByteString
  r = recol sch

  col :: [Mod] -> P String -> P ByteString
  col mods op = liftM2 (\a b -> colorize mods (B.pack a) `B.append` b) op r

  coldel :: Show a => [Mod] -> P String -> P a -> P ByteString
  coldel mods op outs = do
      a <- op
      notFollowedBy outs
      col mods (return a) 
  

keywords :: [String]
keywords = [ "data", "type", "newtype", "instance", "class", "where", "let"
           , "family", "role", "if", "then", "else", "case", "of" ]

synts :: [String]
synts = L.sortOn (negate . L.length) 
        ["[", "]", "#", "@", "|", "=", "\\", "->", "<-", "-<", "::", "=>", "->"]

puncs :: [Char]
puncs = "(){},"

symbols :: [Char]
symbols = "~!$%^*-+=|&/.><"

-- instance Read Line where
--     readPrec = (return $ Line []) +++ do
--         l <- lexP
--         (\x -> x { unLine = l : unLine x }) <$> readPrec
-- 
-- rm :: String -> String
-- rm str = maybe str (show . unLine) (readMaybe str :: Maybe Line)

main :: IO ()
main = BL.interact (onlines id) -- (onlines (\s -> either (pure s) id $ parse (recol hscolour) "" s))
    where
    onlines f = BL.unlines . fmap f . BL.lines 
