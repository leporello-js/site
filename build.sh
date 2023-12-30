#!/bin/bash

set -euo pipefail

for page in `find . -name '*.tpl.html'`; do 
  bash $page > ${page/.tpl.html/.html}
done
