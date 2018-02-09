#!/bin/bash

ls .
echo Hello World
echo pwd:
pwd

mkdir newdirect

cd newdirect
pwd

cd ..
pwd

rm -vr newdirect
ls .

git status
git branch experimental
git branch
git checkout experimental
git status
git checkout master
git branch -d experimental
git branch
