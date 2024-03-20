#!/bin/sh

sops updatekeys ./users/rui/secrets.yaml
sops updatekeys ./hosts/configs/sputnik/secrets.yaml
