{-# LANGUAGE OverloadedStrings #-}

module Main where

import           Network.AMQP
import qualified Data.ByteString.Lazy.Char8 as BL
import           System.Environment

main = do
    conn <- openConnection "127.0.0.1" "/" "guest" "guest"
    chan <- openChannel conn
    args <- getArgs


    let exchange   = "logs"
        routingKey = ""
        msg        = args !! 0

    declareExchange chan $ newExchange { exchangeName = exchange
                                       , exchangeType = "fanout"
                                       }

    publishMsg chan exchange routingKey $ newMsg { msgBody         = BL.pack msg
                                                 , msgDeliveryMode = Just Persistent}
                                                 -- Messages not durable by default

    closeConnection conn
