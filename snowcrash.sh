#!/usr/bin/env bash

#TODO
#Lots, but after I get through 4th year.

menuOne(){
  echo "1  -  Create multiple QR Codes Using Wordlists"
  echo ""
  echo "Select a wordlist using the menu. QR codes will be placed in a folder with the same name as the chosen wordlist."
  echo "Use tab or arrow keys to move between the windows." 
	echo "Within the directory or filename windows, use the up/down arrow keys to scroll the current selection."
	echo "Use the space bar to copy the current selection into the text-entry window. Press enter to select the wordlist."
  echo ""
  pressEnter
  
  fullPath=$(realpath $0)
  dirPath=$(dirname $fullPath)
  listPath="$dirPath/wordlists/"
  
  wordlist=$(dialog --stdout --clear --title "Select Wordlist" --backtitle "1  -  Create multiple QR Codes Using Wordlists" --fselect $listPath 21 50)
  clear
  
	if [ -f "$wordlist" ]; then
		echo ""
		echo "Starting QR code creation....."
		
		outFolder=$(basename -s .txt $wordlist)
		mkdir -p $dirPath/output/$outFolder
		count=1

		while IFS= read -r line; do
			filename=${line:0:35}
			filename=${filename////'?'}
			# This is to get rid of forward slashes in filenames. They will still be in the payload.
			# This works for all files on *nix machines but Windows gets upset if filenames have
			# colons in them. If moving files to a Windows box start by stripping offending chars 
			# from the filename. 
			
			# Bash supports string replacement natively.
			# ${parameter//patern/string} - first double slash means replace all matches.
			# Alternative: filename=$(sed "s:/:'':g" <<< $filename)
			
			echo $line | qrencode -s 4 -o "$dirPath/output/$outFolder/$count-$filename.png"
			
			now=$(date +"%F %T.%N")
			echo "$now :: $count :: $line" >> "$dirPath/output/$outFolder/log.txt"
			
			count=$((count+1))
		done < $wordlist
		
		unset filename
		
		echo ""
		echo "Done!"
		echo ""
		echo "See log file in output folder for further details"
	else
		echo ""
		echo "No wordlist selected."
	fi
	
	unset wordlist
}

subMenuOne(){
  echo "2.1  -  Create a QR Code Using Manual String Input"
  echo ""
  echo "The QR code will be placed in the output folder." 
	echo "It will be in the format; timestamp-input.png"
  echo "This can be used for URLs."
	echo "Make sure you use the full address e.g. https://www.google.com instead of simply google.com"
	echo ""
  echo -n "Input --> "
  read line
  
	if [ -z "$line" ]; then
		echo ""
		echo "Can't create QR code from empty input."
	else
		echo ""
		echo "Starting QR code creation....."
		fullPath=$(realpath $0)
		dirPath=$(dirname $fullPath)
		
		filename=${line:0:30}
		filename=${filename////'?'}
		now=$(date +"%F %T")
		
		echo $line | qrencode -s 4 -o "$dirPath/output/$now-$filename.png" 
		echo "$now :: Manual String Input :: $line" >> "$dirPath/output/log.txt"
		
		unset line
		unset filename
		
		echo ""
		echo "Done!"
		echo ""
		echo "See log file in output folder for further details"
		echo ""
	fi
}

subMenuTwo(){
  echo "2.2  -  Create a QR Code Using Text File as String Input"
  echo ""
  echo "This option is for encoding a text file or text-based script as a single QR code."
  echo "It should not be used for binaries as these must be encoded using qrencode's 8bit mode."
  echo "Go back to the main menu and select option 3 for encoding binaries (e.g. .exe or similar)."
	echo ""
  echo "Use arrow keys to navigate, Spacebar to select and Enter to start QR Code creation."
  echo "QR code will be placed in output folder. It will be in the format; timestamp-filename.png"
  echo ""
  pressEnter
  
  fullPath=$(realpath $0)
  dirPath=$(dirname $fullPath)
  textPath="$dirPath/textfiles/"
	
  txt=$(dialog --stdout --clear --title "String Input" --backtitle "2.2  -  Create a QR Code Using Text File as String Input" --fselect $textPath 21 50)
  clear
  
  if [ -f "$txt" ] && [ -s "$txt" ]; then
		filename=${txt##*/} # Get the filename
  	now=$(date +"%F %T")
  	
		cat $txt | qrencode -s 4 -o "$dirPath/output/$now-$filename.png" 
		# Can use qrencode's -r flag or cat for this one. 
  	echo "$now :: Text File as String Input :: $txt" >> "$dirPath/output/log.txt"
		
		unset txt
		
		echo ""
		echo "Done!"
		echo ""
		echo "See log file in output folder for further details"
		echo ""
  else
		echo ""
  	echo "Not a valid file or the file is empty."
		echo "Please doublecheck and try again."
  fi
}

subMenuThree(){
	echo "2.3  -  Create a QR Code to Send an SMS message"
	echo ""
  echo "This option is will create a QR code that, when scanned, will send an SMS."
	echo "Typically, when scanned, this will open the user's SMS application of choice and prompt them to press send."
	echo "This means some form of social engineering to convince the user that the SMS is safe to send will be necessary."
  echo ""
	echo "QR code will be placed in output folder. It will be in the format; sms-input.png"
	echo ""
	echo "First, enter the phone number to send the SMS to. It should be in the international telephone number format e.g. +0035312345678"
	echo "Dashes and spaces will work on some systems but leaving them out typically produces better results."
	echo ""
  echo -n "Phone number (don't forget the +) --> "
  read number
	
	if [ -z "$number" ]; then
		echo ""
		echo "Phone number cannot be blank."
	else
		sms=$(dialog --stdout --clear --title "SMS message" --backtitle "2.3  -  Create a QR Code to Send an SMS message" --inputbox "Enter your SMS" 10 60)
		clear
		
		if [ -z "$sms" ]; then
			echo ""
			echo "SMS cannot be blank."
		else
			fullPath=$(realpath $0)
			dirPath=$(dirname $fullPath)
			
			payload="smsto:$number:$sms"
			
			filename=${sms:0:30}
			filename=${filename////'?'}
			now=$(date +"%F %T")
			
			echo $payload | qrencode -s 4 -o "$dirPath/output/sms-$filename.png" 
			echo "$now :: SMS :: $payload" >> "$dirPath/output/log.txt"
			
			unset number
			unset sms
			
			echo ""
			echo "Done!"
			echo ""
			echo "See log file in output folder for further details"
			echo ""
		fi
	fi
}

subMenuFour(){
  echo "2.4  -  Create a QR Code to Call a Phone Number"
	echo ""
  echo "This option is will create a QR code that, when scanned, will prompt a user to make a telephone call."
	echo "Typically, when scanned, the user will be prompted to dial call."
	echo "This can also be used to call/execute a UUSD or MMI code."
  echo ""
	echo "QR code will be placed in output folder. It will be in the format; tel-input.png"
	echo ""
	echo "Enter the phone number in the international telephone number format e.g. +0035312345678"
	echo "Dashes and spaces will work on some systems but leaving them out typically produces better results."
	echo ""
  echo -n "Phone number or UUSD/MMI code --> "
  read number
	
	if [ -z "$number" ]; then
		echo ""
		echo "Phone number or UUSD/MMI code cannot be blank."
	else
		fullPath=$(realpath $0)
		dirPath=$(dirname $fullPath)
		
		payload="tel:$number"
		now=$(date +"%F %T")
		filename=${number:0:20}
		filename=${filename////'?'}
		
		echo $payload | qrencode -s 4 -o "$dirPath/output/tel-$filename.png" 
		echo "$now :: TEL/UUSD/MMI :: $payload" >> "$dirPath/output/log.txt"
		
		unset number
		unset filename
		
		echo ""
		echo "Done!"
		echo ""
		echo "See log file in output folder for further details"
		echo ""
	fi
}

subMenuFive(){
	echo "2.5  -  Create a QR Code to Send an Email"
	echo ""
  echo "This option is will create a QR code that, when scanned, will prompt a user to send an email."
	echo "Typically, when scanned, the user will be prompted from their email app (gmail, outlook, etc.)."
  echo ""
	echo "QR code will be placed in output folder. It will be in the format; email-input.png"
	echo ""
  echo -n "Recipient email address --> "
  read email
	
	if [ -z "$email" ]; then
		echo ""
		echo "Cannot send email without an email address."
	else
		echo ""
		echo -n "Subject line --> "
		read subject
		echo ""
		
		body=$(dialog --stdout --clear --title "Email" --backtitle "2.5  -  Create a QR Code to Send an Email" --inputbox "Enter your email" 10 60 )
		clear
		
		payload="MATMSG:TO:$email;SUB:$subject;BODY:$body;;"
		# Subject and body can technically be left blank so no need to check.
		
		fullPath=$(realpath $0)
		dirPath=$(dirname $fullPath)
		now=$(date +"%F %T")
		
		filename=${body:0:50}
		filename=${filename////'?'}
		
		echo $payload | qrencode -s 4 -o "$dirPath/output/email-$filename.png" 
		echo "$now :: Email :: $payload" >> "$dirPath/output/log.txt"
		
		unset email
		unset subject
		unset body
		
		echo ""
		echo "Done!"
		echo ""
		echo "See log file in output folder for further details"
		echo ""
	fi
}

subMenuSix(){
	echo "2.6  -  Create a QR Code to Log into a WiFi Network"
	echo ""
  echo "This option is will create a QR code that, when scanned, will connect a user to a wireless access point."
  echo ""
	echo "QR code will be placed in output folder. It will be in the format; wifi-ssid.png"
	echo ""
  echo -n "Network SSID --> "
  read ssid
	
	if [ -z "$ssid" ]; then
		echo ""
		echo "SSID cannot be blank."
	else
		echo ""
		echo -n "Password --> "
		read pass
		
		echo ""
		echo "Select the security standard."
		echo ""
		echo "1  -  WEP"
		echo "2  -  WPA/WPA2"
		echo "3  -  none"
		echo ""
		echo -n "Enter selection (number) --> "
		read choice
		
		case $choice in
			1 ) sec="WEP" ;;
			2 | * ) sec="WPA" ;;
			3 ) sec="nopass" ;;
		esac
		
		payload="WIFI:S:$ssid;T:$sec;P:$pass;;"
		
		fullPath=$(realpath $0)
		dirPath=$(dirname $fullPath)
		now=$(date +"%F %T")
		
		filename=${ssid:0:30}
		filename=${filename////'?'}
		
		echo $payload | qrencode -s 4 -o "$dirPath/output/wifi-$filename.png" 
		echo "$now :: Join WiFi Network :: $payload" >> "$dirPath/output/log.txt"
		
		unset ssid
		unset pass
		unset choice
		unset sec
		
		echo ""
		echo "Done!"
		echo ""
		echo "See log file in output folder for further details"
		echo ""
	fi
}

menuTwo(){
  echo "2  -  Create a QR Code Using String Input"
  echo ""
  echo "If creating more than one QR code consider creating a custom wordlist and using option 1 instead."
  echo "Pressing Enter will bring you to a submenu where you can select what type of QR code to create."
  echo ""
  pressEnter
  
  until [ "$submenu" = "0" ]; do
  	clear
  	echo ""
  	echo "Below is a list of types of QR Codes that can be created (More to come if 4th year doesn't finish me)"
  	echo ""
  	echo "1  -  Create a QR Code Using Manual String Input"
  	echo "2  -  Create a QR Code Using Text File (txt, perl, bat, etc.) as String Input"
  	echo "3  -  SMS - Create a QR Code to Send an SMS message"
  	echo "4  -  TEL - QR Code to Call a Phone Number"
  	echo "5  -  MATMSG - QR Code to Send an Email"
  	echo "6  -  WIFI AP - QR Code to Connect to a WiFi Network"
  	echo "0  -  Exit"
  	echo ""
  	echo -n "Enter selection (number): "
  	read submenu
  	echo ""
  	case $submenu in
    	1 ) clear ; subMenuOne ; pressEnter ;;
    	2 ) clear ; subMenuTwo ; pressEnter ;;
    	3 ) clear ; subMenuThree ; pressEnter ;;
    	4 ) clear ; subMenuFour ; pressEnter ;;
    	5 ) clear ; subMenuFive ; pressEnter ;;
    	6 ) clear ; subMenuSix ; pressEnter ;;
    	0 ) clear ; unset submenu ; mainMenu ;;
    	* ) clear ; fail ; pressEnter ;;
  	esac
  done
}

