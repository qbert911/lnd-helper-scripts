#!/bin/bash
gnome-terminal --geometry=130x5+0+0 -e "/home/ben/lnd-helper-scripts/lndwatcher/buildwebdb.sh" --working-directory="/home/ben/lnd-helper-scripts/lndwatcher"
gnome-terminal --geometry=170x47+500+148 -e "/home/ben/lnd-helper-scripts/lndwatcher/watchlnd.sh" --working-directory="/home/ben/lnd-helper-scripts/lndwatcher"
