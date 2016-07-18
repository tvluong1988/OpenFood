#!/bin/bash

if [ $TRAVIS_BRANCH = "master" ] && [ $TRAVIS_PULL_REQUEST == "false" ]; then
fastlane ios build
fastlane ios beta
else
open -b com.apple.iphonesimulator
fastlane ios test
fastlane ios report_test_coverage
fastlane ios build
fi
