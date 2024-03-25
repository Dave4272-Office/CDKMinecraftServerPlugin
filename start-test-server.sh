#!/bin/bash

# Use a glob to match filenames directly
oldJarFileNames=()
while IFS= read -r -d '' file; do
    oldJarFileNames+=("$(basename "${file}")")
done < <(find "${TEST_SERVER_HOME}/plugins" -maxdepth 1 -type f -name "CDKMinecraftServerPlugin-*.jar" -print0)

echo "Deleting the following old plugin files from ${TEST_SERVER_HOME}/plugins"
i=1
for file in "${oldJarFileNames[@]}"; do
    echo "[${i}]: ${file}"
    rm -f "${TEST_SERVER_HOME}/plugins/${file}"
    ((i++))  # Increment i
done

# Find the latest created file matching the pattern
jarFileName=$(find ./build/libs -maxdepth 1 -type f -name "CDKMinecraftServerPlugin-*-all.jar" -printf '%T@ %p\n' | sort -n | tail -1 | cut -d' ' -f2)

# Ensure jarFileName is not empty
if [[ -n "${jarFileName}" ]]; then
    echo "Copying file: ${jarFileName} to ${TEST_SERVER_HOME}/plugins"
    cp "${jarFileName}" "${TEST_SERVER_HOME}/plugins"
else
    echo "No matching file found."
    exit 1
fi

cd "${TEST_SERVER_HOME}" || exit 1
./start.sh