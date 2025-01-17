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
    A_Clipboard := ""
    SendEvent "^c"
    SelectedText := A_Clipboard
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

Explorer_GetSelected() {
    selectedItems := []
    if (hwnd := WinActive("ahk_class CabinetWClass")) {
        for window in ComObject("Shell.Application").Windows {
            if (window.HWND == hwnd) {
                items := window.Document.SelectedItems()
                loop items.Count {
                    selectedItems.Push(items.Item(A_Index - 1).Path)
                }
                return selectedItems
            }
        }
    }
    return selectedItems
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



;######################################## AUTO CLICKER ########################################

global autoClickerOn := false ; INIT: `false` = NOT ACTIVE

+Esc:: {
    global
    autoClickerOn := !autoClickerOn
    if (autoClickerOn)
        ToolTip("AutoClicker ON")
    else
        ToolTip("AutoClicker OFF")
    SetTimer () => ToolTip(), -600
}

~$LButton:: {
    global
    if (autoClickerOn) {
        KeyWait("LButton", "T0.5")
        if (A_TimeIdleKeyboard > 500)
            while (GetKeyState("LButton", "P"))
                Click()
    }
}

~$RButton:: {
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
^+u:: {
    selectedText := GetSelectedText()
    if (selectedText)
        PasteText(StrUpper(selectedText))
}

; CONVERT SELECTED TEXT TO LOWERCASE
^+l:: {
    selectedText := GetSelectedText()
    if (selectedText)
        PasteText(StrLower(selectedText))
}

; OPEN SELECTED TEXT AS WEBSITE/URL
^+s:: {
    selectedText := GetSelectedText()
    if (selectedText)
        Run(selectedText)
}

; WEB-SEARCH SELECTED TEXT
^!s:: {
    selectedText := GetSelectedText()
    if (selectedText)
        Run("https://www.google.com/search?q=" . selectedText)
}



;######################################## LOCK PC ########################################

; LOCK COMPUTER
#<:: DllCall("LockWorkStation")

; LOCK COMPUTER AND PUT COMPUTER TO SLEEP
#+<:: {
    ; WAIT FOR THE RELEASE OF THE KEYS
    KeyWait "<", "U"
    KeyWait "LWin", "U"
    KeyWait "Shift", "U"
    ; PUT THE COMPUTER TO SLEEP
    SendMessage(0x112, 0xF170, 2, , "Program Manager")
}

; LOCK COMPUTER AND PUT COMPUTER TO HIBERNATE
#^<:: {
    ; WAIT FOR THE RELEASE OF THE KEYS
    KeyWait "<", "U"
    KeyWait "LWin", "U"
    KeyWait "Ctrl", "U"
    ; PUT THE COMPUTER TO HIBERNATE
    DllCall("PowrProf\SetSuspendState", "int", 1, "int", 0, "int", 0)
}



;######################################## LAUNCH APPS ########################################

;########## LAUNCH BROWSER ##########

