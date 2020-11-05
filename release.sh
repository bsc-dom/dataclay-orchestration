#!/bin/sh
set -e
#-----------------------------------------------------------------------
# Helper functions (miscellaneous)
#-----------------------------------------------------------------------
CONSOLE_CYAN="\033[1m\033[36m"; CONSOLE_NORMAL="\033[0m"; CONSOLE_RED="\033[1m\033[91m"
printMsg() {
  printf "${CONSOLE_CYAN}${1}${CONSOLE_NORMAL}\n"
}
printError() {
  printf "${CONSOLE_RED}${1}${CONSOLE_NORMAL}\n"
}
#-----------------------------------------------------------------------
# MAIN
#-----------------------------------------------------------------------
DEV=false
PROMPT=true
BRANCH_TO_CHECK="master"
while test $# -gt 0
do
    case "$1" in
        --dev)
          DEV=true
          BRANCH_TO_CHECK="develop"
            ;;
        -y)
        	PROMPT=false
        	;;
        *) echo "Bad option $1"
        	exit 1
            ;;
    esac
    shift
done

VERSION=$(cat VERSION.txt)
VERSION="${VERSION//.dev/}"
printMsg "Welcome to dataClay-orchestration release script"
GIT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
if [[ "$GIT_BRANCH" != "$BRANCH_TO_CHECK" ]]; then
  printError "Branch is not $BRANCH_TO_CHECK. Aborting script";
  exit 1;
fi

if [ "$PROMPT" = true ]; then

  read -p "Version defined is $VERSION. Is this ok? (y/n) " -n 1 -r
  echo    # (optional) move to a new line
  if [[ ! $REPLY =~ ^[Yy]$ ]]
  then
      printMsg "Please modify VERSION.txt file"
      exit 1
  fi

  printf "${CONSOLE_RED} IMPORTANT: you're about to build and officially dataClay-orchestration $VERSION ${CONSOLE_NORMAL}\n"
  read -rsn1 -p" Press any key to continue (CTRL-C for quitting this script)";echo

fi

if [ "$DEV" = false ] ; then
  GIT_TAG=$VERSION

  printMsg "  ==  Preparing master branch"
  echo "${VERSION}" > VERSION.txt
  git commit -m "Released ${VERSION}"
  git push origin HEAD:master

  printMsg "  ==  Tagging new release in Git"
  git tag -a ${GIT_TAG} -m "Release ${GIT_TAG}"
  git push origin ${GIT_TAG}

  printMsg "  ==  Preparing develop branch"
  NEW_VERSION=$(echo "$VERSION + 0.1" | bc)
  echo "${NEW_VERSION}.dev" > VERSION.txt

  ## update develop branch also ##
  git fetch --all
  git checkout develop
  git add VERSION.txt
  git commit -m "Updating version.txt"
  git push origin HEAD:develop

  # back to master
  git checkout master
fi

printMsg "  ==  Everything seems to be ok! Bye"