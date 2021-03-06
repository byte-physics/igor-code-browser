#!/bin/sh

set -e

newVersion=1.3

filesToWatch="procedures README.md LICENSE"

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

git rev-parse HEAD > internalVersion

cd releases && zip -m -z -q -r $zipFile $basename/* < ../internalVersion && cd ..

rmdir $folder
rm internalVersion

# for igor exchange
pandoc README.md -t html > README.html
