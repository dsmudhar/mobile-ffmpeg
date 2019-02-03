#!/bin/bash
#
# Generates javadoc for Android library
#

CURRENT_DIR="`pwd`"

gradle -b ${CURRENT_DIR}/../android/ffmpeg/build.gradle clean build javadoc
