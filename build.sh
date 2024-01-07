#!/bin/bash

set -euo pipefail

cp -r static/ public

for page in `find . -name '*.tpl.html'`; do 
  bash $page > public/${page/.tpl.html/.html}
done

# Build blog

mkdir -p public/blog

cp -r blog/. public/blog

for file in `find blog -name '*.md'`; do
  (
    # Parse page title from first header of blog entry (starts with symbol '#'
    # in markdown
    export TITLE=`cat $file | perl -ne 's/#// && print' | head -1`
    cat templates/header.html | envsubst
    cat templates/blog_wrapper.html
    npx marked <$file
    if [ $file != "blog/index.md" ] ; then
      cat templates/blog_content_link.html
    fi
  ) > public/${file/.md/.html}
done
