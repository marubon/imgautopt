imgautopt
==============

**A command line to automate resize and compress images at once for the Mac. **

Imgautopt is a shell script which uses the following external commands and sips command included in the MacOS. 
Binaries of the following commands (i.e. binaries provided by this repository) are same as the commands found 
in ImageOptim.app/Contents/MacOS/

* pngquant http://pngquant.org/
* jpegoptim http://www.kokkonen.net/tjko/projects.html

##Supported Format
* JPEG
* PNG

## Usage

Download all files and deploy them to your chosen direcotry, 
and add the full path to your environment variable (i.e. $PATH).

The following is a example to add the script directory to the environment variable.

	export PATH=${PATH}:<FULL PATH OF YOUR CHOSEN DIRECTORY>

In the beginning you have to move current directory to a directory including target images
because the script resizes and compresses images in current directory based on specified resampling width.
Next execute imgautopt with resampling width.
The script outputs resized and compressed images to "./output" directory.

	$ cd <directory contains target images>
    $ imgautopt <resampling width>

 
## Log

The script outputs a log to "./log" directory, and the log describes image original size, resized size and compressed size, 
and also saved size and its percentage.

	2013-04-25 04:29:04 [INFO] imageopt.sh [START SCRIPT]
	2013-04-25 04:29:04 [INFO] imageopt.sh [RESIZE] 2013-04-21_2155.png 170.646kb 65.850kb -104.796kb -62.00%
	2013-04-25 04:29:04 [INFO] imageopt.sh [RESIZE] 2013-04-21_2157.png 117.056kb 68.757kb -48.299kb -42.00%
	2013-04-25 04:29:09 [INFO] imageopt.sh [COMPRESS] 2013-04-21_2155.png 65.850kb 20.706kb -45.144kb -69.00%
	2013-04-25 04:29:09 [INFO] imageopt.sh [COMPRESS] 2013-04-21_2157.png 68.757kb 21.114kb -47.643kb -70.00%
	2013-04-25 04:29:20 [INFO] imageopt.sh [END SCRIPT] Normal exit status 0

## License

Imgautopt itself is available under the MIT License, and a license of other commands 
(i.e. pngquant, jpegoptim and sips) is based on each license.

	The MIT License (MIT)

	Copyright (c) 2013 Daisuke Maruyama
	https://github.com/marubon

	Permission is hereby granted, free of charge, to any person obtaining a copy
	of this software and associated documentation files (the "Software"), to deal
	in the Software without restriction, including without limitation the rights
	to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
	copies of the Software, and to permit persons to whom the Software is
	furnished to do so, subject to the following conditions:

	The above copyright notice and this permission notice shall be included in
	all copies or substantial portions of the Software.

	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
	LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
	OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
	THE SOFTWARE.
