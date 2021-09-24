#!/bin/sh
wget https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz
tar zxf steamcmd_linux.tar.gz
rm steamcmd_linux.tar.gz
./steamcmd.sh +login anonymous +force_install_dir . +app_update 232250 +quit
echo "hostname \"World's fastest vsh server\"" > tf/cfg/server.cfg
echo "rcon_password \"$1\"" >> tf/cfg/server.cfg
echo "sv_contact \"luna@lunaluna.me\"" >> tf/cfg/server.cfg
echo "mp_timelimit \"30\"" >> tf/cfg/server.cfg
