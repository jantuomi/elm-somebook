#!/bin/bash

TOP_LEVEL="$(git rev-parse --show-toplevel)"
PORT="${1:-8001}"

echo ":: Watching directory src/ and serving continuous builds on http://localhost:${PORT}"

bash scripts/_build-and-serve.sh ${PORT}
fswatch -or src | xargs -n1 -I{} bash scripts/_build-and-serve.sh ${PORT}
