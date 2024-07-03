#!/bin/sh
# Ensures that repo is up to date with Github master, and then builds the static
# html using jekyll. It then copies this to a place where Caddy will serve files
# from.

git pull
jekyll build
echo "Cleaning /var/www/html"
sudo rm -rf /var/www/html/*
echo "Copying files"
sudo cp -r ./_site/* /var/www/html/
echo "All done"
