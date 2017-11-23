#!/usr/bin/runhaskell
{-# LANGUAGE TypeSynonymInstances, FlexibleInstances #-}

import Data.Char
import Data.List
import System.Environment
import Text.Printf

class Show' a => Justifiable a where
    just :: Int -> a -> String

class Show' a where
    show' :: a -> String

instance Show' Integer where
    show' = show

instance Show' String where
    show' str = str

data J a = JL a | JR a

instance Show' a => Show' (J a) where
    show' (JL a) = show' a
    show' (JR a) = show' a

instance Show' a => Justifiable (J a) where
    just n (JL a) = printf "%.-*s" n (show' a)
    just n (JR a) = printf "%.*s" n (show' a)

columned :: Justifiable a => [[a]] -> String
columned js = unlines $ fmap unwords $ fmap (zipWith ($) (just <$> widths)) $ js
  where
      widths = maximum <$> fmap (length' . show') <$> js

columned' :: [[String]] -> String
columned' ss = unlines $ fmap unwords $ fmap (zipWith ($) (pf <$> widths)) $ ss
  where
      widths = maximum <$> fmap length' <$> transpose ss
      pf n x = printf "%-*s" (n + length x - length' x) x

length' :: String -> Int
length' ('\ESC':xs) = length' (dropWhile (/= '\STX') xs) -1
length' (x:xs) = 1 + length' xs
length' [] = 0

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

        merge :: [String] -> [String] -> String
        merge xs ys = concat $ zipWith 
                      (merge' (maximum $ length <$> xs)) xs (ys ++ repeat "")
        merge' n x y = printf "%-*s   %s\n" n x y

        show' :: [Range] -> [String]
        show' xs = fmap (\(R name a b) -> printf " %s%*s  %s%*s %s- %s%s%s"
            (col []) mnam name (col [31]) mlen (show a) (col [39]) (col [33]) 
            (show b) (col [])) xs where
                mnam = maximum $ (\(R n _ _) -> length $ n) <$> xs
                mlen = maximum $ (\(R _ a _) -> length $ show a) <$> xs

rdf = Rs [ R "Ragefire Chasm"     15 21
         , R "Deadmines"          15 25
         , R "Wailling Caverns"   15 25
         , R "Shadowfang Keep"    16 26
         , R "Blackfathom Deeps"  19 29

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

data Class = Warrior | Paladin | DeathKnight | Shaman | Hunter | Druid | Rogue
              | Priest | Warlock | Mage
              deriving (Eq, Ord)
classes = [Warrior, Paladin, DeathKnight, Shaman, Hunter, Druid, Rogue, Priest
          , Warlock, Mage]

instance Show Class where
    show cls = (\(cs,str) -> col [48,5,cs,1,30] ++ str ++ col []) $ case cls of
        Warrior     -> (95,  "Warrior")
        Paladin     -> (212, "Paladin")
        DeathKnight -> (124, "Death Knight")
        Shaman      -> (27,  "Shaman")
        Hunter      -> (83,  "Hunter")
        Druid       -> (166, "Druid")
        Rogue       -> (185, "Rogue")
        Priest      -> (7,   "Priest")
        Warlock     -> (98,  "Warlock")
        Mage        -> (86,  "Mage")

d1 :: String
d1 = columned'
    [ f Warrior   "" ""
--  , g           "Head"      "[Schol] Gandling"
--  , g           "Shoulder"  "[UBRS]  Rend Blackhand"
--  , g           "Chest"     "[UBRS]  Drakkisath"
--  , g           "Wrists"    ".LBRS.  Firebrand/Smolderthorn"
    , g           "Hands"     "[Strat] Ramstein"
    , g           "Waist"     ".Strat. Patchwork Horror"
--  , g           "Legs"      "[Strat] Rivendare"
    , g           "Feet"      "[Schol] Kirtonos"

    , f Paladin   "" ""
--  , g           "Head"      "[Schol] Gandling"
--  , g           "Shoulder"  "[UBRS]  The Beast"
--  , g           "Chest"     "[UBRS]  Drakkisath"
    , g           "Wrists"    ".Schol. Risen Prot/Warr"
    , g           "Hands"     "[Strat] Timmy the Cruel"
    , g           "Waist"     ".Strat. Rockwing"
--  , g           "Legs"      "[Strat] Rivendare"
--  , g           "Feet"      "[Strat] Balnazzar"

    , f Shaman    "" ""
--  , g           "Head"      "[Schol] Gandling"
    , g           "Shoulder"  "[UBRS]  Gyth"
--  , g           "Chest"     "[UBRS]  Drakkisath"
    , g           "Wrists"    ".Strat. Crypt Beast/Crawler"
--  , g           "Hands"     "[UBRS]  Pyroguard"
    , g           "Waist"     ".LBRS.  Smolderthorn/Flamescale"
--  , g           "Legs"      "[Strat] Rivendare"
--  , g           "Feet"      "[LBRS]  Omokk"

    , f Hunter    "" ""
    , g           "Head"      "[Schol] Gandling"
--  , g           "Shoulder"  "[UBRS]  Wyrmthalak"
    , g           "Chest"     "[UBRS]  Drakkisath"
    , g           "Wrists"    ".Strat. Fleshflayer Ghoul"
--  , g           "Hands"     "[LBRS]  Voone"
    , g           "Waist"     ".LBRS.  Firebrand/Smolderthorn"
    , g           "Legs"      "[Strat] Rivendare"
--  , g           "Feet"      "[LBRS]  Omokk"

--  , f Priest    "" ""
--  , g           "Head"      "[Schol] Gandling"
--  , g           "Shoulder"  "[UBRS]  Solakar"
--  , g           "Chest"     "[UBRS]  Drakkisath"
--  , g           "Wrists"    ".Strat. trash"
--  , g           "Hands"     "[Strat] Galford"
--  , g           "Waist"     ".LBRS.  trash"
--  , g           "Legs"      "[Strat] Rivendare"
--  , g           "Feet"      "[Strat] Maleki"

    , f Warlock   "" ""
    , g           "Head"      "[Schol] Gandling"
--  , g           "Shoulder"  "[Schol] Jandice Barov"
--  , g           "Chest"     "[UBRS]  Drakkisath"
    , g           "Wrists"    ".LBRS.  Dreadweaver/Summoner/Seer"
--  , g           "Hands"     "[Schol] Polkelt"
    , g           "Waist"     ".Strat. Necromancer/Shadowcaster"
--  , g           "Legs"      "[Strat] Rivendare"
--  , g           "Feet"      "[Strat] Anastari"

    , f Mage      "" ""
--  , g           "Head"      "[Schol] Gandling"
--  , g           "Shoulder"  "[Schol] Ras"
--  , g           "Chest"     "[UBRS]  Drakkisath"
    , g           "Wrists"    ".LBRS.  Fire Tongue/Pyromancer"
--  , g           "Hands"     "[Schol] Doctor Theolen"
    , g           "Waist"     ".LBRS.  Battle Mage/Mystic/Sorc"
--  , g           "Legs"      "[Strat] Rivendare"
    , g           "Feet"      "[Strat] Forresten"
    ] where
      f x y z = [show x, y, z]
      g y z = ["", y, z]

main :: IO ()
main = do
    args <- getArgs
    let arg = case args of
          [] -> "rdf"
          (x:_) -> x
    case arg of
        "mining"  -> mapM_ print mining
        "rdf"     -> putStr (show rdf)
        "d1"      -> putStr d1

-- util
col [] = col [0]
col xs = "\ESC[" ++ foldl1 (\s s' -> s ++ ";" ++ s') (show <$> xs) ++ "m\STX"
