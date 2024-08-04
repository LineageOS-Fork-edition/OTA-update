#!/bin/bash

# Prompt user for device codename
read -p "Enter device codename (e.g. PL2, miatoll): " codename

# Prompt user for release tag
read -p "Enter release tag (e.g. mm-yyyy): " release_tag

# Construct URL using the release tag and filename
# The filename is extracted from the OTA package file
file_path=$(ls out/target/product/${codename}/lineage-21.0-*-${codename}.zip 2>/dev/null)
filename=$(basename "$file_path")
url="https://github.com/LineageOS-Pixel-Variant/OTA-update/releases/download/r_${release_tag}/${filename}"

# Default values
output_dir="./OTA/devices"
romtype=$(grep -oP '^ro.lineage.releasetype=\K\S+' "out/target/product/${codename}/system/build.prop")
version=$(grep -oP '^ro.lineage.build.version=\K\S+' "out/target/product/${codename}/system/build.prop")
datetime=$(grep -oP '^ro.build.date.utc=\K\d+' "out/target/product/${codename}/system/build.prop")

# Check if the OTA package file exists
if [[ -z "$file_path" ]]; then
  echo "OTA package file not found in the specified directory."
  exit 1
fi

# Generate ID using sha256sum
id=$(sha256sum "$file_path" | awk '{ print $1 }')

# Get the file size
size=$(stat -c%s "$file_path")

# Create JSON
json=$(cat <<EOF
{
  "response": [
    {
      "datetime": $datetime,
      "filename": "$filename",
      "id": "$id",
      "romtype": "$romtype",
      "size": $size,
      "url": "$url",
      "version": "$version"
    }
  ]
}
EOF
)

# Create the output directory if it doesn't exist
mkdir -p "$output_dir"

# Define the output file path
output_file="${output_dir}/${codename}.json"

# Write JSON to the specified file
echo "$json" > "$output_file"

# Confirmation message
echo "JSON has been saved to $output_file"