launch_browser(dev_mode := false) {
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

$#!b:: launch_browser()
$#^b:: launch_browser(true)


;########## OPEN SELECTED FILE WITH APP ##########

; VisualStudioCode
$#!v:: {
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
$#e:: {
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
$#!c:: {
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

;########## WINDOWS FILE EXPLORER ##########
#HotIf WinActive("ahk_class CabinetWClass")

; TOGGLE HIDDEN FILES DISPLAY
F1:: {
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

; ZIP SELECTED FILE(S) / FOLDER CONTENT / FOLDERS
^+z:: {
    selected := Explorer_GetSelected()
    if (selected.Length = 0) {
        return
    }
    firstItem := selected[1]
    if (DirExist(firstItem)) {
        ; FOLDER(S) SELECTED => ZIP USING FIRST FOLDER'S NAME
        SplitPath(firstItem, &name, &dir)
        zipFile := name ".zip"
        zipPath := dir "\" zipFile
    } else {
        ; FILE(S) SELECTED => USE FIRST FILE'S NAME WITHOUT EXTENSION
        SplitPath(firstItem, &name, &dir, &ext)
        zipFile := StrReplace(name, "." ext) ".zip"
        zipPath := dir "\" zipFile
    }
    ; DELETE EXISTING ZIP FILE (IF EXISTS)
    if FileExist(zipPath) {
        FileDelete(zipPath)
    }
    ; CREATE EMPTY ZIP FILE
    zip := FileOpen(zipPath, "w")
    if (zip) {
        zip.Close()
    }
    ; GET SHELL COM OBJECTS
    shell := ComObject("Shell.Application")
    zip := shell.Namespace(zipPath)
    if (!zip) {
        MsgBox("Error creating zip file.")
        return
    }
    ; CHECK FOR COMPRESSION WINDOW AND BRING IT TO FRONT
    SetTimer(BringCompressionWindowToFront, 100)
    ; ZIP THE SELECTED ITEMS
    if (selected.Length = 1 && DirExist(firstItem)) {
        ; SINGLE FOLDER => ZIP ITS CONTENTS
        folder := shell.Namespace(firstItem)
        if (!folder) {
            MsgBox("Error accessing folder.")
            return
        }
        items := folder.Items()
        totalItems := items.Count
        zip.CopyHere(items, 4|16|128)
    } else {
        ; MULTIPLE FILES OR FOLDERS => ZIP THE ITEMS THEMSELVES
        totalItems := selected.Length
        for path in selected {
            zip.CopyHere(path, 4|16|128)
        }
    }
    ; WAIT FOR THE ZIP OPERATION TO COMPLETE
    itemCount := 0
    while (itemCount != totalItems) {
        Sleep(50)
        itemCount := zip.Items().Count
    }
    ; STOP CHECKING FOR THE COMPRESSION WINDOW
    SetTimer(BringCompressionWindowToFront, 0)
    ; SUCCESS OR FAILURE MESSAGE
    if (FileExist(zipPath) && itemCount = totalItems) {
        ; MsgBox("Successfully zipped into '" zipFile "'", "Done creating ZIP file", "OK")
    } else {
        FileDelete(zipPath)
        MsgBox("Something went wrong while compressing into '" zipFile "'", "Error creating ZIP file", "iconX")
    }
}
BringCompressionWindowToFront() {
    static compressionTitles := ["Compressing..."]
    for title in compressionTitles {
        if (hwnd := WinExist(title " ahk_class #32770")) {
            WinActivate(hwnd)
            return
        }
    }
}


#HotIf  ; RESET HOTKEY CONDITION


;######################################## ADD/REMAP SHORTCUTS ########################################

; DISABLE THE DEFAULT BEHAVIORS
; !Tab::Return

; REMAP SHORTCUTS
^Tab:: SendInput("!{Tab}")



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
;  :b0: the hot string only triggers if it's not part of another word

;########## DATE AND TIME ##########
::@#::{
    Send(FormatTime(, "dd.MM.yyyy, HH:mm:ss"))
}
::@##::{
    Send(DateDiff(A_NowUTC, "19700101000000", "Seconds"))
}
::date#::{
    Send(FormatTime(, "dd.MM.yyyy"))
}
::date##::{
    Send(StrReplace(FormatTime(, "yyyy MM dd"), " ", ""))
}
::time#::{
    Send(FormatTime(, "HH:mm"))
}
::time##::{
    Send(FormatTime(, "HH:mm:ss"))
}
:*:year#::{
    Send(FormatTime(, "yyyy"))
}
:*:month#::{
    Send(FormatTime(, "MMMM"))
}
:*:day#::{
    Send(FormatTime(, "dddd"))
}

;########## LONGER STRINGS ##########
; EMAIL SHORTCUTS
:*:@@m::email@example.com

; NAME SHORTCUTS (CASE SENSITIVE)
:*C:FL#::Firstname Lastname
:*C:fl#::firstname.lastname

;########## SPECIAL UNICODE ##########
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
:*:***#::⁂
::*#::∗
:*:...#::…
::..#::‥
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

; GENERAL SPECIAL CHARACTERS
:*?:pass#::✓
:*?:check#::✓
:*?:fail#::⨯
:*?:cross#::⨯

