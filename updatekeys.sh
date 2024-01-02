#!/bin/sh

sops updatekeys ./users/rui/secrets.yaml
sops updatekeys ./hosts/common-secrets.yaml