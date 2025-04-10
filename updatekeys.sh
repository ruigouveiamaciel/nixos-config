#!/bin/sh

sops updatekeys -y ./hosts/proxmox/devbox-lxc/secrets.yaml
sops updatekeys -y ./hosts/proxmox/homepage-lxc/secrets.yaml
sops updatekeys -y ./hosts/proxmox/vikunja-lxc/secrets.yaml
sops updatekeys -y ./hosts/proxmox/immich-lxc/secrets.yaml
