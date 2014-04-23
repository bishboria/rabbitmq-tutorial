{-# LANGUAGE OverloadedStrings #-}

module Main where

import           Network.AMQP
import qualified Data.ByteString.Lazy.Char8 as BL
import           Control.Concurrent

main = do
    conn <- openConnection "127.0.0.1" "/" "guest" "guest"
    chan <- openChannel conn

    let exchange   = "logs"
        routingKey = ""
        prefetchSize  = 0 -- Don't care how big the task size is
        prefetchCount = 1 -- Only one message at a time
    qos chan prefetchSize prefetchCount -- One worker, one task to work on.
                                        -- New message picked up after ack sent

    declareExchange chan $ newExchange { exchangeName = exchange
                                       , exchangeType = "fanout"
                                       }
    (q, _, _) <- declareQueue chan $ newQueue { queueExclusive = True } -- don't care about this queue
    bindQueue chan q exchange routingKey

    consumeMsgs chan q Ack callback

    getLine -- Wait for keypress
    closeConnection conn
    putStrLn "Connection closed"

callback :: (Message,Envelope) -> IO ()
callback (msg, env) = do
    let body      = BL.unpack $ msgBody msg
        sleepTime = length $ filter (\x -> x == '.') body
    putStrLn . show $ body
    threadDelay $ 1000000 * sleepTime -- threadDelay takes μSeconds
    putStrLn ""
    ackEnv env
