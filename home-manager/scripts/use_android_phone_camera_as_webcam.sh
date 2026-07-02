#!/bin/sh

scrcpy --video-source=camera --camera-size=1920x1080 --camera-facing=back --v4l2-sink=/dev/video1 --no-playback --no-window
