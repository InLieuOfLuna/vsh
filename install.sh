#!/bin/sh
wget https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz
tar zxf steamcmd_linux.tar.gz
rm steamcmd_linux.tar.gz
wget https://sm.alliedmods.net/smdrop/1.10/sourcemod-1.10.0-git6512-linux.tar.gz
tar xf sourcemod-1.10.0-git6512-linux.tar.gz -C tf2/tf/
rm sourcemod-1.10.0-git6512-linux.tar.gz
./steamcmd.sh +login anonymous +force_install_dir ./tf2 +app_update 232250 +quit
echo "hostname \"World's fastest vsh server\"" > tf2/tf/cfg/server.cfg
echo "rcon_password \"$1\"" >> tf/cfg/server.cfg
echo "sv_contact \"luna@lunaluna.me\"" >> tf2/tf/cfg/server.cfg
echo "mp_timelimit \"30\"" >> tf2/tf/cfg/server.cfg
