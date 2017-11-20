#!/bin/bash
set -e

#configurations
echo "Please enter your project prefix";
read prefix;
echo "Enter previous release version";
read base_release_version;
echo "Enter deployment release version";
read new_release_version;

./patch_core.sh "$prefix"_portal "$base_release_version" "$new_release_version"
echo "$prefix""_portal created successfully";
./patch_core.sh "$prefix"_db "$base_release_version" "$new_release_version"
echo "$prefix""_db created successfully";
./patch_core.sh "$prefix"_reporting "$base_release_version" "$new_release_version"
echo "$prefix""_reporting created successfully";

echo "Patches created.";
