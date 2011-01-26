#!/bin/bash

# This script allows you to set the login wallpaper on OS X 10.5/10.6.

## Functions
clean_err() {
  echo 1>&2 $1
  exit
}

print_usage() {
  echo 1>&2 "Usage: $0 <wallpaper.jpg|--restore>"
  echo 1>&2
  echo 1>&2 "wallpaper.jpg is the full path (or filename, if in the current directory)"
  echo 1>&2 "to the wallpaper that you would like displayed at the login screen."
  echo 1>&2
  echo 1>&2 "You may use --restore in place of a filename to replace the default"
  echo 1>&2 "wallpaper."
  echo 1>&2
  echo 1>&2 "This script requires root access to replace a system library file."
  echo 1>&2
  exit 127
}

## Check for parameter
if [ $# -lt 1 ]; then
  print_usage
fi
if [ "$1" == "--help" ]; then
  print_usage
fi

# Check for root
if [ $EUID -ne 0 ]; then
  clean_err "This script won't work unless you run it as root!"
fi

OWD=$(pwd)
cd /System/Library/CoreServices

# Have we already backed up the original images?
if [ -e "DefaultDesktop.jpg.bak" ]; then
  echo "There appears to be an existing backup. Skipping..."
else
  echo "Creating a backup of the original wallpaper..."
  cp DefaultDesktop.jpg DefaultDesktop.jpg.bak
  if [ $? -ne 0 ]; then
    clean_err "There was an error creating the backup copy of DefaultDesktop.jpg."
  fi
fi

# Time to do some replacement
echo "Replacing wallpaper..."

# Build up the location for the wallpaper
if [ "$1" == "--restore" ]; then
  WPLOC="DefaultDesktop.jpg.bak"
else
  if [ -e "$1" ]; then
    WPLOC="$1"
  else
    if [ -e "$OWD/$1" ]; then
      WPLOC="$OWD/$1"
    else
      clean_err "This script can't seem to find the file specified. Aborting..."
    fi
  fi
fi

cp "$WPLOC" DefaultDesktop.jpg
if [ $? -ne 0 ]; then
  clean_err "There was an error replacing DefaultDesktop.jpg."
  exit 2
fi

echo "Done!"