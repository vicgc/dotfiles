{-
  This is my xmonad configuration file.
  There are many like it, but this one is mine.

  If you want to customize this file, the easiest workflow goes
  something like this:
    1. Make a small change.
    2. Hit "super-q", which recompiles and restarts xmonad
    3. If there is an error, undo your change and hit "super-q" again to
       get to a stable place again.
    4. Repeat

  Author:     David Brewer
  Repository: https://github.com/davidbrewer/xmonad-ubuntu-conf
-}

import XMonad
import XMonad.Actions.CycleWS
import XMonad.Hooks.SetWMName
import XMonad.Layout.Grid
import XMonad.Layout.ResizableTile
import XMonad.Layout.IM
import XMonad.Layout.ThreeColumns
import XMonad.Layout.NoBorders
import XMonad.Layout.Circle
import XMonad.Layout.PerWorkspace (onWorkspace)
import XMonad.Layout.Fullscreen
import XMonad.Layout.Reflect
import XMonad.Layout.Renamed
import XMonad.Util.EZConfig
import XMonad.Util.Run
import XMonad.Hooks.DynamicLog
import XMonad.Actions.Plane
import XMonad.Hooks.ManageDocks
import XMonad.Hooks.UrgencyHook
import qualified XMonad.StackSet as W
import qualified Data.Map as M
import Control.Monad
import Data.Ratio ((%))


solarizedBase03    = "#002b36"
solarizedBase02    = "#073642"
solarizedBase01    = "#586e75"
solarizedBase00    = "#657b83"
solarizedBase0     = "#839496"
solarizedBase1     = "#93a1a1"
solarizedBase2     = "#eee8d5"
solarizedBase3     = "#fdf6e3"
solarizedYellow    = "#b58900"
solarizedOrange    = "#cb4b16"
solarizedRed       = "#dc322f"
solarizedMagenta   = "#d33682"
solarizedViolet    = "#6c71c4"
solarizedBlue      = "#268bd2"
solarizedCyan      = "#2aa198"
solarizedGreen     = "#859900"

myModMask            = mod4Mask             -- changes the mod key to "super"
myFocusedBorderColor = solarizedBlue      -- color of focused border
myNormalBorderColor  = solarizedBase02    -- color of inactive border
myBorderWidth        = 1                    -- width of border around windows
myTerminal           = "urxvt"              -- which terminal software to use

myTitleLength    = 70         -- truncate window title to this length
myCurrentWSLeft  = "["        -- wrap active workspace with these
myCurrentWSRight = "]"
myVisibleWSLeft  = "["        -- wrap inactive workspace with these
myVisibleWSRight = "]"
myUrgentWSLeft  = "{"         -- wrap urgent workspace with these
myUrgentWSRight = "}"

myWorkspaces = [ "α", "β", "γ", "δ", "ε", "ζ", "η"]

startupWorkspace = "α"  -- which workspace do you want to be on after launch?

{-
  Layout configuration. In this section we identify which xmonad
  layouts we want to use. I have defined a list of default
  layouts which are applied on every workspace, as well as
  special layouts which get applied to specific workspaces.

  Note that all layouts are wrapped within "avoidStruts". What this does
  is make the layouts avoid the status bar area at the top of the screen.
  Without this, they would overlap the bar. You can toggle this behavior
  by hitting "super-b" (bound to ToggleStruts in the keyboard bindings
  in the next section).
-}

-- Define group of default layouts used on most screens, in the
-- order they will appear.
-- "smartBorders" modifier makes it so the borders on windows only
-- appear if there is more than one visible window.
-- "avoidStruts" modifier makes it so that the layout provides
-- space for the status bar at the top of the screen.
defaultLayouts = smartBorders(avoidStruts(
  -- ResizableTall layout has a large master window on the left,
  -- and remaining windows tile on the right. By default each area
  -- takes up half the screen, but you can resize using "super-h" and
  -- "super-l".
  renamed [Replace "R"] (ResizableTall 1 (3/100) (1/2) [])

  -- Mirrored variation of ResizableTall. In this layout, the large
  -- master window is at the top, and remaining windows tile at the
  -- bottom of the screen. Can be resized as described above.
  ||| renamed [Replace "R!"] (Mirror (ResizableTall 1 (3/100) (1/2) []))

  -- Full layout makes every window full screen. When you toggle the
  -- active window, it will bring the active window to the front.
  ||| renamed [Replace "F"] (noBorders Full)

  -- Grid layout tries to equally distribute windows in the available
  -- space, increasing the number of columns and rows as necessary.
  -- Master window is at top left.
  ||| renamed [Replace "#"] (Grid)

  -- ThreeColMid layout puts the large master window in the center
  -- of the screen. As configured below, by default it takes of 3/4 of
  -- the available space. Remaining windows tile to both the left and
  -- right of the master window. You can resize using "super-h" and
  -- "super-l".
  ||| renamed [Replace "3C"] (ThreeColMid 1 (3/100) (3/4))

  -- Circle layout places the master window in the center of the screen.
  -- Remaining windows appear in a circle around it
  ||| renamed [Replace "O"] (Circle)))


