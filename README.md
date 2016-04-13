# Hello, Operator!

This is the source code that powers [Hello, Operator!](http://lazerwalker.com/hellooperator).


## Setup

1. Be sure you're using Node version `0.12.x`. This is because `node-serialport` won't compile on OS X on anything newer. I personally use [nvm](https://github.com/creationix/nvm) to manage this; it is also specified in `package.json`. It is possible newer versions of Node will work in non-OS X environments, but that has not been tested.

2. Install coffee-script globally: `npm install -g coffee-script`

3. Git clone this repo: `git clone git@github.com:lazerwalker/switchboard.git`

4. Install dependencies: `npm install`

5. Modify `runner.coffee` to include the appropriate game interfaces with appropriate options (e.g. Arduino USB serial ports)

6. Run `coffee runner.coffee`


## iOS Project

To run the included iPad version of the game, you need to compile the codebase into a single JS file. Run `./compile` in the root directory, then run and compile the Xcode workspace that lives in the `ios` subdirectory. This will only work on OS X with the latest version of Xcode.

By default, the iOS app will just run the game itself. You can also use it as a remote client to a server-run instance of the game; that requires a deployment of the server component, which isn't currently documented. Sorry about that.


## Caveats

This codebase isn't in great shape. It's persisted across three very different hardware iterations, and probably should have been rewritten from the ground up by now. Due to the severe time constraints surrounding this project, software engineering quality has generally taken second place to hardware fabrication. There's a lot of bad code and a lot of dead code. Some of the more recent code does have tests, which can be run via `npm test`.

Similarly, and perhaps more relevant, this documentation is terrible. If you actually intend on getting this up and running, you'll probably need to bug me personally. I'm not exactly sure who I expect to actively try to use this repo, but in general I'm cool with people contacting me with questions about it. Feel free to shoot me an email at hellooperator@lazerwalker.com, or tweet at me @lazerwalker.


## License

This project is licensed under the MIT License.

Copyright (c) 2014-2016 Mike Lazer-Walker and MIT Media Lab

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
