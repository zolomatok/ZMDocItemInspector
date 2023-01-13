# ZMDocItemInspector

## Important‼️
This was developed for **Xcode 6**. No idea if it's still working or not. It's mostly just here for posterity and as a code sample for plugin development. It does **not** use the modern Xcode extension API.


## What is this?
This Xcode plugin converts the Quick Help inspector into an always visible Document Items inspector.
Makes it easier to find our way around the code.

**It basically does this:**

![Items Inspector](http://i.stack.imgur.com/x4SCO.png)



## How do I use it?
**Either** build the ZMDocItemInspector target in the Xcode project and the plug-in will be automatically installed in ~/Library/Application Support/Developer/Shared/Xcode/Plug-ins.

**Or** install via [Alcatraz](https://github.com/supermarin/Alcatraz)

Relaunch Xcode and bring up the Quck Help inspector in the right side panel.
Developed and tested in Xcode 6


## License
```
The MIT License (MIT)

Copyright (c) 2015 zolomatok

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```