-- Here we define some layouts which will be assigned to specific
-- workspaces based on the functionality of that workspace.

-- The chat layout uses the "IM" layout. We have a roster which takes
-- up 1/8 of the screen vertically, and the remaining space contains
-- chat windows which are tiled using the grid layout. The roster is
-- identified using the myIMRosterTitle variable, and by default is
-- configured for Empathy, so if you're using something else you
-- will want to modify that variable.
-- chatLayout = avoidStruts()


chatLayout = renamed [Replace "Chat"] $ avoidStruts $ withIM (0.2) (Title "Buddy List") $ reflectHoriz $ withIM (0.2) isSkype (Grid) where isSkype = (Title "zoresvit - Skype™")

-- Here we combine our default layouts with our specific, workspace-locked
-- layouts.
myLayouts = onWorkspace "η" chatLayout $ defaultLayouts




myManagementHooks :: [ManageHook]
myManagementHooks = [
  resource =? "stalonetray" --> doIgnore
  , resource =? "XXkb" --> doIgnore
  , className =? "rdesktop" --> doFloat
  , (className =? "Iceweasel") --> focusShift "ζ"
  , (className =? "Firefox") --> focusShift "ζ"
  , (className =? "Chromium-browser") --> focusShift "ζ"
  , (className =? "Empathy") --> doF (W.shift "η")
  , (className =? "Pidgin") --> doF (W.shift "η")
  , (className =? "Skype") --> doF (W.shift "η")
  ]
  where
    focusShift = doF . liftM2 (.) W.greedyView W.shift

myKeyBindings =
  [
    ((myModMask, xK_b), sendMessage ToggleStruts)
    , ((myModMask .|. shiftMask, xK_l), sendMessage MirrorShrink)
    , ((myModMask .|. shiftMask, xK_h), sendMessage MirrorExpand)
    -- Shift to previous workspace
    , ((myModMask, xK_Left), prevWS)
    -- Shift to next workspace
    , ((myModMask, xK_Right), nextWS)
    -- Shift window to previous workspace
    , ((myModMask .|. shiftMask, xK_Left), shiftToPrev)
    -- Shift window to next workspace
    , ((myModMask .|. shiftMask, xK_Right), shiftToNext)
    , ((myModMask, xK_u), focusUrgent)
    , ((myModMask .|. controlMask, xK_l), spawn "gnome-screensaver-command -l")
    , ((myModMask, xK_p), spawn "dmenu_run -i -nb '#002b36' -nf  '#839496' -sb '#073642' -sf '#93a1a1' -fn 'Liberation Mono-14'")
    , ((myModMask .|. controlMask, xK_l), spawn "xscreensaver-command -lock")
    -- Volume control
    , ((myModMask .|. controlMask, xK_m), spawn "amixer -D pulse set Master 1+ toggle")
    , ((myModMask .|. controlMask, xK_Down), spawn "amixer -q -c 1 set Master 10%-")
    , ((myModMask .|. controlMask, xK_Up), spawn "amixer -q -c 1 set Master 10%+")
    -- Brightness control
    , ((myModMask .|. controlMask, xK_Left), spawn "xbacklight -dec 10")
    , ((myModMask .|. controlMask, xK_Right), spawn "xbacklight -inc 10")
  ]


main = do
  xmproc <- spawnPipe "xmobar ~/.xmobarrc"
  xmonad $ withUrgencyHook NoUrgencyHook $ defaultConfig {
        borderWidth = myBorderWidth
      , focusedBorderColor = myFocusedBorderColor
      , handleEventHook = fullscreenEventHook
      , layoutHook = myLayouts
      , manageHook = manageHook defaultConfig
          <+> composeAll myManagementHooks
          <+> manageDocks
      , modMask = myModMask
      , normalBorderColor = myNormalBorderColor
      , startupHook = do
          spawn "~/.xmonad/startup_hook.sh"
      , terminal = myTerminal
      , workspaces = myWorkspaces
      , logHook = dynamicLogWithPP $ xmobarPP {
            ppOutput = hPutStrLn xmproc
          , ppCurrent = xmobarColor solarizedGreen "" . wrap myCurrentWSLeft myCurrentWSRight
          , ppHidden = xmobarColor solarizedBase0 ""
          , ppHiddenNoWindows = xmobarColor solarizedBase02 ""
          , ppLayout = xmobarColor solarizedCyan ""
          , ppTitle = xmobarColor solarizedBase1 "" . shorten myTitleLength
          , ppUrgent = xmobarColor solarizedRed "" . wrap myUrgentWSLeft myUrgentWSRight
          , ppVisible = xmobarColor solarizedBase01 "" . wrap myVisibleWSLeft myVisibleWSRight
          }
      } `additionalKeys` myKeyBindings
