# AutoHotkey
This repository contains AutoHotkey (*AHK*) scripts, which do a lot of really cool and very useful things.

> [!NOTE]
> Most of the scripts in this repo only work for Windows, still the functionalities, that don't rely on Windows specific things, might work on other OSes too.


## AHK files
* [XulbuX AHK](#xulbux-ahk)


## How to install AutoHotkey?
For downloading and installing the AutoHotkey program, just go to [their website](https://www.autohotkey.com) and click on the `Download` button.
For the scripts in this repo, only `v2.0` is used, so click to download that. If downloaded, run the installer.

After the installation has finished, you should be good to go and can execute the downloaded AHK scripts.
If you want the scripts to start automatically on PC startup, follow the next steps:


## How to Make an AHK File Start Automatically

### Windows
1. Create your AHK file.
2. Press `Win + R`, type `%appdata%\Microsoft\Windows\Start Menu\Programs\Startup`, and press `Enter`.
3. Place a shortcut of your AHK file, or the script file itself, in this folder.

### macOS
1. Convert your AHK script into an executable using **Wine** or **Crossover**.
2. Move the executable to `~/Library/LaunchAgents/`.
3. Create a `.plist` file in the same directory to launch it at login.

Example `.plist` content:
```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>Label</key>
  <string>com.user.autohotkey</string>
  <key>ProgramArguments</key>
  <array>
    <string>/path/to/your/autohotkey/executable</string>
  </array>
  <key>RunAtLoad</key>
  <true/>
</dict>
</plist>
```

### Linux (Ubuntu)
1. Use Wine to run AHK scripts on Linux.
2. Create a `.desktop` file in `~/.config/autostart/` with the following content:
```ini
[Desktop Entry]
Type=Application
Exec=wine /path/to/your/ahk/script.ahk
Hidden=false
NoDisplay=false
X-GNOME-Autostart-enabled=true
Name=AutoHotkey Script
```


## <span id="xulbux-ahk">XulbuX AHK</span>
This is the main AHK file, which includes all the functionalities you need, in one single script.

### Auto Clicker
That's right, this script contains an auto clicker!
It's no ordinary auto clicker though, this auto clicker works differently:
* Hold the left mouse button and after about a second it will automatically continue clicking the left mouse button really quickly until you release it.
* The same thing goes for the right mouse button.
* Press `Shift + Ecs` to enable/disable the auto clicker.

### Code Operations
* `Ctrl + Shift + U`, converts the selected to all uppercase.
* `Ctrl + Shift + L`, converts the selected to all lowercase.
* `Ctrl + Shift + S`, will web search for the selected text.

### Lock PC
* `Win + <` to lock the PC.
* `Win + Shift + <` to lock the PC and put it to sleep.
* `Win + Ctrl + <` to lock the PC and put it to hibernate.

### Launch Apps
* `Win + Alt + B` to launch your browser.
* `Win + Ctrl + B` to launch your browser in incognito mode.
* `Win + Alt + V` to launch VisualStudioCode:<br>
  If you have one or multiple files/directories selected in the File Explorer, it will open them in VisualStudioCode.
* `Win + E` to launch the File Explorer:<br>
  If you have a dir-/file-path selected, it will open the Explorer at that path (*if it exists*).
  If you already are inside an open Explorer window, it will launch the new Explorer window at the same path as the old Explorer window.
* `Win + Alt + C` to launch the Windows Terminal:<br>
  If you have a dir-/file-path selected, it will open the Terminal at that path (*if it exists*).
  If you are in an open File Explorer window, it will launch the new Terminal at the path that's open in the Explorer.

### In-App Operations
* `Ctrl + F2` to toggle hidden-files displaying in the File Explorer.

### Add/Remap Shortcuts
* `Ctrl + Tab` to switch between the last two opened windows, just like `Alt + Tab`, but instantly.

### More Keyboard Combinations
This will add more keyboard combinations to write more than the default special characters:

| Keyboard Combination      | will write             |
| ------------------------- | ---------------------- |
| `AltGr + T`               | `™`                    |
| `AltGr + C`               | `©`                    |
| `AltGr + R`               | `®`                    |
| `AltGr + .`               | `·`                    |
| `AltGr + Shift + .`       | `•`                    |
| `AltGr + -`               | `–`                    |
| `AltGr + Shift + -`       | `±`                    |
| `AltGr + Shift + 7`       | `÷`                    |
| `AltGr + X`               | `×`                    |
| `AltGr + P`               | `¶`                    |
| `AltGr + Space`           | ` ` (*large space*)   |
| `AltGr + Shift + Space`   | `█`                    |
| `Ctrl + Shift + Space`    | `	` (*tab char*)      |
| `Alt + -`                 | `─`                    |
| `Alt + Shift + -`         | `━`                    |
| `Alt + <`                 | `│`                    |
| `Alt + Shift + <`         | `┃`                    |

### Replace Text
Here, it will replace defined text with other text:
| `@@e` | `your.email@example.com` (*can be replaced with your real email in the AHK file*) |
| `FL#` | `Firstname Lastname` (*can be replaced with your real name in the AHK file*) |
| `fl#` | `firstname.lastname` (*can be replaced with your real name in the AHK file*) |

Then there's a bunch of special text characters, you can type, which I won't list all here, but you can find them all the way at the bottom in the AHK file. Here's a few examples:
| will get replaced | replaced with | instant or not |
| ----------------- | ------------- | -------------- |
| `=#`              | `≠`           | ***N:*** *write a non-text character after to make it get replaced* |
| `==#`             | `≈`           | ***I:*** *will instantly get replaced* |
| `micro#`          | `µ`           | ***I***        |
| `permille#`       | `‱`          | ***I***        |
| `3/4#`            | `¾`           | ***I***        |
| `->###`           | `➜`           | ***N***        |
| `=##`             | `╣║╗╝╚╔╩╦╠═╬` | ***N***        |
| ...               |               |                |