module GraphData where

data EVRecord = EVRecord
    { year       :: Int
    , actual     :: Double
    , logisticV  :: Double
    , gompertzV  :: Double
    , hybridV    :: Double
    }

toRecord :: (Double, Double, Double, Double, Double) -> EVRecord
toRecord (y,a,l,g,h) =
    EVRecord (round y) a l g h