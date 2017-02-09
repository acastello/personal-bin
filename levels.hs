#!/usr/bin/runhaskell

import Data.Char
import Data.List
import System.Environment
import Text.Printf

data Level = L4 String Int Int Int Int | L3 String Int Int Int

instance Show Level where
    show (L4 name a b c d) = printf "%s%20s  %s%3s %s%3s %s%3s %s%3s%s"
            (col [1]) name (col [31]) (show a) (col [33]) (show b) 
            (col [32]) (show c) (col [0]) (show d) (col [])
    show (L3 name a b c) = printf "%s%20s      %s%3s %s%3s %s%3s%s"
            (col [1]) name (col [33]) (show a) 
            (col [32]) (show b) (col [0]) (show c) (col [])

mining = [ L4 "Copper Vein" 0 25 50 100
         , L4 "Smelt Copper" 0 25 47 70
         , L3 "Smelt Tin" 65 70 75
         , L3 "Smelt Bronze" 65 90 115
         , L4 "Tin Vein" 65 80 115 165
         , L4 "Incendite Vein" 65 80 115 165
         , L4 "Silver Vein" 75 115 125 175
         , L4 "Smelt Silver" 75 115 122 130
         , L4 "Iron Deposit" 125 150 175 230
         , L4 "Smelt Iron" 125 130 145 160
         , L4 "Gold Vein" 155 180 205 0
         , L4 "Smelt Gold" 155 170 180 185
         , L4 "Mithril Deposit" 175 200 225 0
         , L3 "Smelt Mithril" 175 202 230
         , L4 "Truesilver Deposit" 210 0 0 0
         ]

data Range = R String Int Int
newtype Ranges = Rs [Range]

instance Show Ranges where
    show (Rs xs) =
        if length xs > 10 then
            merge (show' xs') (show' xs'')
        else
            merge (show' xs) [] where

        (xs', xs'') = let (a,b) = length xs `divMod` 2 in splitAt (a+b) xs

        merge xs ys = concat $ zipWith 
                      (merge' (maximum $ length <$> xs)) xs (ys ++ repeat "")
        merge' n x y = printf "%-*s   %s\n" n x y

        show' :: [Range] -> [String]
        show' xs = fmap (\(R name a b) -> printf " %s%*s  %s%*s %s- %s%s%s"
            (col []) mnam name (col [31]) mlen (show a) (col [39]) (col [33]) 
            (show b) (col [])) xs where
                mnam = maximum $ (\(R n _ _) -> length $ n) <$> xs
                mlen = maximum $ (\(R _ a _) -> length $ show a) <$> xs

rdf = Rs [ R "Ragefire Chasm"     15 22
         , R "Deadmines"          15 25
         , R "Wailling Caverns"   15 25

         , R "Razorfen Kraul"     22 32
         , R "Gnomeregan"         23 33
         , R "SM: Graveyard"      27 37
         , R "SM: Library"        30 40
         , R "Razorfen Downs"     32 42
         , R "SM: Armory"         32 42
         , R "SM: Cathedral"      35 45
         , R "Uldaman"            35 45
         , R "Maraudon: Purple"   39 49
         , R "Maraudon: Orange"   41 51
         , R "Zul'Farrak"         41 51
         , R "Maraudon: Pristine" 43 53
         , R "Sunken Temple"      45 55
         , R "BRD: Prison"        47 57
         , R "BRD: Upper City"    51 60
         , R "Dire Maul: East"    53 60
         , R "LBRS"               55 60
         , R "Dire Maul: West"    56 60
         , R "Dire Maul: North"   57 60
         , R "Scholomance"        57 60
         , R "Stratholme: Living" 57 60
         , R "Stratholme: Undead" 57 60
         ]

main :: IO ()
main = do
    args <- getArgs
    let arg = case args of
          [] -> "rdf"
          (x:_) -> x
    case arg of
        "mining"  -> foldMap print mining
        "rdf"     -> putStr (show rdf)

-- util
col [] = col [0]
col xs = "\ESC[" ++ foldl1 (\s s' -> s ++ ";" ++ s') (show <$> xs) ++ "m\STX"
