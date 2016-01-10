--Divers
import XMonad
import XMonad.Config.Azerty
import Control.Monad (liftM2)
import XMonad.Util.Run(spawnPipe)
import XMonad.Util.EZConfig(additionalKeysP)
import qualified XMonad.StackSet as W
import System.IO
import XMonad.Util.Scratchpad

--Hooks
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.ManageDocks
import XMonad.Hooks.ManageHelpers
import XMonad.Hooks.InsertPosition

--Layouts
import XMonad.Layout.NoBorders
import XMonad.Layout.IM
import XMonad.Layout.PerWorkspace
import XMonad.Layout.Spacing
import XMonad.Layout.Grid

--IM
import Data.Ratio ((%))

--Terminal préféré
--myTerminal = "gnome-terminal"
myTerminal = "urxvt"

--Raccourcis
myKeys =
    -- Multimedia Keys
        [ ("<XF86AudioPlay>", spawn "audtool --playback-playpause")
        , ("C-<XF86AudioLowerVolume>", spawn "audtool --playlist-reverse")
        , ("C-<XF86AudioRaiseVolume>", spawn "audtool --playlist-advance")
        , ("<XF86AudioMute>", spawn "amixer sset DAC 5%")
        , ("<XF86AudioLowerVolume>", spawn "amixer sset DAC 5%-")
        , ("<XF86AudioRaiseVolume>", spawn "amixer sset DAC 5%+")
        , ("S-<XF86AudioLowerVolume>", spawn "amixer sset DAC 1%-")
        , ("S-<XF86AudioRaiseVolume>", spawn "amixer sset DAC 1%+")
        , ("<XF86HomePage>", spawn "firefox")
        , ("<XF86Search>", spawn "nautilus --no-desktop")
        , ("<XF86Favorites>", spawn "")
        , ("<XF86Mail>", spawn "thunderbird")
        , ("<XF86Calculator>", spawn "gcalctool")
        , ("<XF86Tools>", spawn "audacious")
        , ("C-<XF86Tools>", spawn "audtool --playback-stop")
        , ("<XF86Explorer>", spawn "~/Documents/Scripts/Programme_tv")
        , ("C-<XF86Explorer>", spawn "~/Documents/Scripts/tv")
        , ("<Print>", spawn "sleep 0.2; scrot -s '%Y%m%d%H%M%S.png' -e 'mv $f ~/Images/Captures/'")
        , ("C-<Print>", spawn "scrot '%Y%m%d%H%M%S.png' -e 'mv $f ~/Images/Captures/'")
        , ("<XF86AudioStop>", spawn "audtool --playback-stop")
        , ("<XF86AudioPrev>", spawn "audtool --playlist-reverse")
        , ("<XF86AudioNext>", spawn "audtool --playlist-advance")
        , ("<XF86Documents>", spawn "nautilus --no-desktop")
        , ("C-<XF86Sleep>", spawn "gksudo poweroff")
        , ("M-p", spawn "gmrun")
        , ("M-g", spawn "gramps")
        , ("M-s", spawn "shotwell")
        , ("M-w", scratchPad)
        ]
        where
         scratchPad = scratchpadSpawnActionTerminal "urxvt -pe tabbed"

--Workspaces
myWorkspaces = ["1", "2M", "3w", "4Z", "5F", "6B", "7P", "8o", "9C"]

--Hooks
myLayout = onWorkspace "2M" tiersLayout $ onWorkspace "3w" tiersLayout $ onWorkspace "4Z" zikLayout $ onWorkspace "9C" imLayout $ standardLayouts
  where
   standardLayouts = avoidStruts $ smartBorders $ (Mirror tiled ||| tiled ||| Full)
   tiled = Tall nmaster delta ratio
   nmaster = 1
   ratio = 1/2
   delta = 3/100
   imLayout = avoidStruts $ smartBorders $ withIM (1/5) (Role "roster") gridLayout ||| standardLayouts
   gridLayout = Grid 
   tiersLayout = avoidStruts $ smartBorders $ (Mirror tiers ||| tiers ||| Full)
    where
     tiers = Tall nmastertiers deltatiers ratiotiers
     nmastertiers = 1
     deltatiers = 3/100
     ratiotiers = 66/100
   zikLayout = avoidStruts $ smartBorders $ (zik ||| Mirror zik ||| Full)
    where
     zik = Tall nmasterzik deltazik ratiozik
     nmasterzik = 2
     deltazik = 3/100
     ratiozik = 72/100

