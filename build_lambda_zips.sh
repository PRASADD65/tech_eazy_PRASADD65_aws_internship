#!/bin/bash
set -e

echo "Starting Lambda zip file creation process..."

# Define source directory as current directory (where the script is located)
# And zips will be created in this same directory.

# --- Process start_instance.py ---
START_PY="start_instance.py"
START_ZIP="start_instance.zip"

if [ -f "${START_PY}" ]; then
    if [ ! -f "${START_ZIP}" ] || [ "${START_PY}" -nt "${START_ZIP}" ]; then
        echo "Creating/Updating ${START_ZIP}..."
        # Zip from the current directory (project root)
        zip -q -r "${START_ZIP}" "${START_PY}"
        echo "${START_ZIP} created/updated."
    else
        echo "${START_ZIP} already exists and is up-to-date. Skipping."
    fi
else
    echo "Warning: ${START_PY} not found. Skipping zip creation for start_instance."
fi

# --- Process stop_instance.py ---
STOP_PY="stop_instance.py"
STOP_ZIP="stop_instance.zip"

if [ -f "${STOP_PY}" ]; then
    if [ ! -f "${STOP_ZIP}" ] || [ "${STOP_PY}" -nt "${STOP_ZIP}" ]; then
        echo "Creating/Updating ${STOP_ZIP}..."
        # Zip from the current directory (project root)
        zip -q -r "${STOP_ZIP}" "${STOP_PY}"
        echo "${STOP_ZIP} created/updated."
    else
        echo "${STOP_ZIP} already exists and is up-to-date. Skipping."
    fi
else
    echo "Warning: ${STOP_PY} not found. Skipping zip creation for stop_instance."
fi

echo "Lambda zip file creation process complete."
