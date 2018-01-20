#!/usr/bin/env runhaskell

import Control.Monad

import Data.List as L

import Text.Parsec

-- data Color = Black | Red | Green | Yellow | Blue | Magenta | Cyan | White
--     deriving (Show, Eq)
-- 
-- data Mod = Color Color | Bold | Underlined
--     deriving (Show, Eq)
-- 
-- type Token = ([Mod], Lexeme)
-- 
-- keywords :: [String]
-- keywords = [ "data", "type", "newtype", "instance", "class", "where", "let"
--            , "family", "role", "if", "then", "else", "case", "of" ]
-- 
-- data Scheme = Scheme
--   { sChar :: Token
--   , sString :: Token
--   , sPunc   :: Token
--   , sIdent  :: Token
--   , sSymbol :: Token
--   , sNumber :: Token
--   , sKeys   :: Token
--   , sAddons :: [((String -> Bool), Token)]
--   }
-- 
-- modN :: Mod -> Int
-- modN m = case m of
--     Color Black ->    90
--     Color Red ->      91
--     Color Green ->    92
--     Color Yellow ->   93
--     Color Blue ->     94
--     Color Magenta ->  95
--     Color Cyan ->     96
--     Color White ->    97
--     Bold ->           1
--     Underlined ->     4
-- 
-- esc :: [Mod] -> String
-- esc ms = "\ESC[" ++ foldl1 (\s s' -> s ++ ";" ++ s') (show . modN <$> ms) ++ "m\STX"
-- 
-- escR :: String 
-- escR = "\ESC[0m\STX"
-- 
-- newtype Line = Line { unLine :: [Lexeme] }

rec :: Parsec String () String
rec = choice
  [ do
      string ">"
      liftM ('?':) rec
  , do
      liftM2 (:) anyChar rec
  , do
      string "=>"
      liftM ('!':) rec
  , do
      eof
      return []
  ]

-- instance Read Line where
--     readPrec = (return $ Line []) +++ do
--         l <- lexP
--         (\x -> x { unLine = l : unLine x }) <$> readPrec
-- 
-- rm :: String -> String
-- rm str = maybe str (show . unLine) (readMaybe str :: Maybe Line)
-- 
-- main :: IO ()
-- main = interact (show . words)
