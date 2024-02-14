#!/bin/sh

sops updatekeys ./users/rui/secrets.yaml
sops updatekeys ./hosts/common-secrets.yaml
sops updatekeys ./hosts/configs/soyuz/secrets.yaml
sops updatekeys ./hosts/configs/sputnik/secrets.yaml
sops updatekeys ./hosts/configs/ariane/secrets.yaml
