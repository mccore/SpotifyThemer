#!/bin/bash

if [[ ! -f /usr/share/spotify/Apps/.backups ]]; then
	mkdir /usr/share/spotify/Apps/.backups;
fi

for file in /usr/share/spotify/Apps/*; do
	if [[ condition ]]; then
		cp $file /usr/share/spotify/Apps/.backups;
	fi

	no_extension=$(echo "$file" | sed "s/.spa//")
	#echo "$no_extension"/css
	if [[ "$no_extension" != "/usr/share/spotify/Apps/.backups" ]]; then
		file-roller --force -f $file --extract-to=$no_extension 2> /dev/null;
	fi

	for style in $no_extension/css/*; do
		echo $style;
		sed -i "s/$1/$2/g" $style;
	done

	if [[ "$no_extension" != "/usr/share/spotify/Apps/.backups" ]]; then
		rm $file;
		cd $no_extension;
		zip -r $file *;
		cd -;
		rm -rf $no_extension;
	fi
done