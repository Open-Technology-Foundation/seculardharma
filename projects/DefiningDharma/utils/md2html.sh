#!/bin/bash
set -euo pipefail

output="$1"
output=$(basename -s .md "$output")
[[ -f "$output".md ]] || {
	echo "$output.md not found"
	exit 1
}

	sed -i "s/\f/<hr class=head>/g" "$output".md
	sed -i "s/^• / * /g" "$output".md
	sed -i "s/\f/<hr class=head>/g" "$output".md

  pandoc --from=markdown --to=html \
      --highlight-style="/ai/web/www/vhosts/customkb.dev/html/pandoc/zenburn.theme" \
      "$output".md >"$output"-1.html
  echo "
  <style>
    h2 { font-weight:bold; }
    .head {
      border: none;
      border-top: 3px solid #ffffff;
      border-bottom: 3px solid #ffffff;
      height: 6px;
      background-color: transparent;
    }
  </style>
  <image r 30 \"/images/dharmas.png\" \"Dharmas\" \"\">

  " >"$output".html
  cat "$output"-1.html >> "$output".html
  rm "$output"-1.html

#fin
