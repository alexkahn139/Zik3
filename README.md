# Welcome to Zik3!
Zik3 adding Bluetooth support on Mac OS 10.13 for the headphones Parrot Zik 3.

The origin of the code is the following project: http://picaso.github.io/parrot-zik-status/
which stopped working with MacOS 10.13.
I mostly used the patch proposed here: https://github.com/picaso/parrot-zik-status/issues/14#issuecomment-347964583

### AEXM
The [AEXM library](https://github.com/tadija/AEXML) made by [tadija](https://github.com/tadija) is needed for this project. It is added in the AEXM folder.

## Build
To build the app you need Xcode, which can be downloaded for free from the Mac AppStore. Once this is installed the remaining step is building the program, by clicking the green play button.   

## Running
The app crashes everytime the connection is dropped. I made a quick dirty solution while waiting for a real fix.  
You should make a plist in `~/Library/LaunchAgents`. I called mine `Zik.restart.plist`, then added:  
```
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
        <key>RunAtLoad</key>
        <true/>
        <key>KeepAlive</key>
        <true/>
        <key>Label</key>
        <string>SomeApp.restart</string>
        <key>ProgramArguments</key>
        <array>
                <string>/Applications/Zik3.app/Contents/MacOS/Zik3</string>
        </array>
</dict>
</plist>
```
To always start the app and keep it running you need to call this line:  
```
launchctl load ~/Library/LaunchAgents/Zik.restart.plist
```