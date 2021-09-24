#!/bin/sh
wget https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz
tar zxf steamcmd_linux.tar.gz
rm steamcmd_linux.tar.gz
wget https://sm.alliedmods.net/smdrop/1.10/sourcemod-1.10.0-git6512-linux.tar.gz
tar xf sourcemod-1.10.0-git6512-linux.tar.gz
cp -r addons tf2/tf
rm -r addons
wget https://mms.alliedmods.net/mmsdrop/1.11/mmsource-1.11.0-git1145-linux.tar.gz
tar xf mmsource-1.11.0-git1145-linux.tar.gz
cp -r addons tf2/tf
rm -r addons
rm sourcemod-1.10.0-git6512-linux.tar.gz
wget https://builds.limetech.io/files/tf2items-1.6.4-hg279-linux.zip
unzip tf2items-1.6.4-hg279-linux.zip
cp -r addons tf2/tf
rm -r addons

./steamcmd.sh +login anonymous +force_install_dir ./tf2 +app_update 232250 +quit
echo "rcon_password \"$1\"" >> tf2/tf/cfg/server.cfg
