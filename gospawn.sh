#!/bin/bash
gnome-terminal --geometry=130x7+0+0 -e "/home/ben/lnd-helper-scripts/observer/buildwebdb4.sh" --working-directory="/home/ben/lnd-helper-scripts/observer"
gnome-terminal --geometry=150x30+500+178 -e "/home/ben/lnd-helper-scripts/observer/swatch.sh" --working-directory="/home/ben/lnd-helper-scripts/observer"
