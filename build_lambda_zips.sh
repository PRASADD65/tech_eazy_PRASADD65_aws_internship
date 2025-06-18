#!/bin/bash
set -e

echo "Starting Lambda zip file creation process..."

# Assuming your .py files are in the current directory or a specific subdir like 'lambda_code'
# Let's assume they are in a 'lambda_code' directory for better organization,
# and the zips will be placed there too. If your .py files are directly in the root,
# adjust LAMBDA_CODE_DIR to just '.' or an empty string, and remove the cd.
LAMBDA_CODE_DIR="lambda_code"

# Ensure the lambda_code directory exists
mkdir -p "${LAMBDA_CODE_DIR}"

# --- Process start_instance.py ---
START_PY="${LAMBDA_CODE_DIR}/start_instance.py"
START_ZIP="${LAMBDA_CODE_DIR}/start_instance.zip"

if [ -f "${START_PY}" ]; then
    if [ ! -f "${START_ZIP}" ] || [ "${START_PY}" -nt "${START_ZIP}" ]; then
        echo "Creating/Updating ${START_ZIP}..."
        (cd "${LAMBDA_CODE_DIR}" && zip -q -r start_instance.zip start_instance.py)
        echo "${START_ZIP} created/updated."
    else
        echo "${START_ZIP} already exists and is up-to-date. Skipping."
    fi
else
    echo "Warning: ${START_PY} not found. Skipping zip creation for start_instance."
fi

# --- Process stop_instance.py ---
STOP_PY="${LAMBDA_CODE_DIR}/stop_instance.py"
STOP_ZIP="${LAMBDA_CODE_DIR}/stop_instance.zip"

if [ -f "${STOP_PY}" ]; then
    if [ ! -f "${STOP_ZIP}" ] || [ "${STOP_PY}" -nt "${STOP_ZIP}" ]; then
        echo "Creating/Updating ${STOP_ZIP}..."
        (cd "${LAMBDA_CODE_DIR}" && zip -q -r stop_instance.zip stop_instance.py)
        echo "${STOP_ZIP} created/updated."
    else
        echo "${STOP_ZIP} already exists and is up-to-date. Skipping."
    fi
else
    echo "Warning: ${STOP_PY} not found. Skipping zip creation for stop_instance."
fi

echo "Lambda zip file creation process complete."
