#Requires AutoHotkey v2.0
#NoTrayIcon

;########## SPECIAL KEYS ##########
;    ^  for Ctrl
;    !  for Alt
;    #  for Win
;    +  for Shift
; <^>!  for AltGr
;########## SPECIAL TEXT ##########
;  {Enter}  or  `n  for return



;######################################## GENERAL FUNCTIONS AND VARIABLES ########################################

USER := EnvGet("USERNAME")

GetSelectedText() {
  ClipSaved := ClipboardAll()
  SendEvent "^c"
  SelectedText := StrReplace(A_Clipboard, "/", "\")
  A_Clipboard := ClipSaved
  return SelectedText
}

GetSelectedFile() {
  shell := ComObject("Shell.Application")
  for window in shell.Windows {
    if (window.HWND = WinGetID("A")) {
      selectedItems := window.Document.SelectedItems
      if (selectedItems.Count > 0) {
        return selectedItems.Item(0).Path
      }
    }
  }
  return ""
}

GetExplorerPath() {
  shell := ComObject("Shell.Application")
  for window in shell.Windows {
    if (window.HWND = WinGetID("A")) {
      return window.Document.Folder.Self.Path
    }
  }
  return ""
}

EnvReplace(path) {
  pos := 1
  while (pos := RegExMatch(path, "i)%(\w+)%", &match, pos)) {
    envVal := EnvGet(match[1])
    if (envVal)
      path := StrReplace(path, match[0], envVal)
    pos += StrLen(match[0])
  }
  return path
}

PasteText(text) {
  A_Clipboard := text
  SendInput("^v")
  return text
}



;######################################## AUTOCLICKER ########################################

global autoClickerOn := false ; INIT: `false` = NOT ACTIVE

+Esc::{
  global
  autoClickerOn := !autoClickerOn
  if (autoClickerOn)
    ToolTip("AutoClicker ON")
  else
    ToolTip("AutoClicker OFF")
  SetTimer () => ToolTip(), -600
}

~$LButton::{
  global
  if (autoClickerOn) {
    KeyWait("LButton", "T0.5")
    if (A_TimeIdleKeyboard > 500)
      while (GetKeyState("LButton", "P"))
        Click()
  }
}

~$RButton::{
  global
  if (autoClickerOn) {
    KeyWait("RButton", "T0.5")
    if (A_TimeIdleKeyboard > 500)
      while (GetKeyState("RButton", "P"))
        Click()
  }
}



;######################################## CODE OPERATIONS ########################################

; CONVERT SELECTED TEXT TO UPPERCASE
^+u::{
  selectedText := GetSelectedText()
  if (selectedText != "")
  {
    PasteText(StrUpper(selectedText))
  }
}

; CONVERT SELECTED TEXT TO LOWERCASE
^+l::{
  selectedText := GetSelectedText()
  if (selectedText != "")
  {
    PasteText(StrLower(selectedText))
  }
}

; WEBSEARCH SELECTED TEXT
^+s::{
  selectedText := GetSelectedText()
  if (selectedText)
    Run("https://www.google.com/search?q=" . selectedText)
}



;######################################## LOCK PC ########################################

; PRESS WIN+< TO LOCK COMPUTER
#<::DllCall("LockWorkStation")

; PRESS WIN+SHIFT+< TO LOCK COMPUTER ANDPUT COMPUTER TO SLEEP
#+<::{
    ; WAIT FOR THE RELEASE OF THE KEYS
    KeyWait "<", "U"
    KeyWait "LWin", "U"
    KeyWait "Shift", "U"
    ; PUT THE COMPUTER TO SLEEP
    SendMessage(0x112, 0xF170, 2,, "Program Manager")
}

; PRESS WIN+CTRL+< TO LOCK COMPUTER ANDPUT COMPUTER TO HIBERNATE
#^<::{
    ; WAIT FOR THE RELEASE OF THE KEYS
    KeyWait "<", "U"
    KeyWait "LWin", "U"
    KeyWait "Ctrl", "U"
    ; PUT THE COMPUTER TO HIBETNATE
    DllCall("PowrProf\SetSuspendState", "int", 1, "int", 0, "int", 0)
}


;######################################## LAUNCH APPS ########################################

;########## LAUNCH BROWSER ##########
launch_browser(dev_mode:=false) {
  paths := [
    'C:\Program Files\Google\Chrome Dev\Application\chrome.exe',
    'C:\Program Files\Google\Chrome\Application\chrome.exe',
    'C:\Program Files\Mozilla Firefox\firefox.exe',
    'C:\Program Files\Opera GX\Launcher.exe',
    'C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe'
  ]
  params := dev_mode ? '--incognito' : ''
  for path in paths {
    if FileExist(path) {
      Run('"' path '" ' params)
      return
    }
  }
}

$#!b::launch_browser()
$#^b::launch_browser(true)

;########## OPEN SELECTED FILE WITH APP ##########
; VisualStudioCode
$#!v::{
  winClass := WinGetClass("A")
  if (winClass = "CabinetWClass" or winClass = "ExploreWClass") {
      selectedFile := GetSelectedFile()
      if (selectedFile) {
          Run "C:\Users\" USER '\AppData\Local\Programs\Microsoft VS Code\Code.exe "' selectedFile '"'
      } else {
          Run "C:\Users\" USER "\AppData\Local\Programs\Microsoft VS Code\Code.exe"
      }
  } else {
      Run "C:\Users\" USER "\AppData\Local\Programs\Microsoft VS Code\Code.exe"
  }
}

;########## LAUNCH IN CURRENT DIRECTORY / SELECTED PATH ##########
; FileExplorer
$#e::{
  if (WinGetClass("A") = "CabinetWClass" or WinGetClass("A") = "ExploreWClass") {
    currentDir := GetExplorerPath()
    if (currentDir) {
      Run('explorer.exe "' currentDir '"')
    } else {
      Run("explorer.exe")
    }
  } else {
    selectedText := GetSelectedText()
    path := EnvReplace(selectedText)
    if (FileExist(path)) {
      Run('explorer.exe "' path '"')
    } else {
      Run("explorer.exe")
    }
  }
}

; WindowsTerminal
$#!c::{
  if (WinGetClass("A") = "CabinetWClass" or WinGetClass("A") = "ExploreWClass") {
    currentDir := GetExplorerPath()
    if (currentDir) {
      Run('wt.exe -d "' currentDir '"')
    } else {
      Run "wt.exe"
    }
  } else {
    selectedText := GetSelectedText()
    path := EnvReplace(selectedText)
    if (FileExist(path)) {
      Run('wt.exe -d "' path '"')
    } else {
      Run "wt.exe"
    }
  }
}



;######################################## IN-APP OPERATIONS ########################################

; PRESS CTRL+F2 TO TOGGLE HIDDEN FILES DISPLAY
^F2::{
  id := WinExist("A")
  class := WinGetClass(id)
  if (class = "CabinetWClass" || class = "ExploreWClass") {
    rootKey := "HKEY_CURRENT_USER"
    subKey := "Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
    hiddenStatus := RegRead(rootKey . "\" . subKey, "Hidden")
    if (hiddenStatus = 2)
      RegWrite(1, "REG_DWORD", rootKey . "\" . subKey, "Hidden")
    else
      RegWrite(2, "REG_DWORD", rootKey . "\" . subKey, "Hidden")
    PostMessage(0x111, 41504, , , "ahk_id " id)
  }
}



;######################################## ADD/REMAP SHORTCUTS ########################################

; DISABLE THE DEFAULT BEHAVIORS
; !Tab::Return

; REMAP SHORTCUTS
^Tab::SendInput("!{Tab}")



;######################################## MORE KEYBOARD COMBINATIONS ########################################

<^>!t:: SendInput "™"
<^>!c:: SendInput "©"
<^>!r:: SendInput "®"

<^>!.:: SendInput "·"
<^>!+.:: SendInput "•"

<^>!-:: SendInput "–"
<^>!+-:: SendInput "±"
<^>!+7:: SendInput "÷"
<^>!x:: SendInput "×"

<^>!p:: SendInput "¶"
<^>!space:: SendInput " "
<^>!+space:: SendInput "█"
^+space:: SendInput "	"

!-:: SendInput "─"
!+-:: SendInput "━"
!<:: SendInput "│"
!+<:: SendInput "┃"

;######################### REPLACE A STRING FOLLOWED BY A PUNCTUATION WITH ANOTHER STRING #########################
;########## SPECIAL STRING CHECKS ##########
;  :C:  for case sensitivity
;  :*:  for instant replacement (no need to press space, enter, etc.)

; EMAIL SHORTCUTS
:*:@@e::email@example.com

; NAME SHORTCUTS (CASE SENSITIVE)
:*C:FL#::Firstname Lastname
:*C:fl#::firstname.lastname

; MATHEMATICAL SYMBOLS
::=#::≠
:*:==#::≈
:*:=>#::⇒
:*:<=#::⇐
:*:%#::‰
:*:%%#::‱
:*::#::÷
:*:/#::÷
:C:x#::×
:C:X#::✖
:*:8#::∞
:*:+-#::±
:*:pi#::π
:*:inf#::∞
:*:int#::∫
:*:sum#::∑
:*:prod#::∏
:*:sqrt#::√
:*:delta#::Δ
:*:micro#::µ
:*:permil#::‰
:*:permille#::‱

; FRACTION SYMBOLS
:*:1/#::⅟
:*:1/2#::½
:*:1/3#::⅓
:*:2/3#::⅔
:*:1/4#::¼
:*:3/4#::¾
:*:1/5#::⅕
:*:2/5#::⅖
:*:3/5#::⅗
:*:4/5#::⅘
:*:1/6#::⅙
:*:5/6#::⅚
:*:1/7#::⅐
:*:1/8#::⅛
:*:3/8#::⅜
:*:5/8#::⅝
:*:7/8#::⅞
:*:1/9#::⅑
:*:1/10#::⅒

; SUPERSCRIPT SYMBOLS
:*:^0#::⁰
:*:^1#::¹
:*:^2#::²
:*:^3#::³
:*:^4#::⁴
:*:^5#::⁵
:*:^6#::⁶
:*:^7#::⁷
:*:^8#::⁸
:*:^9#::⁹
:*:^+#::⁺
:*:^-#::⁻
:*:^=#::⁼
:*:^(#::⁽
:*:^)#::⁾
:*:^n#::ⁿ

; SUBSCRIPT SYMBOLS
:*:-0#::₀
:*:-1#::₁
:*:-2#::₂
:*:-3#::₃
:*:-4#::₄
:*:-5#::₅
:*:-6#::₆
:*:-7#::₇
:*:-8#::₈
:*:-9#::₉
:*:-+#::₊
:*:-#::₋
:*:-=#::₌
:*:-(#::₍
:*:-)#::₎

; TEXT WRITING SYMBOLS
::"#::«»
::"##::‹›
::"###::“”
::"####::‘’
::*#::∗
:*:***#::⁂
::..#::‥
:*:...#::…
::?#::¿
::!#::¡
:*:!!#::‼
:*:?!#::‽
:*:!?#::‽
:*:p#::¶

; CODING SYMBOLS
:*:caret#::‸
:*:space#::␣
:*:lessequal#::≤
:*:greaterequal#::≥

; LEFT AND RIGHT ARROWS
::->#::→
::->##::⇾
::->###::➜
::->####::➞
::<-#::←
::<-##::⇽

::>#::❯
::>##::▶
::>###::▸
::>####::ᐳ
::<#::❮
::<##::◀
::<###::◂
::<####::ᐸ

; UP AND DOWN ARROWS
::-^#::↓
::-^##::▼
::-^###::ꜜ
::-^####::🠫
::^#::↑
::^##::▲
::^###::ꜛ
::^####::🠩

; SPECIAL ARROWS
::back->::🔙
::end->::🔚
::on->::🔛
::soon->::🔜
::top->::🔝

; LINE DRAWING SYMBOLS
::=##::╣║╗╝╚╔╩╦╠═╬
::-#::│╰╮─╯╭
::-##::│┤└┐┴┬├─┼┘┌
::-###::┃┫┗┓┻┳┣━╋┛┏

; CURRENCY SYMBOLS
:*:eur#::€
:*:gbp#::£
:*:usd#::$
:*:btc#::₿
:*:yen#::¥
:*:won#::₩
:*:cent#::¢
:*:rupee#::₹

; EMOJI AND ICONS
:*:smile#::😊
:*:sad#::😢
:*:laugh#::😂
:*:wink#::😉
:*:thumbsup#::👍
:*:thumbsdown#::👎
:*:okhand#::👌
:*:clap#::👏
:*:fire#::🔥
:*:star#::⭐
:*:sparkles#::✨
:*:zap#::⚡
:*:checkmark#::✅
:*:crossmark#::❌
:*:question#::❓
:*:exclamation#::❗
:*:bulb#::💡
:*:lock#::🔒
:*:unlock#::🔓
:*:key#::🔑
:*:hammer#::🔨
:*:wrench#::🔧
:*:gear#::⚙️
:*:paperclip#::📎
:*:link#::🔗