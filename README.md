# snow-crash

A basic shell script for creating and testing malicious QR codes.

This script is part of my final project for 4th year at IT Carlow. It is definitely not the best or most efficient script but hey, it works. 
I hope to rewrite this script at some point in the future with everything presented in a TUI interface. 

Snow Crash was written and tested on MX Linux but should work fine on any system using Bash or ZSH.

The following command line tools should be installed; 

libqrencode: Follow the instructions on this page -> https://fukuchi.org/works/qrencode/
             There is a version in the Debian repositories that works but it's a little dated.  

dialog: A lot of linux distros ship with dialog installed but if it's missing then "sudo apt install dialog" or similar.  

feh: feh is a fantastic lightweight image viewer. It comes installed on many systems but if it's missing on yours you can get it here -> https://feh.finalrewind.org/

zbarimg: "sudo apt install zbar-tools" or follow instructions on the official site -> http://zbar.sourceforge.net/index.html

