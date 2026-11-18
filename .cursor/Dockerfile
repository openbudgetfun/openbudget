# OS packages for Cursor Cloud Agents. Nix and devenv are installed for the
# runtime user by .cursor/install.sh (a root profile would not be on that
# user's PATH). The repository is checked out after the image is built.
FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive \
    LANG=C.UTF-8 \
    PATH=/usr/local/bin:/usr/lib/postgresql/16/bin:${PATH}

RUN if ! id ubuntu >/dev/null 2>&1; then \
      useradd --create-home --shell /bin/bash ubuntu; \
    fi \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
      ca-certificates \
      curl \
      git \
      postgresql \
      postgresql-contrib \
      redis-server \
      sudo \
      xz-utils \
    && rm -rf /var/lib/apt/lists/* \
    && printf '%s\n' 'ubuntu ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/ubuntu \
    && chmod 440 /etc/sudoers.d/ubuntu \
    && if [ ! -d /run/systemd/system ]; then \
      printf '%s\n' '#!/bin/sh' 'exit 101' > /usr/sbin/policy-rc.d; \
      chmod 755 /usr/sbin/policy-rc.d; \
    fi

USER ubuntu
