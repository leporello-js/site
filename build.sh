#!/bin/bash

set -euo pipefail

cp -r static/ public

for page in `find . -name '*.tpl.html'`; do 
  bash $page > public/${page/.tpl.html/.html}
done