myManageHook = (composeAll
   [ className =? "Rhythmbox" --> doShift "4Z"
   , resource =? "vdpau" --> doFloat
   , resource =? "vdpau" --> doShift "5F"
   , className =? "Gimp" --> doShift "7P"
   , className =? "Thunderbird" --> doShift "2M"
   , role =? "Msgcompose" --> doFloat
   , role =? "Preferences" --> doFloat
   , role =? "filterlist" --> doFloat
   , role =? "EventDialog" --> doFloat
   , role =? "certmanager" --> doFloat
   , role =? "AlarmWindow" --> doFloat
   , className =? "Xmessage"  --> doFloat
   , className =? "Firefox" --> doShift "3w"
   , className =? "Boincmgr" --> doShift "6B"
   , className =? "F-spot" --> doShift "7P"
   , className =? "Shotwell" --> doShift "7P"
   , className =? "Zenity" --> doFloat
   , className =? "Empathy" --> doShift "9C"
   , className =? "Gajim" --> doShift "9C"
   --A-- and float everything but the roster
   --A-- , classNotRole ("Gajim", "roster") --> doFloat
   , className =? "Mumble" --> doShift "9C"
   , className =? "Bombono-dvd" --> doShift "5F"
   , className =? "Devede" --> doShift "5F"
   , className =? "Photivo" --> doShift "7P"
   , className =? "Rawtherapee" --> doShift "7P"
   , className =? "Remmina" --> doShift "1"
   , className =? "VirtualBox" --> doShift "8o"
   , className =? "Cinelerra" --> doShift "5F"
   , className =? "Avidemux" --> doShift "5F"
   , className =? "Ghb" --> doShift "5F"
   , className =? "Vmplayer" --> doShift "8o"
   , className =? "Freetuxtv" --> doShift "5F"
   , className =? "Audacious" --> doShift "4Z"
   , className =? "Inkscape" --> doShift "7P"
   , resource =? "canto-xmonad" --> doShift "6B"
   , resource =? "file_properties" --> doFloat
   , (className /=? "Audacious" <&&> fmap not isDialog <&&> role /=? "Msgcompose" <&&> role /=? "Preferences" <&&> role /=? "filterlist" <&&> role /=? "EventDialog" <&&> role /=? "certmanager" <&&> role /=? "AlarmWindow") --> insertPosition Below Newer
   , manageDocks
   ])
   <+> manageScratchPad
   where
     --A-- classNotRole :: (String, String) -> Query Bool
     --A-- classNotRole (c,r) = className =? c <&&> role /=? r
    role = stringProperty "WM_WINDOW_ROLE"

--Scratchpad config
manageScratchPad :: ManageHook
manageScratchPad = scratchpadManageHook (W.RationalRect l t w h)
  where
    h = 0.25   -- terminal height, 25%
    w = 0.98   -- terminal width, 98%
    t = 0.72   -- distance from top edge, 72%
    l = 0.01   -- distance from left edge, 1%

--myStartupHook = do
--    spawn "xmobar ~/.xmobar/xmobarrc2"

--Variables persos
----THEMES /!\ géré en auto par script saisons
--myTheme = "#A52A2A" --Thème Automne
--myTheme = "#000080" --Thème Été
myTheme = "#009698" --Thème Hiver
--myTheme = "#00CC3A" --Thème Noel
--myTheme = "#FFD700" --Thème Printemps

main = do
    xmproc <- spawnPipe "xmobar ~/.xmobar/xmobarrc"
    xmonad $  azertyConfig
        { workspaces = myWorkspaces
	, terminal = myTerminal
        , manageHook = myManageHook <+> manageHook defaultConfig
        , handleEventHook = docksEventHook
	, layoutHook = myLayout
        , logHook = dynamicLogWithPP xmobarPP
                        { ppOutput = hPutStrLn xmproc
                        , ppTitle = xmobarColor "blue" "" . shorten 50
                        , ppCurrent = xmobarColor myTheme "" . wrap "{" "}"
                        }
--        , startupHook = myStartupHook
        , modMask = mod4Mask     -- Touche Super
        , focusedBorderColor = myTheme -- Couleur coutour fenêtre qui a focus
        , borderWidth = 4
        } `additionalKeysP` myKeys

