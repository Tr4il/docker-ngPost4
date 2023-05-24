# Pull base image.
FROM jlesage/baseimage-gui:alpine-3.18-v4

# Docker image version is provided via build arg.
ARG DOCKER_IMAGE_VERSION=unknown

# Define software versions.
ARG NGPOST_VERSION=4.16

# Define software download URLs.
# ARG NGPOST_URL=https://github.com/mbruel/ngPost/archive/refs/tags/v${NGPOST_VERSION}.tar.gz
ARG NGPOST_URL=https://github.com/Tr4il/ngPost/tarball/alpine-fix

# Install glibc according to instructions
RUN install-glibc

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

# Install 7z (not p7zip)
RUN \
    mkdir /temp && cd /temp && \
    wget https://7-zip.org/a/7z2300-linux-x64.tar.xz && \
    tar xvf 7z2300-linux-x64.tar.xz && \
    cp 7zzs /usr/bin/7z && \
    chmod +x /usr/bin/7z && \
    cd && \
    rm -rf /temp/* /temp/.[!.]*

# Compile and install ParPar.
RUN \
    # Download sources for parpar
    echo "Downloading & Installing ParPar" && \
    npm install -g @animetosho/parpar --unsafe-perm    

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
      org.label-schema.schema-version="4.16"
