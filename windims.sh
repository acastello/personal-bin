#!/bin/sh

set -e
xwininfo | awk -F: '
/Absolute upper-left X/{x=$2}
/Absolute upper-left Y/{y=$2}
/Width/{w=$2}
/Height/{h=$2}
END{
  printf "-s %dx%d -i %s.0+%d,%d", w, h, ENVIRON["DISPLAY"], x, y
}
'
