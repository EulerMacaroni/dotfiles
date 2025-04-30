#!/bin/sh

# SSID=$(/System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport -I | awk -F:  '($1 ~ "^ *SSID$"){print $2}' | cut -c 2-)
#
# sketchybar --set wifi \
#   icon= icon.color=0xff58d1fc \
#   label="$SSID"

INFO="$(networksetup -listallhardwareports | \
        awk '/Wi-Fi/{getline; print $2}' | \
        xargs networksetup -getairportnetwork | \
        sed 's/Current Wi-Fi Network: //')"

if [ -z "$INFO" ] || [ "$INFO" = "You are not associated with an AirPort network." ]; then
  INFO="Not Connected"
fi

sketchybar --set wifi \
  icon= \
  icon.color=$GREY \
  label="$INFO"

# Get SSID using wdutil (preferred over deprecated airport)
# SSID=$(wdutil info | awk -F': ' '/SSID/{print $2}')
#
# # Handle disconnected state
# if [ -z "$SSID" ]; then
#   SSID="Not Connected"
# fi
#
# # Update SketchyBar item
# sketchybar --set wifi \
#   icon= \
#   icon.color=0xff58d1fc \
#   label="$SSID"

# # Get SSID
# SSID=$(/System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport -I \
#   | awk -F: '($1 ~ "^ *SSID$"){print $2}' \
#   | cut -c 2-)
#
# # Fallback if not connected
# if [ -z "$SSID" ]; then
#   SSID="Not Connected"
# fi
#
# # Update sketchybar
# sketchybar --set wifi \
#   icon= \
#   icon.color=0xff58d1fc \
#   label="$SSID"

