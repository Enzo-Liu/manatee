-- Author:     Andy Stewart <lazycat.manatee@gmail.com>
-- Maintainer: Andy Stewart <lazycat.manatee@gmail.com>
-- 
-- Copyright (C) 2010 ~ 2011 Andy Stewart, all rights reserved.
-- 
-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- any later version.
-- 
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
-- 
-- You should have received a copy of the GNU General Public License
-- along with this program.  If not, see <http://www.gnu.org/licenses/>.

import Distribution.PackageDescription
import Distribution.Simple
import Manatee.Core.Config
import Manatee.Core.Dynload
import Manatee.Core.Types
import Manatee.Toolkit.Cabal.Utils
import Manatee.Extension.IrcClient.PageMode

import qualified Data.Map as M

main = defaultMainWithHooks 
       simpleUserHooks {
         -- Generate User.hs and Import.hs before configure.
         preConf = \ _ _ -> do
             generateConfig "IrcClient.hs"
                           ["actionMsgColor","joinMsgColor","otherMsgColor"
                           ,"partMsgColor","quitMsgColor","selfMsgColor"
                           ,"serverMsgColor","urlColor","wrapColumn"
                           ,"timeStampPosition", "sourceLanguage", "targetLanguage"
                           ,"showLineNumber"
                           ,"defaultNick", "defaultServer", "defaultPort", "defaultChannel"
                           ]
              
             return emptyHookedBuildInfo
         -- Update PageTypeRule after install successful.
        ,postInst = \ _ _ pack_des lbi -> do
             (PageTypeRule rule) <- readConfig pageTypeRulePath (PageTypeRule M.empty)
             writeConfig pageTypeRulePath (PageTypeRule (M.insert "PageIrc" "manatee-ircclient" rule))
             -- Update PageModeRule.
             (PageModeRule modeRule) <- readConfig pageModeRulePath (PageModeRule M.empty)
             writeConfig pageModeRulePath (PageModeRule 
                                                (M.insert "PageIrc" (Left $ pageModeName ircMode) modeRule))
             -- Update ExtensionGloalKeymap.
             (ExtensionGloalKeymap keymap) <- readConfig extensionGlobalKeymapPath (ExtensionGloalKeymap M.empty)
             writeConfig extensionGlobalKeymapPath (ExtensionGloalKeymap
                                                    (M.insert "F6" ("Irc Client",
                                                                    ("PageIrc", "irc://", [])) keymap))
             -- Update Application info.
             let snapshotPath = getDataFilePath pack_des lbi "data/welcome/snapshot.png"
             (WelcomeApplication apps) <- readConfig welcomeApplicationPath (WelcomeApplication M.empty)
             writeConfig welcomeApplicationPath (WelcomeApplication
                                                 (M.insert 
                                                       ("Irc Client", snapshotPath)
                                                       ("PageIrc", "irc://", [])
                                                       apps))
       }

