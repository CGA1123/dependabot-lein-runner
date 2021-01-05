FROM ubuntu:18.04

### SYSTEM DEPENDENCIES

ENV DEBIAN_FRONTEND="noninteractive" \
  LC_ALL="en_US.UTF-8" \
  LANG="en_US.UTF-8"

RUN apt-get update \
  && apt-get upgrade -y \
  && apt-get install -y --no-install-recommends \
    build-essential \
    dirmngr \
    git \
    bzr \
    mercurial \
    gnupg2 \
    curl \
    wget \
    file \
    zlib1g-dev \
    liblzma-dev \
    tzdata \
    zip \
    unzip \
    locales \
    openssh-client \
  && locale-gen en_US.UTF-8

### RUBY

# Install Ruby 2.6.6, update RubyGems, and install Bundler
ENV BUNDLE_SILENCE_ROOT_WARNING=1
RUN apt-get install -y software-properties-common \
  && apt-add-repository ppa:brightbox/ruby-ng \
  && apt-get update \
  && apt-get install -y ruby2.6 ruby2.6-dev \
  && gem update --system 3.0.3 \
  && gem install bundler -v 1.17.3 --no-document


### CLOJURE

# Install leiningen
RUN apt-get update \
  && apt-get install -y openjdk-8-jre-headless \
  && java -version \
  && wget "https://raw.githubusercontent.com/technomancy/leiningen/stable/bin/lein" \
  && mkdir -p /usr/local/lein/bin \
  && mv lein /usr/local/lein/bin \
  && chmod +x /usr/local/lein/bin/lein \
  && /usr/local/lein/bin/lein version

ENV PATH="$PATH:/usr/local/lein/bin" \
  LEIN_SNAPSHOTS_IN_RELEASE="yes"

# Get dependabot source
RUN git clone --branch leiningen https://github.com/CGA1123/dependabot-core /home/app/dependabot-core # :buildcache:
WORKDIR /home/app/dependabot-core
RUN echo $(git rev-parse --short HEAD)

# Install native clojure helper
RUN mkdir -p /opt/lein/helpers
RUN cp -R ./lein/helpers /opt/lein/

ENV DEPENDABOT_NATIVE_HELPERS_PATH="/opt"

RUN bash /opt/lein/helpers/build /opt/lein

# Setup update script
COPY . /home/app/dependabot-lein-runner
WORKDIR /home/app/dependabot-lein-runner

RUN bundle install --path vendor

COPY ./entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
