#!/bin/bash
cd /opt/simutrans
while sleep 30; do
./sim -server 13353 -lang ja -nosound -nomidi -log 1 -debug 3 -load $SIMUTRANS_SAVEGAME -server_name $SIMUTRANS_SERVERNAME -singleuser -objects pak
done

