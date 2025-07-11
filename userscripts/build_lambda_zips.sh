#!/bin/bash
set -e

echo "Starting lambda zip file creation process..."

# Define source directory as the Terraform directory where the .py scripts are located
# And zips will be created in this same directory (or moved there later if preferred)
TERRAFORM_DIR="Terraform" # New variable for the Terraform directory

# --- Process start_instance.py ---
START_PY="${TERRAFORM_DIR}/start_instance.py"
START_ZIP="${TERRAFORM_DIR}/start_instance.zip"

if [ -f "${START_PY}" ]; then
  if [ -f "${START_ZIP}" ] && [[ "${START_PY}" -nt "${START_ZIP}" ]]; then
    echo "Creating/updating ${START_ZIP}..."
    # Zip from the directory where the .py script resides
    (cd "${TERRAFORM_DIR}" && zip -q -r "${START_ZIP##*/}" "start_instance.py")
    echo "${START_ZIP} created/updated."
  else
    echo "${START_ZIP} already exists and is up-to-date. Skipping."
  fi
else
  echo "Warning: ${START_PY} not found. Skipping zip creation for start_instance."
fi

# --- Process stop_instance.py ---
STOP_PY="${TERRAFORM_DIR}/stop_instance.py"
STOP_ZIP="${TERRAFORM_DIR}/stop_instance.zip"

if [ -f "${STOP_PY}" ]; then
  if [ -f "${STOP_ZIP}" ] && [[ "${STOP_PY}" -nt "${STOP_ZIP}" ]]; then
    echo "Creating/updating ${STOP_ZIP}..."
    # Zip from the directory where the .py script resides
    (cd "${TERRAFORM_DIR}" && zip -q -r "${STOP_ZIP##*/}" "stop_instance.py")
    echo "${STOP_ZIP} created/updated."
  else
    echo "${STOP_ZIP} already exists and is up-to-date. Skipping."
  fi
else
  echo "Warning: ${STOP_PY} not found. Skipping zip creation for stop_instance."
fi

echo "Lambda zip file creation process complete."
