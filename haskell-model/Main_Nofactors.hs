module Main where

import DataReader
import GraphData
import Text.Printf (printf)
import Data.List (zip5)

-- Models
logistic k r t0 t = k / (1 + exp (-r * (t - t0)))

gompertz k r t0 t =
    max 100 (k * exp (- exp (-r * (t - t0))))

hybridModel l g = 0.4 * l + 0.6 * g

formatDouble x = printf "%.0f" x

-- CSV writers
writeResultsCSV file rows = do
    let header = "year,actual,logistic,gompertz,hybrid\n"
    let content = concatMap (\(y,a,l,g,h) ->
            show (round y) ++ "," ++
            formatDouble a ++ "," ++
            formatDouble l ++ "," ++
            formatDouble g ++ "," ++
            formatDouble h ++ "\n") rows
    writeFile file (header ++ content)

writeGraphCSV file rows = do
    let header = "year,actual,logistic,gompertz,hybrid\n"
    let content = concatMap (\r ->
            show (year r) ++ "," ++
            show (actual r) ++ "," ++
            show (logisticV r) ++ "," ++
            show (gompertzV r) ++ "," ++
            show (hybridV r) ++ "\n") rows
    writeFile file (header ++ content)

main = do
    evData <- readCSV "../data/ev_sales.csv"

    let actual = map snd evData
    let years = [2010..2030]

    let k = 95000
    let r = 1.2
    let t0 = 2023

    let predLogistic = map (logistic k r t0) years
    let predGompertz = map (gompertz k r (t0 - 1)) years
    let predHybrid   = zipWith hybridModel predLogistic predGompertz

    let actualExtended = actual ++ replicate (length years - length actual) 0
    let combined = zip5 years actualExtended predLogistic predGompertz predHybrid

    let records = map toRecord combined

    -- PRINT
    putStrLn "Year | Actual | Logistic | Gompertz | Hybrid (No Factors)"
    mapM_ (\(y,a,l,g,h) ->
        putStrLn (show (round y) ++ " | " ++
                  formatDouble a ++ " | " ++
                  formatDouble l ++ " | " ++
                  formatDouble g ++ " | " ++
                  formatDouble h)) combined

    -- SAVE FILES
    writeResultsCSV "results_no_factors.csv" combined
    writeGraphCSV   "graph_no_factors.csv" records

    putStrLn "\nFiles generated:"
    putStrLn "results_no_factors.csv"
    putStrLn "graph_no_factors.csv"