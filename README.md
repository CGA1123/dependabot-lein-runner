# dependabot-lein-runner

This runs dependabot for our Clojure (lein) projects using a [fork] of
[`dependabot/dependabot-core`] that has support for lein.

Updates will be checked daily at 0930. Manual checks can be triggered as well
in the [Actions] tab.

The `run.sh` executes the `update.rb` script using a trimmed down version of
the `Dockerfile` from `dependabot-core` which contains only what is required
to run updates on `lein` projects. The image is pushed to
`carwow/dependabot-lein-runner` on Docker Hub.

It uses the following environment variables:
- `GITHUB_REPO` the repo to update in `owner/repo` format
- `GITHUB_MAVEN_REGISTRIES` any github packages maven repository urls for private packages (comma separated)
- `GITHUB_TOKEN` the github access token to use to both check the private repositories and create pull requests

[`dependabot/dependabot-core`]: https://github.com/dependabot/dependabot-core
[fork]: https://github.com/CGA1123/dependabot-core/tree/leiningen
[Actions]: https://github.com/carwow/dependabot-lein-runner/actions?query=workflow%3A%22Manual+Bump%22
