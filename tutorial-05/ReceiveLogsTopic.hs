{-# LANGUAGE OverloadedStrings #-}

module Main where

import qualified Data.ByteString.Lazy.Char8 as BL
import qualified Data.Text            as T
import           Network.AMQP
import           System.Environment

main = do
    conn <- openConnection "127.0.0.1" "/" "guest" "guest"
    chan <- openChannel conn
    args <- getArgs

    let exName = "topic_logs"
        routingKeys = map T.pack args

    declareExchange chan $ newExchange { exchangeName = exName
                                       , exchangeType = "topic"
                                       }

    (q, _, _) <- declareQueue chan $ newQueue { queueExclusive = True } -- don't care about this queue
    mapM_ (\routingKey -> bindQueue chan q exName routingKey) routingKeys

    consumeMsgs chan q Ack callback

    getLine -- Wait for keypress
    closeConnection conn
    putStrLn "Connection closed"

callback :: (Message,Envelope) -> IO ()
callback (msg, env) = do
    let body = BL.unpack $ msgBody msg
    putStrLn body
    putStrLn ""
    ackEnv env
