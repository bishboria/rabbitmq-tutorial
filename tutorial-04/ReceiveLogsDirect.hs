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

    let exchange      = "direct_logs"
        prefetchSize  = 0 -- Don't care how big the task size is
        prefetchCount = 1 -- Only one message at a time
    qos chan prefetchSize prefetchCount -- One worker, one task to work on.
                                        -- New message picked up after ack sent

    declareExchange chan $ newExchange { exchangeName = exchange
                                       , exchangeType = "direct"
                                       }
    (q, _, _) <- declareQueue chan $ newQueue { queueExclusive = True } -- don't care about this queue

    mapM_ (\routingKey -> bindQueue chan q exchange $ pack routingKey) args

    consumeMsgs chan q Ack callback

    getLine -- Wait for keypress
    closeConnection conn
    putStrLn "Connection closed"

callback :: (Message,Envelope) -> IO ()
callback (msg, env) = do
    let body = BL.unpack $ msgBody msg
    putStrLn . show $ body
    putStrLn ""
    ackEnv env