menuThree(){
  echo "3  -  Create a QR Code Using Binary File"
  echo ""
  echo "Select a binary (e.g. .exe .elf .apk) using the menu."
  echo "Use arrow keys to navigate, Spacebar to select and Enter to start QR Code creation."
  echo "QR code will be placed in output folder. It will be in the format; timestamp-filename.png"
  echo ""
  pressEnter
  
  fullPath=$(realpath $0)
  dirPath=$(dirname $fullPath)
  binPath="$dirPath/binaries/"
	
  file=$(dialog --stdout --clear --title "Select a File" --backtitle "3  -  Create a QR Code Using Binary File" --fselect $binPath 21 50)
  clear
  
  if [ -f "$file" ]; then
		size=$(du -b $file | awk '{print $1}') # Return size in bytes.
		
		if [ "$size" -lt 2954 ]; then
			filename=${file##*/} # Get the filename
			now=$(date +"%F %T")
			
			# pass it through qrencode. Use -r for reading in (need this for binaries??), -8 for 8bit mode, -s 4 for the pixel size.
			qrencode -r $file -8 -s 4 -o "$dirPath/output/$now-$filename.png"
			echo "$now :: Binary File :: $file" >> "$dirPath/output/log.txt"
			
			echo ""
			echo "Binary QR code created, check output folder."
			echo ""
			echo "See log file in output folder for further details"
			echo ""
		else
			echo ""
			echo "File is larger than 2953 bytes so can't fit into a v40 QR code."
		fi
  else
		echo ""
		echo "Not a valid file or the file is empty."
		echo "Please doublecheck and try again."
  fi
	
	unset file
}

menuFour(){
  echo "4  -  Test QR Code(s) With ZBar"
	echo ""
  echo "Test string-based QR codes to see if they encoded correctly." 
	echo "Testing QR codes with executables will display strange 8bit symbols because of how they are encoded." 
	echo "Testing binaries/executables should be done on the targeted platform using ZBar or ZBarcam."
	echo ""
	echo "First, select if you want to test one or multiple QR codes."
	echo ""
	echo "1  -  Single QR Code."
	echo "2  -  Multiple QR Codes."
	echo ""
	echo -n "Enter selection (number) --> "
	read choice
  
	# choice="${choice//[$'\t\r\n ']}"
	# remove newline, carriage return, etc. to do integer comparison without bash giving out.
	# Still gives out so new if else wrapper to drop non-int input. 
	
	fullPath=$(realpath $0)
	dirPath=$(dirname $fullPath)
	outPath="$dirPath/output/"
	now=$(date +"%F %T")
	
	if [ -z "${choice##*[!0-9]*}" ];  then
		echo ""
    echo "That input was not understood. Please choose option 1 or 2."
	else
		if [ "$choice" -eq 1 ]; then
			file=$(dialog --stdout --clear --title "Test Single File" --backtitle "4  -  Test QR Code(s) With ZBar" --fselect $outPath 21 50)
			clear
			
			if [ -f "$file" ] && [ -s "$file" ] && [ ${file: -4} == ".png" ]; then
				filename=${file##*/} #filename minus path
				
				echo "$now :: Single QR Code Test :: $filename" >> "$dirPath/tests/test-single-$filename.txt"
				zbarimg -q --raw "$file" | tee -a "$dirPath/tests/test-single-$filename.txt"
				echo "" >> "$dirPath/tests/test-single-$filename.txt"
				
				echo ""
				echo "Done!"
				echo ""
				echo "See log file in tests folder for further details."
			else
				echo ""
				echo "Not a valid file or the file is empty."
				echo "Please doublecheck and try again."
			fi
			
			unset file
		elif [ "$choice" -eq 2 ]; then
			dir=$(dialog --stdout --clear --title "Test Multiple Files" --backtitle "4  -  Test QR Code(s) With ZBar" --dselect $outPath 21 50)
			clear
			
			if [ -d "$dir" ]; then
				dirname="${dir%"${dir##*[!/]}"}" 		# remove trailing /
				dirname="${dirname##*/}"						# remove everything before the last /
				
				echo "$now :: Multiple QR Codes Test" >> "$dirPath/tests/test-multiple-$dirname.txt"
				echo "" >> "$dirPath/tests/test-multiple-$dirname.txt"
				
				shopt -s nullglob
				ls $dir/*.png | sort -V > tmp
				
				IFS=$'\n' # Need to change the IFS or for loop will start splitting input on spaces.
				for f in $(cat tmp); do
					zbarimg -q --raw "$f" >> "$dirPath/tests/test-multiple-$dirname.txt"
				done
				
				rm -f tmp
				unset dir
				unset dirname
				
				echo ""
				echo "Done!"
				echo ""
				echo "See log file in tests folder for further details."
				echo ""
			else
				echo ""
				echo "Not a valid directory"
				echo "Please doublecheck and try again."
			fi		
		else
			echo ""
			echo "Must select Single (1) or Multiple (2)."
		fi
	fi
	unset choice
}

menuFive(){
  echo "5  -  Slideshow Options"
  echo ""
  echo "QR code will be displayed in full screen." 
	echo "First, enter the number of seconds to wait between displaying each image."
  echo "This will depend on the capabilities of the camera/scanner being used for testing."
	echo "Typically a value of 3 - 6 seconds is appropriate. Please use an integer i.e. 3, 4 NOT 4.1"
	echo ""
  echo "Then, please select the directory containing the image files. Images are assumed to be in .png format."
  echo ""
  echo -n "Wait x seconds between images --> "
  read sec
  #read -r -p "Wait x seconds between images --> " sec
	
	if [ -z "${sec##*[!0-9]*}" ];  then
		# The above str replacement is removing all the digits
		# and checking if sec is null/zero length.
		echo ""
    echo "Input was not a number. "
	else
		if [ $sec -gt 0 ]; then
			fullPath=$(realpath $0)
			dirPath=$(dirname $fullPath)
			imagePath="$dirPath/output/"
			
			images=$(dialog --stdout --clear --title "Slideshow Directory" --backtitle "5  -  Slideshow Options" --dselect $imagePath 21 50)
			clear
			
			if [ -d "$images" ]; then
				echo "Use ESC to terminate early."
				echo "Slideshow will start in 5 seconds.... "
				sleep 5
				
				feh -D $sec -F --on-last-slide quit -q  $images/*.png
				
				echo ""
				echo "Finished Slideshow."
			else
				echo ""
				echo "Not a valid directory."
				echo "Please doublecheck and try again."
			fi
			
			unset images
		else
			echo ""
			echo "There must be a delay of at least 1 second."
		fi		
	fi
	unset sec
}

pressEnter(){
  echo ""
  echo "Press Enter to Continue"
  read
  clear
}

fail(){
  echo "That input wasn't understood. Try again."
}

mainMenu(){
  until [ "$selection" = "0" ]; do
  	clear
  	echo ""
  	echo "1  -  Create multiple QR Codes Using Wordlists"
  	echo "2  -  Create a QR Code Using String Input"
  	echo "3  -  Create a QR Code Using Binary File"
  	echo "4  -  Test QR Code(s) With ZBar"
  	echo "5  -  Slideshow Options"
  	echo "0  -  Exit"
  	echo ""
  	echo -n "Enter selection (number): "
  	read selection
  	echo ""
  	case $selection in
    	1 ) clear ; menuOne ; pressEnter ;;
    	2 ) clear ; menuTwo ; pressEnter ;;
    	3 ) clear ; menuThree ; pressEnter ;;
    	4 ) clear ; menuFour ; pressEnter ;;
    	5 ) clear ; menuFive ; pressEnter ;;
    	0 ) clear ; exit ;;
    	* ) clear ; fail ; pressEnter ;;
  	esac
  done
}

#FUNCTIONS END SCRIPT STARTS !!! FUNCTIONS END SCRIPT STARTS !!! FUNCTIONS END SCRIPT STARTS !!!

fullPath=$(realpath $0)
dirPath=$(dirname $fullPath)

mkdir -p $dirPath/binaries/
mkdir -p $dirPath/output/
mkdir -p $dirPath/textfiles/
mkdir -p $dirPath/tests/
mkdir -p $dirPath/wordlists/

clear

cat << "EOF"

When the computer crashed and wrote gibberish into the bitmap, 
the result was something that looked vaguely like static on a 
broken television set -- a 
 ____                         ____               _     
/ ___| _ __   _____      __  / ___|_ __ __ _ ___| |__  
\___ \| '_ \ / _ \ \ /\ / / | |   | '__/ _` / __| '_ \ 
 ___) | | | | (_) \ V  V /  | |___| | | (_| \__ \ | | |
|____/|_| |_|\___/ \_/\_/    \____|_|  \__,_|___/_| |_|                                                       

------------------------------------------------------------------------

Malicious QR Code Generator

Brendan D. Burke - BrendanB7@protonmail.com

Disclaimer: ALWAYS get written permission before pentesting a system.
I'm not responsible if you break something with a QR code. 

------------------------------------------------------------------------
EOF

pressEnter

mainMenu
