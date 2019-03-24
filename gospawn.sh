#!/bin/bash
gnome-terminal --geometry=130x5+0+0 -e "/home/ben/lnd-helper-scripts/observer/buildwebdb4.sh" --working-directory="/home/ben/lnd-helper-scripts/observer"
gnome-terminal --geometry=170x47+500+148 -e "/home/ben/lnd-helper-scripts/observer/swatch.sh" --working-directory="/home/ben/lnd-helper-scripts/observer"
