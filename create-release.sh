#!/bin/sh

set -e

newVersion=1.0

filesToWatch="procedures test INSTALL.txt"

if [ ! -z "$(git status -s --untracked-files=no $filesToWatch)" ]; then
	echo "Aborting, please commit the changes first"
	exit 0
fi

basename=CodeBrowser-v$newVersion
zipFile=$basename.zip
folder=releases/$basename

rm -rf $folder
rm -rf $zipfile

mkdir -p $folder

cp -r $filesToWatch $folder

git rev-parse $revision > internalVersion

cd releases && zip -m -z -q -r $basename.zip $basename/* < ../internalVersion && cd ..

rmdir $folder
rm internalVersion

