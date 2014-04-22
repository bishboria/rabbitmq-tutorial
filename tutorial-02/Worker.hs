{-# LANGUAGE OverloadedStrings #-}

module Main where

import           Network.AMQP
import qualified Data.ByteString.Lazy.Char8 as BL
import           Control.Concurrent

main = do
    conn <- openConnection "127.0.0.1" "/" "guest" "guest"
    chan <- openChannel conn

    declareQueue chan $ newQueue {queueName = "hello"} -- Queues are Durable by default
    let prefetchSize  = 0 -- Don't care how big the task size is
        prefetchCount = 1 -- Only one message at a time
    qos chan prefetchSize prefetchCount -- One worker, one task to work on.
                                        -- New message picked up after ack sent

    let queue = "hello"
    consumeMsgs chan queue Ack callback

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
