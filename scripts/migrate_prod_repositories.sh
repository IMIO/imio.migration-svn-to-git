#!/usr/bin/env bash
set -e
for instance in $(find /srv/instances -mindepth 1 -maxdepth 1 -type d); do
  echo "--- $instance ---"
  if [[ ! -d $instance/.svn ]]; then
    continue
  fi
  branch=$(svn info "$instance"|grep "^URL:"|sed 's%.*tags/\(.*\)%\1%g')
  echo "$branch"
  if [[ ! -d /tmp/$branch ]]; then
    git clone https://github.com/IMIO/server.urban.git -b "$branch" "/tmp/$branch"
  fi
  rsync -aqv "/tmp/$branch/.git/" "$instance/.git/"
  git -C "$instance" checkout -- .gitignore

  product_urban_tag=$(svn info "$instance/src/Products.urban"| grep '^URL:' | grep -E -o '(tags|branches)/[^/]+|trunk' | grep -E -o '[^/]+$')
  if [[ $product_urban_tag == "trunk" ]]; then
    product_urban_tag="master"
  fi
  echo $product_urban_tag
  if [[ ! -d /tmp/product_urban_tag_$product_urban_tag ]]; then
    git clone https://github.com/IMIO/Products.urban.git /tmp/product_urban_tag_$product_urban_tag
    git -C /tmp/product_urban_tag_$product_urban_tag checkout $product_urban_tag
  fi
  rsync -aqv /tmp/product_urban_tag_$product_urban_tag/.git/ "$instance/src/Products.urban/.git/"

done
