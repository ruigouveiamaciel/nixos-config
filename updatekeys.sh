#!/bin/sh

sops updatekeys -y ./hosts/proxmox/devbox/secrets.yaml
sops updatekeys -y ./hosts/proxmox/homepage/secrets.yaml
sops updatekeys -y ./hosts/proxmox/media-server/secrets.yaml
