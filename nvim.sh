#!/bin/bash

docker build --platform=linux/amd64 -t catdadcode/nvim:latest -f ./nvim.Dockerfile ./

# Check if the user supplied a path.
if [[ $# -gt 0 ]]; then
	# Get the base directory or file name.
	base_name=$(basename "$1")
	# Run the Docker container with volume mapping.
	docker run -it --platform=linux/amd64 -v "$1:/$base_name" catdadcode/nvim:latest "/$base_name"
else
	# Run the Docker container without volume mapping.
	docker run -it --platform=linux/amd64 catdadcode/nvim:latest
fi
