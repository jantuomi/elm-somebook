#!/bin/bash

TOP_LEVEL="$(git rev-parse --show-toplevel)"
PORT="${1:-8001}"

echo ":: Watching directory src/ and serving continuous builds on http://localhost:${PORT}."
echo ":: Touch a file in src/ to compile & serve!"

# bash scripts/_build-and-serve.sh ${PORT}
fswatch -or src | xargs -n1 -I{} bash scripts/_build-and-serve.sh ${PORT}
