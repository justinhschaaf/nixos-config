#!/usr/bin/env bash
# commandeered from the Hyprland Wiki https://wiki.hyprland.org/Useful-Utilities/Status-Bars/

function clamp {
	min=$1
	max=$2
	val=$3
	rust-script -d num -e "num::clamp($val, $min, $max)"
}

direction=$1
current=$2
if test "$direction" = "down"
then
	target=$(clamp 1 10 $(($current+1)))
	echo "jumping to $target"
	hyprctl dispatch workspace $target
elif test "$direction" = "up"
then
	target=$(clamp 1 10 $(($current-1)))
	echo "jumping to $target"
	hyprctl dispatch workspace $target
fi
