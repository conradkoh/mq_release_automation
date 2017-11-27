#!/bin/bash
#version 1.4
#shell config
set -e

#folder definitions
echo "Enter the folder name to create a patch from:"
read folder_name
patches_folder='patches'
folder_patch_suffix=_patch
diff_filename=portal.diff

#confirmation checks
echo "Create a release for $folder_name"
echo "Warning: running this script will cause you to lose all unsaved changes and untracked files."
echo "Do you want to continue? (Y/N)"

#folder organization
if ! [[ -d $patches_folder ]];
then
mkdir "$patches_folder"
fi 

read confirmation
if [[ "$confirmation" == "Y" || "$confirmation" == "y" ]]
then
	#========================================
	#initialize variables
	#========================================
	base_dir=${PWD}

	#========================================
	#remove .diff file if it already exists
	#========================================
	diff_file=$base_dir/$diff_filename

	if [ -f  "$diff_file" ]; then
		echo "Deleting diff file"
		rm -r "$diff_file"
		echo "Diff file deleted"
	fi

	#========================================
	#Update git data and compute diffs
	#========================================
	echo "Enter previous release version:"
	read base_release_version
	echo "Enter deployment release version:"
	read new_release_version
	echo Building diffs from version: release/$base_release_version to release/$new_release_version


	#configure git working directory and compute diffs
	cd $folder_name
	git fetch
	git reset --hard HEAD >/dev/null
	git clean -f >/dev/null
	git checkout -f release/$base_release_version >/dev/null
	git pull >/dev/null
	git submodule init >/dev/null
	git submodule sync >/dev/null
	git submodule update >/dev/null
	git checkout -f release/$new_release_version >/dev/null
	git pull >/dev/null
	git submodule init >/dev/null
	git submodule sync >/dev/null
	git submodule update >/dev/null
	git diff --name-only release/$base_release_version > "$diff_file"

	#========================================
	#Clean up old release
	#========================================
	#copy files based on generated diff
	source=$base_dir/$folder_name
	destination="$base_dir"/"$patches_folder"/"$folder_name""$folder_patch_suffix"_t"$new_release_version"_f"$base_release_version"

	#recreate portal folder if it already exists
	if [ -d "$destination" ]; then
		echo "Removing patch destination folder"
		rm -r "$destination"
		echo "Patch destination folder removed"
	fi
	mkdir -p $destination #create patch directory

	#========================================
	#Build the release patch
	#========================================
	#Copy each of the files and make the directories
	set +e #allow errors for diffs, especially since files might have been removed
	while IFS= read -r var
	do
	   target_file="$destination"/"$var"
	   src_file="$source"/"$var"
	   target_dir=$(dirname "${target_file}")
	   mkdir -p $target_dir
   	   if [ ! -f $src_file ] && [ ! -d $src_file ];
   	   then
		   echo "Cannot copy deleted file: $src_file"
		else
	   cp -r $src_file $target_dir
	   fi
	done < "$diff_file"

	#cleanup
	echo "Cleaning up files"
	rm $diff_file
	find $destination -name '.DS_Store' -type f -delete
	echo "Patch creation completed successfully."
else
	echo "Exiting"
fi
