{-# LANGUAGE OverloadedStrings #-}

module Main where

import           Network.AMQP
import qualified Data.ByteString.Lazy.Char8 as BL
import           System.Environment

main = do
    conn <- openConnection "127.0.0.1" "/" "guest" "guest"
    chan <- openChannel conn
    declareQueue chan $ newQueue {queueName = "hello"} -- Queues are Durable by default

    args <- getArgs

    let exchange   = ""
        routingKey = "hello"
        msg        = args !! 0
    publishMsg chan exchange routingKey $ newMsg { msgBody         = BL.pack msg
                                                 , msgDeliveryMode = Just Persistent}
                                                 -- Messages not durable by default

    closeConnection conn
