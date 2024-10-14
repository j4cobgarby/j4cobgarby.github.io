#!/bin/sh
# Ensures that repo is up to date with Github master, and then builds the static
# html using jekyll. It then copies this to a place where Caddy will serve files
# from.

git pull && bundle exec jekyll build -d /var/www/html --trace
