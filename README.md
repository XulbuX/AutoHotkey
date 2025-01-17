# AutoHotkey
This repository contains AutoHotkey (*AHK*) scripts, which do a lot of really cool and very useful things.
For more information on AutoHotkey, how to use it and how to write AHK scripts, check out the [AutoHotkey documentation](https://www.autohotkey.com/docs/v2).

> [!NOTE]
> Most of the scripts in this repo only work for Windows, still the functionalities, that don't rely on Windows specific things, might work on other OSes too.

<br>

## AHK files

* [XulbuX AHK](#xulbux-ahk)

<br>

## How to install AutoHotkey?

For downloading and installing the AutoHotkey program, just go to [their website](https://www.autohotkey.com) and click on the `Download` button.
For the scripts in this repo, only `v2.0` is used, so click to download that. If downloaded, run the installer.

After the installation has finished, you should be good to go and can execute the downloaded AHK scripts.
If you want the scripts to start automatically on PC startup, follow the next steps:

<br>

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

<br>

## <span id="xulbux-ahk">XulbuX AHK</span>

This is the main AHK file, which includes all the functionalities you need, in one single script.<br>
⇾ You can easily customize shortcuts, text replacements and everything else in the code.<br>
⇾ You can also easily copy and paste existing parts of the code to add more shortcuts, text replacements, etc.

<br>

### Auto Clicker

That's right, this script contains an auto clicker!
It's no ordinary auto clicker though, this auto clicker works differently:
* Hold the left mouse button and after about a second it will automatically continue clicking the left mouse button really quickly until you release it.
* The same thing goes for the right mouse button.
* Press `Shift + Ecs` to enable/disable the auto clicker.


### Code Operations

* `Ctrl + Shift + U` converts the selected to all uppercase:<br>
  If you want to convert text with linebreaks to uppercase, coy that text and then press `Ctrl + Shift + U`. If you now paste the text again, it will be all uppercase.
* `Ctrl + Shift + L` converts the selected to all lowercase:<br>
  If you want to convert text with linebreaks to lowercase, coy that text and then press `Ctrl + Shift + L`. If you now paste the text again, it will be all lowercase.
* `Ctrl + Shift + S` will open the selected text as website/URL.
* `Ctrl + Alt + S` will web search for the selected text.


### Lock PC

* `Win + <` to lock the PC.
* `Win + Shift + <` to lock the PC and put it to sleep.
* `Win + Ctrl + <` to lock the PC and put it to hibernate.


### Launch Apps

* `Win + Alt + B` to launch your browser.
* `Win + Ctrl + B` to launch your browser in incognito mode.
* `Win + Alt + V` to launch VisualStudioCode:<br>
  * If you have one or multiple files/directories selected in the File Explorer, it will open them in VisualStudioCode.
* `Win + E` to launch the File Explorer:<br>
  1. If you have a path selected, it will open the Explorer in that location (*if it exists*).
  2. If you already are inside an open Explorer window, it will launch the new Explorer window at the same path as the old Explorer window.
* `Win + Alt + C` to launch the Windows Terminal:<br>
  1. If you have a path selected, it will open the Terminal in that location (*if it exists*).
  2. If you are in an open File Explorer window, it will launch the new Terminal at the path that's open in the Explorer.


### In-App Operations

* File Explorer:
  * `F1` to toggle hidden-files display.
  * `Ctrl + Shift + Z` to compress the selected files and directories into a zip file.


### Add/Remap Shortcuts

* `Ctrl + Tab` to switch between the last two opened windows, just like `Alt + Tab`, but instantly.


### More Keyboard Combinations

This will add more keyboard combinations to write more than the default special characters:

| Keyboard Combination      | will write                |
| ------------------------- | ------------------------- |
| `AltGr + T`               | `™`                       |
| `AltGr + C`               | `©`                       |
| `AltGr + R`               | `®`                       |
| `AltGr + .`               | `·`                       |
| `AltGr + Shift + .`       | `•`                       |
| `AltGr + -`               | `–`                       |
| `AltGr + Shift + -`       | `±`                       |
| `AltGr + Shift + 7`       | `÷`                       |
| `AltGr + X`               | `×`                       |
| `AltGr + P`               | `¶`                       |
| `AltGr + Space`           | ` ` (*large whitespace*) |
| `AltGr + Shift + Space`   | `█`                       |
| `Ctrl + Shift + Space`    | `	` (*tab character*)    |
| `Alt + -`                 | `─`                       |
| `Alt + Shift + -`         | `━`                       |
| `Alt + <`                 | `│`                       |
| `Alt + Shift + <`         | `┃`                       |


### Replace Text

Here you can write certain patterns followed by one or multiple `#` which will get replaced with something else.

The first replacing patterns are for time and date:
| gets replaced | with                               | instant or not |
| ------------- | ---------------------------------- | -------------- |
| `@#`          | date & time: `DD.MM.YYYY HH:mm:ss` | **N:** gets replaced only after a non-text character is written behind it |
| `@@#`         | Unix timestamp                     | **N**          |
| `date#`      | date: `DD.MM.YYYY`                 | **N**          |
| `date##`     | date: `YYYYMMDD`                   | **N**          |
| `time#`      | time: `HH:mm`                      | **N**          |
| `time##`     | time: `HH:mm:ss`                   | **N**          |
| `year#`      | year: `YYYY`                       | **I:** the replacement occurs instantly |
| `month#`     | month name                         | **I**          |
| `day#`       | day name                           | **I**          |

Then there is just small patterns, that get replaces with text.
These can all be replaced with your real email, name or anything else.
The replacements here occur all instantly:
| gets replaced | with text            |
| ------------- | -------------------- |
| `@@e`         | `email@example.com`  |
| `FL#`         | `Firstname Lastname` |
| `fl#`         | `firstname.lastname` |

Then there's a bunch of special text characters, you can type, by writing a pattern with one or multiple `#` behind it, which will then get replaced with the special character.
I won't list all patterns here, but you can find them all at the bottom inside the AHK file.
Here's a few examples what those patterns look like:
| gets replaced | with character/s | instant or not |
| ------------- | ---------------- | -------------- |
| `=#`          | `≠`              | **N**          |
| `==#`         | `≈`              | **I**          |
| `micro#`      | `µ`              | **I**          |
| `permil#`     | `‰`              | **I**          |
| `permille#`   | `‱`             | **I**          |
| `3/4#`        | `¾`              | **I**          |
| `->#`         | `→`              | **N**          |
| `->##`        | `⇾`              | **N**          |
| `->###`       | `➜`              | **N**          |
| `=##`         | `╣║╗╝╚╔╩╦╠═╬`    | **N**          |
| ...           |                  |                |

There are also a ton of emojis, which you can write their name followed by a `#` to get that emoji.Here there are even multiple different names you can use to get the same emoji.
The replacements here again occur all instantly.
Again, I'm not going to list them all here, but here's a few examples:
| gets replaced                                        | with emoji |
| ---------------------------------------------------- | ---------- |
| `smile#` `happy#` `cheerful#`                        | `😊`       |
| `joy#` `rofl#` `xd#`                                 | `😂`       |
| `sob#` `weep#` `bawl#`                               | `😭`       |
| `steaming#` `furious#` `outrage#` `fury#`            | `😡`       |
| `thumbsup#` `like#` `upvote#`                        | `👍`       |
| `thumbsdown#` `dislike#` `downvote#`                 | `👎`       |
| `perfect#` `ok#` `okay#` `good#`                     | `👌`       |
| `peace#` `victory#` `yeah#`                          | `✌️`       |
| `programmer#` `coder#` `dev#`                        | `👨‍💻`       |
| `refresh#` `reload#` `update#`                       | `🔁`       |
| `pause#` `wait#` `suspend#`                          | `⏸️`       |
| `folder#` `dir#` `directory#`                        | `📁`       |
| `file#` `textfile#` `doc#` `document#`               | `📄`       |
| `flame#` `fire#` `burn#`                             | `🔥`       |
| `water#` `drop#` `raindrop#`                         | `💧`       |
| `ice#` `ice_cube#` `freeze#` `frozen#`               | `🧊`       |
| `dia#` `diamond#` `gem#` `gemstone#`                 | `💎`       |
| `crown#` `royal#` `king#` `queen#` `lead#` `leader#` | `👑`       |
| ...                                                  |            |

There's also a few more things, like the `@#` pattern, which gets replaced with the current date, and the `time#` pattern, which gets replaced with the current time.