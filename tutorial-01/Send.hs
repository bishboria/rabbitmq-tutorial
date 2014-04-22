{-# LANGUAGE OverloadedStrings #-}

module Main where

import           Network.AMQP
import qualified Data.ByteString.Lazy.Char8 as BL

main = do
    conn <- openConnection "127.0.0.1" "/" "guest" "guest"
    chan <- openChannel conn

    declareQueue chan $ newQueue {queueName = "hello"}

    let exchange   = ""
        routingKey = "hello"
        msg        = "Hello, World!"
    publishMsg chan exchange routingKey $ newMsg {msgBody = BL.pack msg}

    closeConnection conn
