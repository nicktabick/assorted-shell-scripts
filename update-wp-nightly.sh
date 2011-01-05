#!/bin/bash

## WordPress Update Script
## Nick Tabick, twoslashes.com
## nicktabick@gmail.com
##
## This script will fetch the latest WordPress release from
## the official site, modify it (if necessary) to prevent
## customizations in the themes from being overwritten, 
## then apply the update to the live site.
##
## All the user needs to do after this script's execution
## is update the database (if necessary) by logging in.
## Couldn't be easier, if I do say so myself.
##
## This script is provided without warranty; if you break
## your WordPress installation by using it, it's your own
## bloody fault.
##
## I realize that this isn't the most efficient script;
## perhaps I'll go back and optimize it one day.  Until
## then, you're stuck with what's here.

## Functions
clean_err() {
  echo 1>&2 $1
  rm -f ~/.wp-temp$$
  exit
}

print_usage() {
  echo 1>&2 Usage: $0 WP-PATH [--silent]
  echo 1>&2 WP-PATH is the path to the root of your WordPress installation.
  echo 1>&2
  echo 1>&2 "--silent   Suppresses the interactive prompts.  Themes updated."
  echo 1>&2 "           No status lines will be printed.  (This is great for cronjobs.)"
  exit 127
}

## Functions End - Start Execution Here

## Check for a help flag, not that there's really any reason, but *SHRUG*
if [ $# -lt 1 ]; then
  print_usage
fi
if [ $1 == "--help" ]; then
  print_usage
fi

if [ $# -eq 1 ]; then
  SILENT="NONSILENT"
else
  if [ $2 == "--silent" ]; then
    SILENT="SILENT"
  else
    SILENT="NONSILENT"
  fi
fi

## Check that the specified directory exists before we cause any errors later on
if [ ! -d $1 ]; then
  clean_err "Please specify a valid target directory for the WordPress installation."
fi

if [ $SILENT != "SILENT" ]; then
  echo Warning:  You are about to install a WordPress development version!
  echo Please confirm this action to ensure your sanity is in check.
  echo
  read -n1 -p "UPDATE WORDPRESS? [y/N]"
  echo

  case $REPLY in
    y | Y)
    echo As you wish...
    ;;
    *)
    exit
    ;;
  esac
  echo

  echo Creating temporary directory...
fi
mkdir -p ~/.wp-temp$$
if [ $? -ne 0 ]; then
  clean_err "There was an error creating the temporary work directory..."
fi

if [ $SILENT != "SILENT" ]; then
  echo Downloading WordPress latest release...
fi
cd ~/.wp-temp$$
wget -q http://wordpress.org/nightly-builds/wordpress-latest.zip
if [ $? -ne 0 ]; then
  clean_err "There was an error downloading the latest WordPress nightly."
fi

if [ $SILENT != "SILENT" ]; then
  echo Decompressing WordPress package...
fi
unzip -q wordpress-latest.zip
if [ $? -ne 0 ]; then
  clean_err "There was an error decompressing the downloaded WordPress nightly."
fi

if [ $SILENT != "SILENT" ]; then
  echo
  echo Prevent the default themes from updating?
  echo This is recommended if you have made customizations to
  echo the included themes.
  echo 
  echo If you use another theme, you can update them.
  echo
  read -n1 -p "Prevent theme update? [y/N]"
  echo 

  case $REPLY in
    y | Y)
    echo Removing themes from image to prevent update...
    rm -r ~/.wp-temp$$/wordpress/wp-content/themes
    echo Theme update prevented.
    ;;
    *)
    echo Theme update allowed.
    ;;
  esac
  echo

  echo Installing WordPress update...
fi
cp -r ~/.wp-temp$$/wordpress/* $1
if [ $? -ne 0 ]; then
  clean_err "There was an error copying to the specified directory.  Does it exist?"
fi

if [ $SILENT != "SILENT" ]; then
  echo Removing temporary directory...
fi
rm -r ~/.wp-temp$$
if [ $? -ne 0 ]; then
  clean_err "There was an error cleaning up.  There might be a .wp-temp directory inside your home directory."
fi

if [ $SILENT != "SILENT" ]; then
  echo
  echo Congratulations, your update is complete.
fi
