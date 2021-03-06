# FROM alpine:3.4
FROM alpine:3.5

ARG VERSION
ARG NPM_VERSION

# ENV VERSION=v4.7.3 NPM_VERSION=2
# ENV VERSION=v6.9.5 NPM_VERSION=3
ENV VERSION=${VERSION:-7.5.0} NPM_VERSION=${NPM_VERSION:-4}

# For base builds
ENV CONFIG_FLAGS="--fully-static" DEL_PKGS="libstdc++" RM_DIRS=/usr/include

RUN apk add --no-cache bash curl git make gcc g++ python-dev linux-headers binutils-gold gnupg libgcc libstdc++ musl-dev && \
  gpg --keyserver ha.pool.sks-keyservers.net --recv-keys \
    9554F04D7259F04124DE6B476D5A82AC7E37093B \
    94AE36675C464D64BAFA68DD7434390BDBE9B9C5 \
    0034A06D9D9B0064CE8ADF6BF1747F4AD2306D93 \
    FD3A5288F042B6850C66B31F09FE44734EB7990E \
    71DCFD284A79C3B38668286BC97EC7A07EDE3FC1 \
    DD8F2338BAE7501E3DD5AC78C273792F7D83545D \
    C4F0DFFF4E8C1A8236409D08E73BC641CC11F4C8 \
    B9AE9905FFD7803F25714661B63B535A4C206CA9 && \
  curl -sSLO https://nodejs.org/dist/${VERSION}/node-${VERSION}.tar.xz && \
  curl -sSL https://nodejs.org/dist/${VERSION}/SHASUMS256.txt.asc | gpg --batch --decrypt | \
    grep " node-${VERSION}.tar.xz\$" | sha256sum -c | grep . && \
  tar -xf node-${VERSION}.tar.xz && \
  cd node-${VERSION} && \
  ./configure --prefix=/usr ${CONFIG_FLAGS} && \
  make -j$(getconf _NPROCESSORS_ONLN) && \
  make install && \
  cd / && \
  if [ -x /usr/bin/npm ]; then \
    npm install -g npm@${NPM_VERSION} && \
    npm install -g node-gyp && \
    npm install -g node-sass && \
    find /usr/lib/node_modules/npm -name test -o -name .bin -type d | xargs rm -rf; \
  fi && \
  apk del linux-headers binutils-gold gnupg ${DEL_PKGS} && \
  rm -rf ${RM_DIRS} /node-${VERSION}* /usr/share/man /tmp/* /var/cache/apk/* \
    /root/.gnupg /usr/lib/node_modules/npm/man /usr/lib/node_modules/npm/doc /usr/lib/node_modules/npm/html \
    /usr/lib/node_modules/npm/scripts
