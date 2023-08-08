module Keymap (
 viewKeymap
) where

import Data.Map as M
import XMonad
import XMonad.Util.Run
import System.IO (hClose)


getKeyCodes :: M.Map (ButtonMask, KeySym) (X ()) -> X [KeyCode]
getKeyCodes keybinds = do
  let keySyms = snd <$> M.keys keybinds
  d <- display <$> ask
  liftIO $ mapM (keysymToKeycode d) keySyms


viewKeymap :: Map (ButtonMask, KeySym) (X ()) -> String -> X ()
viewKeymap keyConfig scriptPath = do
  keyCodes <- getKeyCodes keyConfig
  h <- spawnPipe $ "bash "<>scriptPath<>" | zathura -"
  liftIO
    ( do
      mapM_ (hPutStrLn h) (show <$> keyCodes)
      hClose h
    )