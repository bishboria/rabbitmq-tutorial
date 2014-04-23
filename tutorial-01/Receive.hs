{-# LANGUAGE OverloadedStrings #-}

module Main where

import           Network.AMQP
import qualified Data.ByteString.Lazy.Char8 as BL

main = do
    conn <- openConnection "127.0.0.1" "/" "guest" "guest"
    chan <- openChannel conn

    declareQueue chan $ newQueue {queueName = "hello"}

    let queue = "hello"
    consumeMsgs chan queue NoAck callback

    getLine -- Wait for keypress
    closeConnection conn
    putStrLn "Connection closed"

callback :: (Message,Envelope) -> IO ()
callback (msg, env) = do
    putStrLn . BL.unpack $ msgBody msg
    putStrLn ""
