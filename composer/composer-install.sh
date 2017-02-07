#!/usr/bin/env bash
set -e

# Add SSH key and github token to enable private dependencies.
mkdir -p /root/.ssh

# Keyscan hosts we plan to access.
if [ -n "$ACCEPT_HOSTS" ]; then
  ssh-keyscan "$ACCEPT_HOSTS" >> /root/.ssh/known_hosts
  cat /root/.ssh/known_hosts
fi

if [ -n "$VAULT_TOKEN" ]; then
  SSH_PRIVATE_KEY=$(vault read -field=value secret/SSH_PRIVATE_KEY) || true
  GITHUB_PRIVATE_TOKEN=$(vault read -field=value secret/GITHUB_PRIVATE_TOKEN) || true
else
  export SSH_PRIVATE_KEY=''
  export GITHUB_PRIVATE_TOKEN=''
fi


if [ -n "$GITHUB_PRIVATE_TOKEN" ]; then
  echo "Installing github private token."
  composer config -g github-oauth.github.com "$GITHUB_PRIVATE_TOKEN"
fi

if [ -n "$SSH_PRIVATE_KEY" ]; then
  echo "Installing ssh private key."
  export SSH_PRIVATE_KEY
  printenv SSH_PRIVATE_KEY >> /root/.ssh/id_rsa
  chmod 600 /root/.ssh/id_rsa
fi

echo "Running composer install in $COMPOSER."
composer install

# Remove the private key and github token to leave no traces in the image.
if [ -n "$GITHUB_PRIVATE_TOKEN" ]; then
  echo "Removing github private token."
  composer config -g github-oauth.github.com deleted
fi

if [ -n "$SSH_PRIVATE_KEY" ]; then
  echo "Removing ssh private key."
  rm /root/.ssh/id_rsa
fi
