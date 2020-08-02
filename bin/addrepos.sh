#!/bin/sh

PROJECTS=$HOME/Projects

for filename in $PROJECTS/*
do
    echo "Adding " $filename " to Tower"
    gittower $filename
done
