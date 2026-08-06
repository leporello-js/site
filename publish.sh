#!/bin/bash

# Publish a blog article: register it in blog/index.md and static/rss.xml.
# The article itself must already exist, either as blog/<slug>.md or as
# blog/<slug>/index.md

set -euo pipefail

SITE=https://leporello.tech

usage() {
  cat >&2 <<EOF
Usage: $0 <article.md> [-d DESCRIPTION] [-D YYYY-MM-DD] [-n]

  <article.md>     path to the article, e.g. blog/my_post.md
                   or blog/my_post/index.md
  -d DESCRIPTION   RSS description (default: first paragraph of the article)
  -D YYYY-MM-DD    publication date (default: today)
  -n               dry run, print what would be added
EOF
  exit 1
}

[ $# -ge 1 ] || usage

ARTICLE=$1
shift

DESCRIPTION=
DESCRIPTION_SET=
DATE=`date +%Y-%m-%d`
DRY_RUN=

while [ $# -gt 0 ]; do
  case $1 in
    -d) DESCRIPTION=${2-}; DESCRIPTION_SET=1; shift 2 ;;
    -D) DATE=${2-}; shift 2 ;;
    -n) DRY_RUN=1; shift ;;
    *) usage ;;
  esac
done

cd "`dirname "$0"`"

[ -f "$ARTICLE" ] || { echo "No such article: $ARTICLE" >&2; exit 1; }

# Strip an optional leading ./ so that both `blog/x.md` and `./blog/x.md` work
ARTICLE=${ARTICLE#./}

case $ARTICLE in
  blog/*/index.md)
    SLUG=${ARTICLE#blog/}
    SLUG=${SLUG%/index.md}
    LINK=./$SLUG/
    ;;
  blog/index.md)
    echo "blog/index.md is the blog index, not an article" >&2
    exit 1
    ;;
  blog/*.md)
    SLUG=${ARTICLE#blog/}
    SLUG=${SLUG%.md}
    LINK=./$SLUG.html
    ;;
  *)
    echo "Article must live under blog/: $ARTICLE" >&2
    exit 1
    ;;
esac

URL=$SITE/blog/${LINK#./}

TITLE=`perl -ne 'if (s/^#\s+//) { s/\s+$//; print; exit }' "$ARTICLE"`
[ -n "$TITLE" ] || { echo "Article has no '# Title' heading: $ARTICLE" >&2; exit 1; }

if [ -z "$DESCRIPTION_SET" ]; then
  # First paragraph after the title
  DESCRIPTION=`awk '
    /^#/ { seen = 1; next }
    !seen { next }
    /^[[:space:]]*$/ { if (para) exit; next }
    { para = para (para ? " " : "") $0 }
    END { print para }
  ' "$ARTICLE"`
fi

# Each file is updated independently, so a rerun can complete a half finished
# publication instead of refusing to do anything

IN_INDEX=
IN_RSS=

if grep -qF "]($LINK)" blog/index.md; then IN_INDEX=1; fi
if grep -qF "<guid isPermaLink=\"false\">$SLUG</guid>" static/rss.xml; then IN_RSS=1; fi

if [ -n "$IN_INDEX" ] && [ -n "$IN_RSS" ]; then
  echo "Already published: $SLUG" >&2
  exit 1
fi

# BSD date needs -j -f to parse, GNU date needs -d
if date -d "$DATE" +%s >/dev/null 2>&1; then
  format_date() { date -d "$DATE" "+$1"; }
else
  format_date() { date -j -f %Y-%m-%d "$DATE" "+$1"; }
fi

INDEX_DATE=`format_date '%-d %b %Y'`
RSS_DATE="`format_date '%a, %-d %b %Y'` `date -u +%H:%M:%S` GMT"

xml_escape() { perl -pe 's/&/&amp;/g; s/</&lt;/g; s/>/&gt;/g'; }

XML_TITLE=`printf %s "$TITLE" | xml_escape`
XML_DESCRIPTION=`printf %s "$DESCRIPTION" | xml_escape`

INDEX_ENTRY="- *$INDEX_DATE*&emsp;[$TITLE]($LINK) "

RSS_ENTRY="   <item>
     <title>$XML_TITLE</title>
     <description>$XML_DESCRIPTION</description>
     <pubDate>$RSS_DATE</pubDate>
     <link>$URL</link>
     <guid isPermaLink=\"false\">$SLUG</guid>
   </item>"

if [ -n "$DRY_RUN" ]; then
  if [ -z "$IN_INDEX" ]; then
    echo "blog/index.md:"
    echo "$INDEX_ENTRY"
    echo
  fi
  if [ -z "$IN_RSS" ]; then
    echo "static/rss.xml:"
    echo "$RSS_ENTRY"
  fi
  exit 0
fi

# Both files are sorted newest first, so the new entry goes before the first
# existing one

if [ -n "$IN_INDEX" ]; then
  echo "Already in blog/index.md, skipped"
elif grep -q '^- ' blog/index.md; then
  ENTRY=$INDEX_ENTRY perl -i -pe '
    if (!$done && /^- /) { print $ENV{ENTRY}, "\n"; $done = 1 }
  ' blog/index.md
else
  printf '%s\n' "$INDEX_ENTRY" >> blog/index.md
fi

if [ -n "$IN_RSS" ]; then
  echo "Already in static/rss.xml, skipped"
else
  ENTRY=$RSS_ENTRY perl -i -pe '
    if (!$done && /<item>/) { print $ENV{ENTRY}, "\n"; $done = 1 }
  ' static/rss.xml
fi

echo "Published: $TITLE"
echo "  $URL"
echo "Run ./build.sh to regenerate the site"
