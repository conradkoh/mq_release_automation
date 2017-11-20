#!/bin/bash
#version 1.0
#shell config
set -e
index_folder_name=1;
index_base_release_version=2;
index_new_release_version=3;

folder_name="${!index_folder_name}";
base_release_version="${!index_base_release_version}"
new_release_version="${!index_new_release_version}"
echo "[$folder_name] - PATCH f_$base_release_version t_$new_release_version";
#if all required vars have been provided, execute
if ! [[ -z "$folder_name" ]] && ! [[ -z "$base_release_version" ]] && ! [[ -z "$new_release_version" ]];
	then
		#folder definitions
		patches_folder='patches'
		folder_patch_suffix=_patch
		diff_filename=portal.diff


		#folder organization
		if ! [[ -d $patches_folder ]];
		then
		mkdir "$patches_folder"
		fi 

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
	echo "Incorrect command format specified";
fi

