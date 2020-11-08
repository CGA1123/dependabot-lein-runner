# dependabot-lein-runner

This runs dependabot for Clojure (lein) projects using a [fork] of
[`dependabot/dependabot-core`] that has support for lein.

The `run.sh` script executes the `update.rb` script using a trimmed down
version of the `Dockerfile` from `dependabot-core` which contains only what is
required to run updates on `lein` projects. The image is pushed to
[`ghcr.io/cga1123/dependabot-lein-runner`].

It uses the following environment variables:
- `GITHUB_REPO` the repo to update in `owner/repo` format
- `GITHUB_MAVEN_REGISTRIES` any github packages maven repository urls for private packages (comma separated)
- `GITHUB_TOKEN` the github access token to use to both check the private repositories and create pull requests

The actions in the repo expect the `PERSONAL_TOKEN` secret to be set. This secret
will be used as the `GITHUB_TOKEN` in `run.sh` and will also be used to authenticate
against `ghcr.io`.

[`ghcr.io/cga1123/dependabot-lein-runner`]: https://github.com/users/CGA1123/packages/container/package/dependabot-lein-runner
[`dependabot/dependabot-core`]: https://github.com/dependabot/dependabot-core
[fork]: https://github.com/CGA1123/dependabot-core/tree/leiningen
[Actions]: https://github.com/carwow/dependabot-lein-runner/actions?query=workflow%3A%22Manual+Bump%22
