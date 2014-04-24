{-# LANGUAGE OverloadedStrings #-}

module Main where

import qualified Data.ByteString.Lazy.Char8 as BL
import qualified Data.List            as L
import qualified Data.Text            as T
import           Network.AMQP
import           System.Environment

main = do
    conn <- openConnection "127.0.0.1" "/" "guest" "guest"
    chan <- openChannel conn
    args <- getArgs

    let exName     = "topic_logs"
        routingKey = T.pack $ args !! 0
        message    = L.intercalate " " $ tail args

    declareExchange chan $ newExchange { exchangeName = exName
                                       , exchangeType = "topic"
                                       }

    publishMsg chan exName routingKey $ newMsg { msgBody = BL.pack message }

    closeConnection conn
