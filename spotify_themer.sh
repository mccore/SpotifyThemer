#!/bin/bash

#TODO:
#1) up arrow in charts should reain unchanged
#2) compile .png files into .ico
#3) add more options for changing colors (in progress)
#4) add comments to code (done)
#5) allow people to just enter color options on the command line (done)
	#-this can be done by displaying options and letting people choose or by outputting choices in help flag (I like his option best)

#Colors
declare -A COLORS
SPOTIFY_GREEN="1ED760 1DB954 1CA24B"
COLORS["RED"]="F44236"
COLORS["CYAN"]="33E3FF"
COLORS["GREEN(DEF)"]="1ED760"
COLORS["BLACK"]="000000"
COLORS["YELLOW"]="CCDC38"
COLORS["LIGHTBLUE"]="00BBD4"
COLORS["PURPLE"]="6639B6"
COLORS["WHITE"]="FFFFFF"
COLORS["FLAMES"]="FF9800"

Apps="/usr/share/spotify/Apps"
icons="/usr/share/spotify/icons"

if [[ "$1" == "-h" || "$1" == "help" || "$1" == "--help" ]]; then
	echo "Color options:"
	for key in ${!COLORS[@]}; do
    		echo ${key} "=" ${COLORS[${key}]}
	done
		echo "Use -hex or hex as first argument and then a hex code as the second argument to use your own color"
		echo "Note: Changed icons look terrible. This is being worked on. As of now it is recommended not to change them."
	exit
fi

#set the choice to be used by sed when changing color codes in the extracted css ciles
if [ ${COLORS[$1]} ]; then
	choice=${COLORS[$1]}
elif [[ "$1" == "-hex" || "$1" == "hex" ]]; then
	choice=$2
elif [[ "$1" == "-i" || "$1" == "icons" ]]; then
	choice=$2
else
	echo "Not a choice! Exiting..."
	exit;
fi

#create a backup folder of the original .spa files (and only the originals). This means that after every update this folder will need to be cleared/deleted.
if [[ ! -f $Apps/.backups ]]; then
	mkdir $Apps/.backups;
fi

#loop through each .spa file
for file in $Apps/*; do
	no_path=$(echo "$file" | sed "s/\/usr\/share\/spotify\/Apps\///")
	#ensure that only the originals are backed up
	if [[ ! -f $Apps/.backups/$no_path ]]; then
		cp $file $Apps/.backups;
	fi

	no_extension=$(echo "$file" | sed "s/.spa//")
	#extract the .spa files to folders so that they can be edited. file-roller is used since the .spa files act like .zip files. The if statement is to leave the backup folder untouched
	if [[ "$no_extension" != "$Apps/.backups" ]]; then
		file-roller --force -f $file --extract-to=$no_extension 2> /dev/null;
	fi

	#every .spa file (and therefore .spa folder) has a css subfolder. The loop goes through all css files in that css folder and changes the default hex code to the specified one ($choice)
	for style in $no_extension/css/*; do
		echo $style;
		for code in $SPOTIFY_GREEN; do
			sed -i "s/$code/$choice/g" $style;
		done
	done

	#re-zip the .spa fodler (and therefore the changed files) and remove the folder afterwards. It is important that zip is used because .spa are basically .zip.
	if [[ "$no_extension" != "$Apps/.backups" ]]; then
		rm $file;
		cd $no_extension;
		zip -r $file *;
		cd - 1> /dev/null;
		rm -rf $no_extension;
	fi
done

if [[ ! -f $icons/.backups ]]; then
	mkdir $icons/.backups;
fi

for file in $icons/*; do
	no_path=$(echo "$file" | sed "s/\/usr\/share\/spotify\/icons\///")
	if [[ ! -f $Apps/.backups/$no_path ]]; then
		cp $file $icons/.backups;
	fi
done

#convert the 512 to red since with fuzzing it loosk the best. Then resize that for the rest. The last command resizes the 512 and creates an ico which is what spotify actually uses. I have no idea what the other .png files are for. It is possible they are used only once at install to create the initial ico and then never again.
if [[ "$1" == "-i" || "$1" == "icons" ]]; then
	convert $icons/spotify-linux-512.png -fuzz 47.102% -fill "#$choice" -opaque "#1ED760" $icons/spotify-linux-512.png
	convert -resize 256x256 $icons/spotify-linux-512.png $icons/spotify-linux-256.png
	convert -resize 128x128 $icons/spotify-linux-512.png $icons/spotify-linux-128.png
	convert -resize 64x64 $icons/spotify-linux-512.png $icons/spotify-linux-64.png
	convert -resize 48x48 $icons/spotify-linux-512.png $icons/spotify-linux-48.png
	convert -resize 32x32 $icons/spotify-linux-512.png $icons/spotify-linux-32.png
	convert -resize 24x24 $icons/spotify-linux-512.png $icons/spotify-linux-24.png
	convert -resize 22x22 $icons/spotify-linux-512.png $icons/spotify-linux-22.png
	convert -resize 16x16 $icons/spotify-linux-512.png $icons/spotify-linux-16.png
	convert -background transparent $icons/spotify-linux-512.png -define icon:auto-resize=16,32,48,256 $icons/spotify_icon
fi

