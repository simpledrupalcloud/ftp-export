#!/usr/bin/env bash

WORKING_DIR="$(pwd)"

hash wget 2> /dev/null

if [ "${?}" -ne 0 ]; then
  echo "ftp-export: wget command not found."

  exit 1
fi

help() {
  cat << EOF
ftp-export: Usage: ftp-export <SOURCE> <HOSTNAME> <USERNAME> <PASSWORD> <DESTINATION> [REMOTE_DIRECTORY]
EOF

  exit 1
}

if [ "${1}" == "-h" ] || [ "${1}" == "--help" ]; then
  help
fi

unknown_command() {
  echo "ftp-export: Unknown command. See 'ftp-export --help'"

  exit 1
}

if [ "${#}" -lt 5 ] || [ "${#}" -gt 6 ]; then
  unknown_command
fi

SOURCE="${1}"

if [ ! -d "${SOURCE}" ]; then
  echo "svn-export: Source directory doesn't exist: ${SOURCE}"

  exit 1
fi

mkdir -p "${SOURCE}"

cd "${SOURCE}"

SOURCE="$(pwd)"

cd "${WORKING_DIR}"

DESTINATION="${5}"

if [ -d "${DESTINATION}" ]; then
  echo "svn-export: Destination directory already exists: ${DESTINATION}"

  exit 1
fi

mkdir -p "${DESTINATION}"

cd "${DESTINATION}"

DESTINATION="$(pwd)"

REMOTE_DIRECTORY=""

if [ "${#}" -gt 5 ]; then
  REMOTE_DIRECTORY="${6}"

  if [ "${REMOTE_DIRECTORY:$((${#REMOTE_DIRECTORY} - 1)):1}" != "/" ]; then
    REMOTE_DIRECTORY="${REMOTE_DIRECTORY}/";
  fi
fi

HOSTNAME="${2}"
USERNAME="${3}"
PASSWORD="${4}"

for FILE in $(find "${SOURCE}" -type f); do
  RELATIVE_PATH="${FILE/${SOURCE}}"

  if [ "${RELATIVE_PATH:0:1}" == "/" ]; then
    RELATIVE_PATH="$(echo ${RELATIVE_PATH} | cut -c 2-)"
  fi

  DIRECTORY="$(dirname ${RELATIVE_PATH})"

  if [ ! -d "${DIRECTORY}" ]; then
    mkdir -p "${DIRECTORY}"
  fi

  wget -q "ftp://${USERNAME}:${PASSWORD}@${HOSTNAME}/${REMOTE_DIRECTORY}${RELATIVE_PATH}" -O "${RELATIVE_PATH}"

  if [ "${?}" -ne 0 ]; then
    rm -rf "${RELATIVE_PATH}"

    if [ "${DIRECTORY}" != "." ] && [ ! "$(ls -A ${DIRECTORY})" ]; then
      rm -rf "${DIRECTORY}"
    fi
  else
    echo "ftp-export: Exporting file: ${RELATIVE_PATH}"
  fi
done

cd "${WORKING_DIR}"
