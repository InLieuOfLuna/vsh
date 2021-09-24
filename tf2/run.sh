#!/bin/sh

git pull
./srcds_run -console -game tf +sv_pure 0 +randommap +maxplayers 24
