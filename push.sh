#!/usr/bin/env bash
set -e

images="php composer drupal"

for image in $images; do
  for tagfile in $image/Dockerfiles/*; do
    tag=$(basename "$tagfile")
    docker push iamdork/"$image":"$tag"
  done
done

