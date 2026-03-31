module DataReader (readCSV) where

import Data.Maybe (mapMaybe)

readCSV :: FilePath -> IO [(Double, Double)]
readCSV file = do
    content <- readFile file
    let ls = lines content
    let rows = drop 1 ls
    return $ mapMaybe parseLine rows

parseLine :: String -> Maybe (Double, Double)
parseLine line =
    case splitBy ',' line of
        [a,b] ->
            let cleanA = filter (/= ' ') a
                cleanB = filter (/= ' ') b
            in if null cleanA || null cleanB then Nothing
               else Just (read cleanA, read cleanB)
        _ -> Nothing

splitBy :: Char -> String -> [String]
splitBy _ "" = []
splitBy c s =
    let (w, rest) = break (== c) s
    in w : case rest of
        []     -> []
        (_:xs) -> splitBy c xs