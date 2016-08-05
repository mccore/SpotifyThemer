#!/bin/bash

#TODO:
#1) up arrow in charts should reain unchanged
#2) add a usage flag
#3) add more options for changing colors
#4) add comments to code
#5) allow people to just enter color options on the command line
	#-this can be done by displaying options and letting people choose or by outputting choices in help flag (I like his option best)

#Colors
declare -A COLORS
SPOTIFY_GREEN="1ED760 1DB954 1CA24B"
COLORS["RED"]="F44236"
COLORS["CYAN"]="33E3FF"
COLORS["PURPLE"]="6E33FF"
if [ ${COLORS[$1]} ]; then
	choice=${COLORS[$1]}
else
	echo "Not a choice! Exiting..."
	exit;
fi

if [[ ! -f /usr/share/spotify/Apps/.backups ]]; then
	mkdir /usr/share/spotify/Apps/.backups;
fi

for file in /usr/share/spotify/Apps/*; do
	no_path=$(echo "$file" | sed "s/\/usr\/share\/spotify\/Apps\///")
	if [[ ! -f /usr/share/spotify/Apps/.backups/$no_path ]]; then
		cp $file /usr/share/spotify/Apps/.backups;
	fi

	no_extension=$(echo "$file" | sed "s/.spa//")
	#echo "$no_extension"/css
	if [[ "$no_extension" != "/usr/share/spotify/Apps/.backups" ]]; then
		file-roller --force -f $file --extract-to=$no_extension 2> /dev/null;
	fi

	for style in $no_extension/css/*; do
		echo $style;
		for code in $SPOTIFY_GREEN; do
			sed -i "s/$code/$choice/g" $style;
		done
	done

	if [[ "$no_extension" != "/usr/share/spotify/Apps/.backups" ]]; then
		rm $file;
		cd $no_extension;
		zip -r $file *;
		cd - 1> /dev/null;
		rm -rf $no_extension;
	fi
done
