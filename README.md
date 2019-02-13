# notify-send for Windows (AHK version)

Shows a GUI notification window from the command line.

## Usage

``notify-send [OPTION?] <Message>``

- `--icon=ICON`	Path to a JPEG or PNG image
- `--app-name=TITLE`	Specifies the app name for the icon (Default: "send-notify")
- `--expire-time=T`	Specifies the timeout in milliseconds (Default: 5000)

These command line parameters follow the format of the Ubuntu package libnotify-bin.

## Downloads

Prebuilt binaries are available from the
[releases section](https://github.com/Fonata/notify-send-for-Windows/releases).

To build the ahk source into an exe you need the AutoHotkey compiler.
 
## Aknowledgements

- [GDI+ standard library for Autohotkey](https://github.com/tariqporter/Gdip)
- Some text and inspiration comes from [julienXX/terminal-notifier](https://github.com/julienXX/terminal-notifier)
- Another Windows implementation with different command line switches is [vaskovsky/notify-send](https://github.com/vaskovsky/notify-send) 

## License

Copyright © 2012-2016 Alexey Vaskovsky <alexey@vaskovsky.net>

This program is free software; you can redistribute it and/or
modify it under the terms of the GNU Lesser General Public
License as published by the Free Software Foundation; either
version 3 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
See the [GNU Lesser General Public License][1] for more details.

[1]: http://vaskovsky.net/notify-send/license.html
