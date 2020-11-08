#!/bin/bash

set -eu

docker run \
  -v $(pwd)/update.rb:/home/app/dependabot-lein-runner/update.rb \
  -e GITHUB_REPO \
  -e GITHUB_TOKEN \
  -e GITHUB_MAVEN_REGISTRIES \
  ghcr.io/cga1123/dependabot-lein-runner:latest \
  bundle exec ruby ./update.rb
