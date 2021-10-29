#!/bin/bash

PORT=${1}

mkdir -p build && rm -r build/*
elm make src/Main.elm --debug --output build/index.html && python3 -m http.server ${PORT} -d build
