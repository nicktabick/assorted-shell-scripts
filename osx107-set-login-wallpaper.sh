#!/bin/bash

# This script allows you to set the login wallpaper on OS X 10.7.

## Configuration (for automatic resizing)
SCRWIDTH=1280
SCRHEIGHT=800

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

# Check for parameter
if [ $# -lt 1 ]; then
  print_usage
fi
if [ "$1" == "--help" ]; then
  print_usage
fi

# Check for version of OS X
OSXVER=$(sw_vers -productVersion)
if [ $OSXVER != "10.7" ]; then
  clean_err "This script won't work on this version of OS X."
fi

# Check for root
if [ $EUID -ne 0 ]; then
  clean_err "This script won't work unless you run it as root!"
fi

OWD=$(pwd)
cd /System/Library/Frameworks/AppKit.framework/Versions/C/Resources


# Have we already backed up the original images?
if [ -e "NSTexturedFullScreenBackgroundColor.png.bak" ]; then
  echo "There appears to be an existing backup. Skipping..."
else
  echo "Creating a backup of the original wallpaper..."
  cp NSTexturedFullScreenBackgroundColor.png NSTexturedFullScreenBackgroundColor.png.bak
  if [ $? -ne 0 ]; then
    clean_err "There was an error creating the backup copy of NSTexturedFullScreenBackgroundColor.png."
  fi
fi

# Time to do some replacement
echo "Replacing wallpaper..."

# Build up the location for the wallpaper
if [ "$1" == "--restore" ]; then
  WPLOC="NSTexturedFullScreenBackgroundColor.png.bak"
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

if [ "$1" == "--restore" ]; then
  cp "$WPLOC" NSTexturedFullScreenBackgroundColor.png
  if [ $? -ne 0 ]; then
    clean_err "There was an error restoring NSTexturedFullScreenBackgroundColor.png from backup."
    exit 2
  fi
else
  # Kill two birds with one stone and resize it as we copy the replacement over
  sips -s format png -z $SCRHEIGHT $SCRWIDTH "$WPLOC" --out NSTexturedFullScreenBackgroundColor.png &> /dev/null
  if [ $? -ne 0 ]; then
    clean_err "There was an error converting and replacing NSTexturedFullScreenBackgroundColor.png with your image."
    exit 2
  fi
fi
echo "Done!"