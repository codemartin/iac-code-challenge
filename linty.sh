#!/bin/bash

# Install tflint
curl -L "$(curl -s https://api.github.com/repos/terraform-linters/tflint/releases/latest | grep -o -E "https://.+?_linux_amd64\.zip")" --output tflint.zip
unzip tflint.zip
rm tflint.zip
#normally I would use sudo here but cnat be run on my machine via git bash 
#sudo mv tflint /usr/local/bin/
mv tflint /usr/local/bin/

# Run tflint on Terraform files
tflint
