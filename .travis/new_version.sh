#!/bin/bash

if [ "$TRAVIS_BRANCH" == "master" ]; then 
     export VERSION=$(cat VERSION.txt);
     NEW_VERSION=$(echo "$VERSION + 0.1" | bc)

	 ## update develop branch also ##
	 git fetch
	 git checkout develop
     echo ${NEW_VERSION}.dev > VERSION.txt
     git add VERSION.txt
	 git commit -m "Modified VERSION.txt"
	 git push origin HEAD:develop
else
     echo "Skipping new version tag because current branch is not master";
fi
