#!/bin/bash

if [ "$TRAVIS_BRANCH" == "master" ]; then 
     export VERSION=$(cat VERSION.txt);
     NEW_VERSION=${VERSION%".dev"}
     echo $NEW_VERSION > VERSION.txt
     git add VERSION.txt
	 git commit -m "Modified VERSION.txt"
	 git push origin HEAD:$TRAVIS_BRANCH
else
     echo "Skipping prepare version tag because current branch is not master";
fi
