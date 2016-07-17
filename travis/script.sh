#!/bin/bash

if [ $TRAVIS_BRANCH = "master" ]; then
fastlane ios beta
else
open -b com.apple.iphonesimulator
fastlane ios test
fastlane ios report_test_coverage
fastlane ios build
fi
