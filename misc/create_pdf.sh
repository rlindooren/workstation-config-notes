pandoc rescue-cheatsheet.md -o rescue-cheatsheet.pdf \
  --pdf-engine=xelatex \
  -V mainfont="Liberation Sans" \
  -V monofont="Liberation Mono" \
  -V papersize=a4
