# Pull base image.
FROM jlesage/baseimage-gui:alpine-3.21-v4

# Docker image version is provided via build arg.
ARG DOCKER_IMAGE_VERSION=unknown

# Define software versions.
ARG NGPOST_VERSION=4.17

# Define software download URLs.
# ARG NGPOST_URL=https://github.com/mbruel/ngPost/archive/refs/tags/v${NGPOST_VERSION}.tar.gz
# ARG NGPOST_URL=https://github.com/Tr4il/ngPost/tarball/alpine-fix
ARG NGPOST_URL=https://github.com/Tr4il/ngPost/tarball/obfuscation-fix

# Define working directory.
WORKDIR /tmp

# Install dependencies.
RUN add-pkg \
        curl \
        qt5-qtsvg \
        qt5-qtbase-dev \
        build-base \
        nodejs \
        npm \
        git \
        wget \
        bash \
        tar \
        libc6-compat \
        libstdc++ \
        fontconfig \
        ttf-freefont \
        font-noto \
        terminus-font \ 
        gcompat \
        7zip \
     && fc-cache -f

# Compile and install ngPost.
RUN \
    # Download sources for ngPost.
    echo "Downloading ngPost package..." && \
    mkdir ngPost && \
    curl -# -L ${NGPOST_URL} | tar xz --strip 1 -C ngPost && \
    # Compile.
    cd ngPost/src && \
    /usr/lib/qt5/bin/qmake ngPost.pro -o Makefile && \
    make && \
    cp ngPost /usr/bin/ngPost && \
    cd && \
    # Cleanup.
    rm -rf /tmp/* /tmp/.[!.]*

RUN \
    npm install -g @animetosho/parpar

# Generate and install favicons.
RUN \
    APP_ICON_URL=https://raw.githubusercontent.com/mbruel/ngPost/master/src/resources/icons/ngPost.png && \
    install_app_icon.sh "$APP_ICON_URL"

# Add files.
COPY rootfs/ /

# Set environment variables.
ENV APP_NAME="ngPost"

# Define mountable directories.
VOLUME ["/config"]
VOLUME ["/storage"]

# Metadata.
LABEL \
      org.label-schema.name="ngPost" \
      org.label-schema.description="Docker container for ngPost" \
      org.label-schema.version="$DOCKER_IMAGE_VERSION" \
      org.label-schema.vcs-url="https://github.com/Tr4il/docker-ngPost" \
      org.label-schema.schema-version="4.17"
