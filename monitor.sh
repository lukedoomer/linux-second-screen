#!/bin/bash

## PARAMS
## Device resolution using [width]x[height], without bracets. Sample 800x600
## -v - VIRTUAL display to be used. Sample v1, v2, v3
## -left  - If our device is on the left
## -right - If our device is on the right

### Uncomment what you are using, hardcoded
## Laptop
#fisical="LVDS1"
## VGA
#fisical="VGA1"
## HDMI
fisical="HDMI1"

#echo $@
## Regex to understand params
virtual=$(echo $@ | grep -Po '\-v\d' | grep -Po '\d')
device=$(echo $@ | grep -Po '\d+x\d+')
position=$(echo $@ | grep -Po '\-(left|right)' | grep -Po '\w+')



## Use VIRTUAL1 if none was passed
if [ -z "$virtual" ] ; then
	virtual="VIRTUAL1"
else
	virtual="VIRTUAL${virtual}"
fi

## Device width and height
d_width=1920
d_height=1080

## Check param position, this position is where the user want the new screen
if [ -z "$position" ] ; then
	position="left"
fi
#echo "position= $position"
if [ "$position" = "left" ] ; then
	xinerama="xinerama0"
else
	xinerama="xinerama1"
fi



## Find Host Resolution
h_width=1920
h_height=1080


v_width=$d_width
v_height=$d_height
#echo "width   = $v_width"


## Build the modeline, the display configurations
modeline=$(cvt $v_width $v_height 60.00 | grep "Modeline" | cut -d' ' -f 2-17)
## Find the mode
mode=$(echo "$modeline" | cut -d' ' -f 1)
## remove quotes, don't need to remove quotes
#mode=${mode//\"}
res=$(echo ${mode//\"} | cut -d'_' -f 1)


## Evaluates the start width position, to clip vnc
#s_width=$(echo $host | cut -d'x' -f 1)
#s_width=$((s_width + 1))
#echo "s_width = $s_width"

#echo $modeline
#echo $mode

echo "device  = $device"
#echo "width   = $d_width"
#echo "height  = $d_height"

echo "host    = $host"
#echo "width   = $h_width"
#echo "height  = $h_height"
echo "scale   = $proportion"

echo "Display = $virtual"

echo "virtual = $res"
echo ""

## Log and Run commands
function run () {
	echo "$1"
	$1
}

## Create Virtual Display
run "xrandr --newmode $modeline"
run "xrandr --addmode $virtual $mode"
run "xrandr --output $virtual --mode $mode --${position}-of ${fisical}"


## Start VNC
run "x11vnc -clip ${xinerama} -xrandr -nocursorshape -nocursorpos -forever"


## Turn VirtualDisplay off
run "xrandr --output $virtual --off"
run "xrandr --delmode $virtual $mode"
run "xrandr --rmmode $mode"
run "xrandr -s 0"
