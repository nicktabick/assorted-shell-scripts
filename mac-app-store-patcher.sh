#!/bin/bash

## Mac App Store Patcher
## Proof-of-Concept
##
## Nick Tabick, nicktabick@gmail.com
##
## Per some documentation floating around that
## the DRM in the Mac App Store is as easy to crack
## as using cp, this script attempts to automate the
## process in a simple test.
##
## SUPPORT DEVELOPERS!
##
## This script comes with no warranty and no guarantees
## of the legality of performing these actions in your
## country of origin.

## Functions
clean_err() {
  echo 1>&2 $1
  exit
}

print_usage() {
  echo 1>&2 "Usage: $0 [--prep] <target.app>"
  echo 1>&2
  echo 1>&2 "--prep  Backs up valid App Store credentials to the user's home directory"
  echo 1>&2 "        so that they may be used to patch other applications."
  echo 1>&2
  echo 1>&2 "If the --prep flag is not specified, this script assumes that it has"
  echo 1>&2 "already been run against a legitimately-downloaded application and uses"
  echo 1>&2 "the cache created by --prep to patch the target application."
  echo 1>&2
  echo 1>&2 "In all cases, the application is assumed to be in the /Applications"
  echo 1>&2 "directory.  The .app extension must be specified."
  exit 127
}

## End Functions

## Check for help flag
if [ $# -lt 1 ]; then
  print_usage
fi
if [ "$1" == "--help" ]; then
  print_usage
fi

## Check whether we're running in prepmode or patchmode
if [ "$1" == "--prep" ]; then
  ## Prepmode - borrowing credentials from an application downloaded legitimately
  ## from the App Store.  We store them in the user's home directory on the off
  ## chance that the user decides to remove the free application we're sourcing
  ## these from at a later date.
  
  ## Clean any existing cache
  rm -rf ~/.appstorecache
  if [ $? -ne 0 ]; then
    clean_err "The credentials cache ~/.appstorecache could not be cleared."
  fi
  
  ## Build the new cache directory
  mkdir ~/.appstorecache
  if [ $? -ne 0 ]; then
    clean_err "The credentials cache ~/.appstorecache could not be created."
  fi
  
  ## Copy over the files
  cp -r /Applications/$2/Contents/_CodeSignature /Applications/$2/Contents/_MASReceipt /Applications/$2/Contents/CodeResources ~/.appstorecache
  if [ $? -ne 0 ]; then
    clean_err "One or more of the files from $2 could not be copied to ~/.appstorecache."
  fi
  
  ## Done with prep!
  echo Credentials cache created successfully in ~/.appstorecache.
  echo "(You may delete $2 in the future.)"
  exit 0
fi

## If execution gets to here, we're in patchmode

## Clear out the existing credentials
rm -rf /Applications/$1/Contents/_CodeSignature /Applications/$1/Contents/_MASReceipt 
if [ $? -ne 0 ]; then
  clean_err "The existing credentials could not be removed from the application package."
fi

## Copy in the new credentials from our cache
cp -r ~/.appstorecache/_CodeSignature ~/.appstorecache/_MASReceipt "/Applications/$1/Contents"
if [ $? -ne 0 ]; then
  clean_err "The new credentials could not be copied into the application package. (Does it exist?)"
fi

##We're done!
echo Patching complete.