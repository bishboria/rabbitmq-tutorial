{-# LANGUAGE OverloadedStrings #-}

module Main where

import           Network.AMQP
import qualified Data.ByteString.Lazy.Char8 as BL
import           Data.Text
import           System.Environment

main = do
    conn <- openConnection "127.0.0.1" "/" "guest" "guest"
    chan <- openChannel conn
    args <- getArgs


    let exchange   = "direct_logs"
        severity   = args !! 0
        msg        = args !! 1

    declareExchange chan $ newExchange { exchangeName = exchange
                                       , exchangeType = "direct"
                                       }

    publishMsg chan exchange (pack severity) $ newMsg { msgBody         = BL.pack msg
                                                      , msgDeliveryMode = Just Persistent }
                                                 -- Messages not durable by default

    closeConnection conn
