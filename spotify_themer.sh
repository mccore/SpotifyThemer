#!/bin/bash


#Colors
declare -A COLORS
#These are the different color codes
#for spotify's default theme
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

APPSDIR="/usr/share/spotify/Apps"
ICONSDIR="/usr/share/spotify/icons"

# Make sure we're root
[ `id -u` -eq 0 ] || die "You must be root to run $0"
# Handle arguments and set parameter values

# This is a massive block of crap so we're making a clear division...
# FIXME: Do we want to allow both -c and -i in the same command?

# Assume false
DO_ICONS=false
while test $# -gt 0; do
        case "$1" in
                -c)
						shift
						if test $# -gt 0; then
							if [ ${COLORS[$1]} ]; then	
								export choice=${COLORS[$1]}
                            else
							    echo "not a valid color option"
                                exit 1
							fi
						else
								echo "no color specified"
								exit 1
						fi
						shift
						;;
				-h|--help)
                        echo "SpotifyThemer - Customize the theme of spotify for linux"
                        echo " "
                        echo "spotify_themer [options] [COLOR]"
                        echo " "
						echo "Colors: RED, CYAN, BLACK, YELLOW, LIGHTBLUE, PURPLE,"
                        echo "        WHITE, FLAMES"
		                echo " "
                        echo "options:"
                        echo "-c, --color               specify a color option"
						echo "-h, --help                show brief help"
                        echo "-i, --icons               create new icons with COLOR"
                        exit 0
                        ;;
                -i)
                        shift
                        if test $# -gt 0; then
                                export choice=${COLORS[$1]}
								export DO_ICONS=true
                        else
                                echo "no color specified"
                                exit 1
                        fi
                        shift
                        ;;
                #icons*)
                #        export PROCESS=`echo $1 | sed -e 's/^[^=]*=//g'`
                #        shift
                #        ;;
                *)
                        break
                        ;;
        esac
done


###########################################
echo "Starting spotify_themer with color $1"

#create a backup folder of the original .spa files (and only the originals). This means that after every update this folder will need to be cleared/deleted.
if [[ ! -d $APPSDIR/.backups ]]; then
	mkdir $APPSDIR/.backups;
else
	# Modify from the original, else there will be nothing green to change
	cp $APPSDIR/.backups/* $APPSDIR/
fi

#loop through each .spa file
for file in $APPSDIR/*; do
	no_path=$(echo "$file" | sed "s/\/usr\/share\/spotify\/Apps\///")
	#ensure that only the originals are backed up
	if [[ ! -f $APPSDIR/.backups/$no_path ]]; then
		cp $file $APPSDIR/.backups;
	fi

	no_extension=$(echo "$file" | sed "s/.spa//")
	#extract the .spa files to folders so that they can be edited. file-roller is used since the .spa files act like .zip files. The if statement is to leave the backup folder untouched
	if [[ "$no_extension" != "$APPSDIR/.backups" ]]; then
		file-roller --force -f $file --extract-to=$no_extension 2> /dev/null;
	fi

	#every .spa file (and therefore .spa folder) has a css subfolder. The loop goes through all css files in that css folder and changes the default hex code to the specified one ($choice)
	# We want to exlude the colors attached to 'charts'
    # There are only two such cases, so this naive regex will do.
    CHARTS="*chart*"
	for style in $no_extension/css/*; do
     	if ! [[ $style == $CHARTS ]];then
			echo $style;
			for code in $SPOTIFY_GREEN; do
				sed -i "s/$code/$choice/g" $style;
			done
		fi
	done

	#re-zip the .spa fodler (and therefore the changed files) and remove the folder afterwards. It is important that zip is used because .spa are basically .zip.
	if [[ "$no_extension" != "$APPSDIR/.backups" ]]; then
		rm $file;
		cd $no_extension;
		zip -r $file *;
		cd - 1> /dev/null;
		rm -rf $no_extension;
	fi
done

if [[ ! -d $ICONSDIR/.backups ]]; then
	mkdir $ICONSDIR/.backups;
fi

for file in $ICONSDIR/*; do
	no_path=$(echo "$file" | sed "s/\/usr\/share\/spotify\/icons\///")
	if [[ ! -f $APPSDIR/.backups/$no_path ]]; then
		cp $file $ICONSDIR/.backups;
	fi
done

#convert the 512 to red since with fuzzing it loosk the best. Then resize that for the rest. The last command resizes the 512 and creates an ico which is what spotify actually uses. I have no idea what the other .png files are for. It is possible they are used only once at install to create the initial ico and then never again.
if [ "$DO_ICONS" = true ]; then
	echo "Changing icons..."
	convert $ICONSDIR/spotify-linux-512.png -fuzz 47.102% -fill "#$choice" -opaque "#1ED760" $ICONSDIR/spotify-linux-512.png
	convert -resize 256x256 $ICONSDIR/spotify-linux-512.png $ICONSDIR/spotify-linux-256.png
	convert -resize 128x128 $ICONSDIR/spotify-linux-512.png $ICONSDIR/spotify-linux-128.png
	convert -resize 64x64 $ICONSDIR/spotify-linux-512.png $ICONSDIR/spotify-linux-64.png
	convert -resize 48x48 $ICONSDIR/spotify-linux-512.png $ICONSDIR/spotify-linux-48.png
	convert -resize 32x32 $ICONSDIR/spotify-linux-512.png $ICONSDIR/spotify-linux-32.png
	convert -resize 24x24 $ICONSDIR/spotify-linux-512.png $ICONSDIR/spotify-linux-24.png
	convert -resize 22x22 $ICONSDIR/spotify-linux-512.png $ICONSDIR/spotify-linux-22.png
	convert -resize 16x16 $ICONSDIR/spotify-linux-512.png $ICONSDIR/spotify-linux-16.png
	convert -background transparent $ICONSDIR/spotify-linux-512.png -define icon:auto-resize=16,32,48,256 $ICONSDIR/spotify_icon
fi

