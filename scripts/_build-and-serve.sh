#!/bin/bash

PORT=${1}

mkdir -p build && rm -r build/*
cp -r vendor/* build/
cp src/index.html build/index.html
elm make src/Main.elm --debug --output build/main.js && python3 -m http.server ${PORT} -d build