;########## EMOJIS ##########
; FEELINGS / EMOTIONS
:*:smile#::😊
:*:happy#::😊
:*:cheerful#::😊
:*:laugh#::😄
:*:lol#::😄
:*:haha#::😄
:*:joy#::😂
:*:rofl#::😂
:*:xd#::😂
:*:wink#::😉
:*:flirt#::😉
:*:joke#::🙃
:*:joking#::🙃
:*:love_face#::😍
:*:heart_eyes#::😍
:*:in_love#::😍
:*:kiss#::😘
:*:mwah#::😘
:*:xoxo#::😘
:*:romance#::🥰
:*:love#::🥰
:*:in_love#::🥰
:*:kiss_heart#::💋
:*:smooch#::💋
:*:muah#::💋
:*:blush#::☺️
:*:shy#::☺️
:*:uwu#::☺️
:*:cool#::😎
:*:sunglasses#::😎
:*:awesome#::😎
:*:drool#::🤤
:*:yummy#::🤤
:*:tasty#::🤤
:*:relief#::😅
:*:phew#::😅
:*:sweat#::😅
:*:tongue#::😛
:*:silly#::😛
:*:playful#::😛
:*:crazy#::🤪
:*:zany#::🤪
:*:goofy#::🤪
:*:sus#::😏
:*:suspicious#::😏
:*:aha#::😏
:*:party#::🥳
:*:celebrate#::🥳
:*:woohoo#::🥳
:*:star_struck#::🤩
:*:amazed#::🤩
:*:amazing#::🤩
:*:wow#::🤩
:*:mindblown#::🤯
:*:explode#::🤯
:*:boom#::🤯
:*:flabbergasted#::😨
:*:shocked#::😨
:*:loud#::🫨
:*:vibrate#::🫨
:*:vibrating#::🫨
:*:dizzy#::😵‍💫
:*:stunned#::😵‍💫
:*:dead#::😵
:*:finished#::😵
:*:think#::🤔
:*:thinking#::🤔
:*:hmm#::🤔
:*:monocle#::🧐
:*:inspect#::🧐
:*:examine#::🧐
:*:nerd#::🤓
:*:geek#::🤓
:*:smart#::🤓
:*:stupid#::🥴
:*:dumb#::🥴
:*:eyes#::👀
:*:look#::👀
:*:peek#::👀
:*:sad#::😢
:*:cry#::😢
:*:tear#::😢
:*:sob#::😭
:*:weep#::😭
:*:bawl#::😭
:*:angry#::😠
:*:mad#::😠
:*:rage#::😠
:*:annoyed#::😠
:*:steaming#::🤬
:*:furious#::🤬
:*:outrage#::🤬
:*:outraged#::🤬
:*:fury#::🤬
:*:tired#::😫
:*:exhausted#::😫
:*:weary#::😫
:*:worried#::😟
:*:concerned#::😟
:*:anxious#::😟
:*:cold#::🥶
:*:icecold#::🥶
:*:freezing#::🥶
:*:sick#::🤢
:*:ill#::🤢
:*:nauseous#::🤢
:*:virus#::🦠
:*:microbe#::🦠
:*:sickness#::🦠
:*:infection#::🦠
:*:rip#::💀
:*:skull#::💀
:*:crossbones#::☠️
:*:deadly#::☠️
:*:ghost#::👻
:*:ghosted#::👻
:*:spooky#::👻
:*:boo#::👻
:*:poop#::💩
:*:crap#::💩
:*:shit#::💩
:*:bad#::💩
:*:moai#::🗿
:*:stone_face#::🗿
:*:bruh#::🗿
; GESTURES
:*:thumbsup#::👍
:*:like#::👍
:*:upvote#::👍
:*:thumbsdown#::👎
:*:dislike#::👎
:*:downvote#::👎
:*:perfect#::👌
:*:ok#::👌
:*:okay#::👌
:*:good#::👌
:*:clap#::👏
:*:applause#::👏
:*:bravo#::👏
:*:pray#::🙏
:*:please#::🙏
:*:thank#::🙏
:*:muscle#::💪
:*:strong#::💪
:*:flex#::💪
:*:punch#::👊
:*:fist#::👊
:*:bro#::👊
:*:point_up#::☝️
:*:above#::☝️
:*:up#::☝️
:*:point_down#::👇
:*:below#::👇
:*:down#::👇
:*:handshake#::🤝
:*:deal#::🤝
:*:agreement#::🤝
:*:fingers_crossed#::🤞
:*:luck#::🤞
:*:hope#::🤞
:*:peace#::✌️
:*:victory#::✌️
:*:yeah#::✌️
:*:shrug#::🤷
:*:dunno#::🤷
:*:whatever#::🤷
:*:idk#::🤷
:*:facepalm#::🤦
:*:smh#::🤦
:*:doh#::🤦
; TECH & DEVELOPER
:*:keyboard#::⌨️
:*:type#::⌨️
:*:input#::⌨️
:*:computer#::💻
:*:pc#::💻
:*:desktop#::💻
:*:terminal#::📟
:*:console#::📟
:*:shell#::📟
:*:cmd#::📟
:*:programmer#::👨‍💻
:*:coder#::👨‍💻
:*:dev#::👨‍💻
:*:robot#::🤖
:*:auto#::🤖
:*:bot#::🤖
:*:rocket#::🚀
:*:deploy#::🚀
:*:launch#::🚀
:*:execute#::▶️
:*:start#::▶️
:*:run#::▶️
:*:play#::▶️
:*:refresh#::🔄
:*:reload#::🔄
:*:update#::🔄
:*:sync#::🔄
:*:wifi#::📶
:*:wireless#::📶
:*:signal#::📶
:*:network#::📶
:*:download#::⬇️
:*:down#::⏬
:*:save#::⏬
:*:upload#::⬆️
:*:up#::⏫
:*:push#::⏫
:*:stop#::⏹️
:*:halt#::⏹️
:*:terminate#::⏹️
:*:pause#::⏸️
:*:wait#::⏸️
:*:suspend#::⏸️
:*:zap#::⚡
:*:lightning#::⚡
:*:fast#::⚡
:*:cloud#::☁️
:*:server#::☁️
:*:host#::☁️
:*:database#::🗄️
:*:db#::🗄️
:*:storage#::🗄️
:*:save#::💾
:*:diskette#::💾
:*:store#::💾
:*:folder#::📂
:*:dir#::📂
:*:directory#::📂
:*:files#::🗃️
:*:documents#::🗃️
:*:docs#::🗃️
:*:file#::📄
:*:textfile#::📄
:*:doc#::📄
:*:document#::📄
:*:magnify#::🔍
:*:search#::🔍
:*:find#::🔍
:*:web#::🌐
:*:browser#::🌐
:*:internet#::🌐
:*:www#::🌐
:*:link#::🔗
:*:url#::🔗
:*:href#::🔗
:*:hyperlink#::🔗
:*:graph#::📊
:*:chart#::📊
:*:stats#::📊
:*:data#::📊
:*:clipboard#::📋
:*:paste#::📋
:*:copy#::📋
:*:tasks#::📝
:*:todo#::📝
:*:list#::📝
:*:editor#::📝
:*:notepad#::📝
:*:locked#::🔒
:*:secure#::🔒
:*:secret#::🔒
:*:private#::🔒
:*:lock#::🔐
:*:unlock#::🔐
:*:passwords#::🔐
:*:safe#::🔐
:*:password_manager#::🔐
:*:pwd_manager#::🔐
:*:unlocked#::🔓
:*:open#::🔓
:*:free#::🔓
:*:key#::🔑
:*:passkey#::🔑
:*:password#::🔑
:*:pwd#::🔑
:*:pin#::🔑
:*:access#::🔑
:*:gear#::⚙️
:*:settings#::⚙️
:*:config#::⚙️
:*:options#::⚙️
:*:tools#::🛠️
:*:setup#::🛠️
:*:maintenance#::🛠️
:*:recycling_bin#::🗑️
:*:bin#::🗑️
:*:trash#::🗑️
:*:delete#::🗑️
:*:testing#::🧪
:*:test#::🧪
:*:quality#::🧪
:*:noentry#::⛔
:*:noaccess#::⛔
:*:prohibited#::🚫
:*:ban#::🚫
:*:stop#::🚫
:*:forbidden#::🚫
:*:uranium#::☢️
:*:radioactive#::☢️
:*:radioactivity#::☢️
:*:biohazard#::☣️
:*:toxic#::☣️
:*:poison#::☣️
:*:warn#::⚠️
:*:warning#::⚠️
:*:caution#::⚠️
:*:alert#::⚠️
:*:danger#::⚠️
:*:dangerous#::⚠️
:*:virus#::👾
:*:malware#::👾
:*:trojan#::👾
:*:shield#::🛡️
:*:security#::🛡️
:*:protect#::🛡️
:*:antivirus#::🛡️
; DESIGN & CREATIVE
:*:palette#::🎨
:*:colors#::🎨
:*:art#::🎨
:*:pencil#::✏️
:*:draw#::✏️
:*:edit#::✏️
:*:brush#::🖌️
:*:paint#::🖌️
:*:design#::🖌️
:*:ruler#::📏
:*:measure#::📏
:*:size#::📏
:*:frames#::🖼️
:*:image#::🖼️
:*:picture#::🖼️
:*:camera#::📸
:*:photo#::📸
:*:capture#::📸
:*:video#::🎥
:*:film#::🎥
:*:movie#::🎥
:*:sparkles#::✨
:*:magic#::✨
:*:shine#::✨
:*:layers#::🗂️
:*:stack#::🗂️
:*:arrange#::🗂️
; ANIMALS
:*:bug#::🪲
:*:debug#::🪲
:*:error#::🪲
:*:python#::🐍
:*:snake#::🐍
:*:serpent#::🐍
:*:dog#::🐶
:*:puppy#::🐶
:*:doggy#::🐶
:*:cat#::🐱
:*:kitty#::🐱
:*:meow#::🐱
:*:mouse#::🐭
:*:rat#::🐭
:*:rodent#::🐭
:*:monkey#::🐵
:*:ape#::🐵
:*:chimp#::🐵
:*:bear#::🐻
:*:grizzly#::🐻
:*:teddy#::🐻
:*:golang#::🦫
:*:gopher#::🦫
:*:unicorn#::🦄
:*:fantasy#::🦄
:*:magic#::🦄
:*:butterfly#::🦋
:*:moth#::🦋
:*:insect#::🦋
:*:bird#::🐦
:*:birdie#::🐦
:*:avian#::🐦
:*:fox#::🦊
:*:mozilla#::🦊
:*:firefox#::🦊
:*:penguin#::🐧
:*:linux#::🐧
:*:tux#::🐧
:*:whale#::🐳
:*:docker#::🐳
:*:container#::🐳
:*:spider#::🕷️
:*:arachnid#::🕷️
; SYMBOLS & MARKS
:*:checkmark#::✅
:*:correct#::✅
:*:verified#::✅
:*:crossmark#::❌
:*:wrong#::❌
:*:incorrect#::❌
:*:question#::❓
:*:what#::❓
:*:huh#::❓
:*:exclaim#::❗
:*:attention#::❗
:*:alert#::❗
:*:star#::⭐
:*:favorite#::⭐
:*:favourite#::⭐
:*:bookmark#::⭐
:*:copyright#::©️
:*:copy#::©️
:*:rights#::©️
:*:trademark#::™️
:*:tm#::™️
:*:brand#::™️
:*:registered#::®️
:*:reg#::®️
:*:brand#::®️
:*:plus#::➕
:*:add#::➕
:*:new#::➕
:*:minus#::➖
:*:subtract#::➖
:*:remove#::➖
:*:multiply#::✖️
:*:times#::✖️
:*:x#::✖️
:*:divide#::➗
:*:division#::➗
:*:slash#::➗
:*:equals#::🟰
:*:equal#::🟰
:*:result#::🟰
:*:infinite#::♾️
:*:forever#::♾️
:*:endless#::♾️
:*:hundred#::💯
:*:percent#::💯
:*:score#::💯
:*:nice#::💯
; OBJECTS & TOOLS
:*:phone#::📱
:*:mobile#::📱
:*:cell#::📱
:*:mail#::📧
:*:email#::📧
:*:message#::📧
:*:bulb#::💡
:*:idea#::💡
:*:light#::💡
:*:money#::💰
:*:cash#::💰
:*:dollar#::💰
:*:wrench#::🔧
:*:fix#::🔧
:*:repair#::🔧
:*:hammer#::🔨
:*:build#::🔨
:*:construct#::🔨
:*:paperclip#::📎
:*:pyperclip#::📎
:*:attach#::📎
:*:clip#::📎
:*:link#::🔗
:*:chain#::🔗
:*:url#::🔗
:*:save#::🔖
:*:marker#::🔖
:*:tag#::🔖
:*:memo#::📝
:*:note#::📝
:*:write#::📝
:*:printer#::🖨️
:*:print#::🖨️
:*:output#::🖨️
:*:floppy#::💾
:*:disk#::💾
:*:save#::💾
:*:cd#::💿
:*:dvd#::💿
:*:disc#::💿
; COMMUNICATION & SOCIAL
:*:chat#::💬
:*:speech#::💬
:*:comment#::💬
:*:globe#::🌐
:*:world#::🌐
:*:internet#::🌐
:*:signal#::📶
:*:wifi#::📶
:*:wireless#::📶
:*:bell#::🔔
:*:notify#::🔔
:*:notification#::🔔
:*:mute#::🔕
:*:silent#::🔕
:*:quiet#::🔕
:*:inbox#::📥
:*:received#::📥
:*:messages#::📥
:*:outbox#::📤
:*:sent#::📤
:*:sending#::📤
; HEARTS & LOVE
:*:red_heart#::❤️
:*:heart#::❤️
:*:red#::❤️
:*:orange_heart#::🧡
:*:warm#::🧡
:*:sunset#::🧡
:*:yellow_heart#::💛
:*:friendship#::💛
:*:sunny#::💛
:*:green_heart#::💚
:*:nature#::💚
:*:life#::💚
:*:blue_heart#::💙
:*:calm#::💙
:*:ocean#::💙
:*:purple_heart#::💜
:*:royal#::💜
:*:noble#::💜
:*:pink_heart#::🩷
:*:sweet#::🩷
:*:cute#::🩷
:*:black_heart#::🖤
:*:dark#::🖤
:*:night#::🖤
:*:heartbreak#::💔
:*:broken#::💔
:*:hurt#::💔
:*:sparks#::💖
:*:excited#::💖
:*:crush#::💖
:*:fire_heart#::❤️‍🔥
:*:passion#::❤️‍🔥
:*:desire#::❤️‍🔥
:*:hearts#::💕
; WEATHER & NATURE
:*:sun#::☀️
:*:sunshine#::☀️
:*:bright#::☀️
:*:cloudy#::☁️
:*:weather#::☁️
:*:rain#::🌧️
:*:rainy#::🌧️
:*:wet#::🌧️
:*:rainbow#::🌈
:*:pride#::🌈
:*:colors#::🌈
:*:fire#::🔥
:*:flame#::🔥
:*:burn#::🔥
:*:water#::💧
:*:drop#::💧
:*:raindrop#::💧
:*:splash#::💦
:*:fluid#::💦
:*:liquid#::💦
:*:plant#::🌱
:*:seed#::🌱
:*:natural#::🌱
:*:tree#::🌳
:*:forest#::🌳
:*:leaf#::🍃
:*:leafy#::🍃
:*:green#::🍃
:*:wood#::🪵
:*:rock#::🪨
:*:stone#::🪨
:*:rocky#::🪨
:*:flower#::🌸
:*:blossom#::🌸
:*:bloom#::🌸
:*:rose#::🌹
:*:tulip#::🌷
:*:hyacinth#::🪻
:*:snowflake#::❄️
:*:winter#::❄️
:*:ice#::🧊
:*:ice_cube#::🧊
:*:freeze#::🧊
:*:frozen#::🧊
; SPACE
:*:space#::🌌
:*:galaxy#::🌌
:*:meteor#::☄️
:*:meteorite#::☄️
:*:planet#::🪐
:*:saturn#::🪐
:*:earth#::🌏
:*:world#::🌏
:*:globe#::🌏
:*:moon_cycle#::🌙
:*:moon#::🌕
:*:full_moon#::🌕
:*:waxing_gibbous_moon#::🌔
:*:first_quarter_moon#::🌓
:*:waxing_moon#::🌒
:*:new_moon#::🌑
:*:satellite#::🛰️
:*:ufo#::🛸️
; TIME MANAGEMENT
:*:hour#::🕐
:*:clock#::🕐
:*:watch#::🕐
:*:hourglass#::⌛
:*:timer#::⌛
:*:wait#::⌛
:*:calendar#::📅
:*:schedule#::📅
:*:alarm#::⏰
:*:reminder#::⏰
:*:wake#::⏰
:*:stopwatch#::⏱️
:*:measure#::⏱️
:*:timing#::⏱️
; ACHIEVEMENTS
:*:trophy#::🏆
:*:win#::🏆
:*:winner#::🏆
:*:champion#::🏆
:*:medal#::🏅
:*:prize#::🏅
:*:award#::🏅
:*:crown#::👑
:*:royal#::👑
:*:king#::👑
:*:queen#::👑
:*:lead#::👑
:*:leader#::👑
:*:dia#::💎
:*:diamond#::💎
:*:gem#::💎
:*:gemstone#::💎
:*:jewel#::💎
:*:target#::🎯
:*:aim#::🎯
:*:goal#::🎯
