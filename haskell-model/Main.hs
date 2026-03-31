{-# LANGUAGE OverloadedStrings #-}

module Main where

import Text.Printf (printf)
import Data.Char (isSpace)
import Data.List (mapAccumL)
import Data.Maybe (mapMaybe)

-- =========================================================================
-- CORE MATHEMATICAL MODELS (Double -> Double -> Double -> Double -> Double)
-- =========================================================================

logistic :: Double -> Double -> Double -> Double -> Double
logistic k r t0 t = k / (1 + exp (-r * (t - t0)))

gompertz :: Double -> Double -> Double -> Double -> Double
gompertz k r t0 t = k * exp (- exp (-r * (t - t0)))

bassModel :: Double -> Double -> Double -> Double -> Double
bassModel p q m t =
    let t_rel = t - 2010
        expTerm = exp (-(p + q) * t_rel)
    in m * ((1 - expTerm) / (1 + (q / p) * expTerm))

arimaxStep :: Double -> Double -> Double -> Double -> Double
arimaxStep prev gdp oil batt =
    let tam = 2200000.0 
        growth = 0.10 + (gdp / 1e13) * 0.4 + (oil / 100) * 0.12 - (batt / 150) * 0.25 
        dampened = growth * (1 - (prev / tam))
    in prev * (1 + max (min dampened 0.25) 0.01)

-- =========================================================================
-- DATA UTILITIES (Explicitly Typed to resolve GHC-39999)
-- =========================================================================

splitBy :: Char -> String -> [String]
splitBy _ "" = []
splitBy c s = let (w, rest) = break (== c) s 
              in w : case rest of { [] -> []; (_:xs) -> splitBy c xs }

parseLine :: String -> Maybe (Double, Double)
parseLine line =
    case splitBy ',' line of
        [a,b] -> let cleanA = filter (not . isSpace) a
                     cleanB = filter (not . isSpace) b
                 in if null cleanA || null cleanB then Nothing
                    else Just (read cleanA, read cleanB)
        _ -> Nothing

readCSV :: FilePath -> IO [(Double, Double)]
readCSV file = do
    content <- readFile file
    return $ mapMaybe parseLine (drop 1 $ lines content)

formatActual :: Maybe Double -> String
formatActual (Just v) = printf "%.0f" v
formatActual Nothing  = "-"

lookupActual :: Int -> [(Double, Double)] -> Maybe Double
lookupActual year rows =
    case [v | (y, v) <- rows, round y == year] of
      (v:_) -> Just v
      []    -> Nothing

-- =========================================================================
-- MAIN RESEARCH FORECAST LOOP
-- =========================================================================

main :: IO ()
main = do
    putStrLn "\n=== [UNIVERSITY RESEARCH] EV ADOPTION MODEL (2010-2040) ==="

    -- 1. Setup Timelines and Load Data
    let years = [2010 .. 2040] :: [Int]
    evData   <- readCSV "../data/ev_sales.csv"
    gdpData  <- readCSV "../data/gdp.csv"
    oilData  <- readCSV "../data/oil_prices.csv"
    battData <- readCSV "../data/battery_prices.csv"

    let actualHistory = map snd evData
    let lastActualYear = if null evData then 2024 else round (fst (last evData))

    -- 2. Regressor Projections
    let lastGdp = if null gdpData then 4.0e12 else last (map snd gdpData)
    let gdpVals = take (length years) $ map snd gdpData ++ [lastGdp * (1.05 ** fromIntegral i) | i <- [1..30]]
    
    let lastOil = if null oilData then 75.0 else last (map snd oilData)
    let oilVals = take (length years) $ map snd oilData ++ repeat lastOil

    let battFuture = [100, 92, 85, 78, 70, 65, 62, 60, 58, 56, 55] 
    let battVals = take (length years) $ map snd battData ++ battFuture ++ repeat 50.0

    -- 3. Run Models
    let k_val = 2200000.0
    let logisticVals = map (logistic k_val 0.42 2026.0 . fromIntegral) years
    let gompertzVals = map (gompertz k_val 0.25 2029.0 . fromIntegral) years
    let bassVals     = map (bassModel 0.00015 0.42 k_val . fromIntegral) years
    let arimaxVals   = buildArimax actualHistory gdpVals oilVals battVals (length years)

    -- 4. Hybrid Ensemble logic
    let actualExt = actualHistory ++ replicate (length years - length actualHistory) 0
    let rawHybrid = zipWith (\y (b, g, a) ->
            let (wB, wG, wA) = if y < 2025 then (0.5, 0.3, 0.2) else (0.2, 0.7, 0.1)
                pred = (wB * b) + (wG * g) + (wA * a)
                idx = y - 2010
                corrected = if y <= lastActualYear 
                            then pred + 0.90 * ((actualExt !! idx) - pred) 
                            else pred
            in corrected
          ) years (zip3 bassVals gompertzVals arimaxVals)

    -- Post-processing: Smooth and Cap
    let finalHybrid = map (min 2150000.0) rawHybrid

    -- 5. Final Output Table
    let csvRows = [ (y, lookupActual y evData, logisticVals !! (y-2010), gompertzVals !! (y-2010), finalHybrid !! (y-2010)) | y <- years ]
    
    printf "%-6s | %-12s | %-12s | %-12s | %-12s\n" ("YEAR"::String) ("ACTUAL"::String) ("LOGISTIC"::String) ("GOMPERTZ"::String) ("HYBRID"::String)
    putStrLn $ replicate 70 '-'
    mapM_ printRow csvRows
    
    writeCSV "research_output_2040.csv" csvRows
    putStrLn "\nFile 'research_output_2040.csv' saved successfully."

-- =========================================================================
-- PRINTING & EXPORT (Explicit signatures to fix Ambiguity)
-- =========================================================================

printRow :: (Int, Maybe Double, Double, Double, Double) -> IO ()
printRow (y, a, l, g, h) = 
    printf "%-6d | %-12s | %-12.0f | %-12.0f | %-12.0f\n" y (formatActual a) l g h

writeCSV :: FilePath -> [(Int, Maybe Double, Double, Double, Double)] -> IO ()
writeCSV f rows = do
    let header = "Year,Actual,Logistic,Gompertz,Hybrid\n"
    let content = unlines [ printf "%d,%s,%.2f,%.2f,%.2f" y (formatActual a) l g h | (y,a,l,g,h) <- rows ]
    writeFile f (header ++ content)

buildArimax :: [Double] -> [Double] -> [Double] -> [Double] -> Int -> [Double]
buildArimax h g o b n = case h of { [] -> replicate n 0; (f:_) -> go 0 [f] }
  where
    go i acc | i == n - 1 = acc
             | otherwise = let prev = if i+1 < length h then h !! i else last acc
                               next = arimaxStep prev (g !! (i+1)) (o !! (i+1)) (b !! (i+1))
                           in go (i+1) (acc ++ [next])