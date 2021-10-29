#!/bin/bash

TOP_LEVEL="$(git rev-parse --show-toplevel)"
OUT_FILE="build/main.js"
OUT_MIN_FILE="build/main.min.js"

mkdir -p build && rm -r build/*

echo ":: Outputting JS to ${OUT_FILE}"
echo ":: Outputting optimized JS to ${OUT_MIN_FILE}"
echo ":: Outputting index.html to build/index.html"

elm make src/Main.elm --optimize --output="${OUT_FILE}"
uglifyjs "${OUT_FILE}" --compress 'pure_funcs=[F2,F3,F4,F5,F6,F7,F8,F9,A2,A3,A4,A5,A6,A7,A8,A9],pure_getters,keep_fargs=false,unsafe_comps,unsafe' | uglifyjs --mangle --output "${OUT_MIN_FILE}"
cp src/index.html build/index.html

echo ":: Compiled size: $(wc -c $OUT_FILE) bytes ($OUT_FILE)"
echo ":: Minified size: $(wc -c $OUT_MIN_FILE) bytes ($OUT_MIN_FILE)"
echo ":: Gzipped size:  $(gzip -c $OUT_MIN_FILE | wc -c) bytes"
