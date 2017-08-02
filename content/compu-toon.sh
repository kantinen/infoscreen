#!/bin/sh

img_url=$(curl -sL http://www.gocomics.com/random/compu-toon | grep data-image | cut -d'"' -f2)

curl "$img_url" > /tmp/compu-toon
surf content/res/compu-toon.html
