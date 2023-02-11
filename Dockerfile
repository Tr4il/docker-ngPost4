# Pull base image.
FROM jlesage/baseimage-gui:debian-11-v4

# Docker image version is provided via build arg.
ARG DOCKER_IMAGE_VERSION=unknown

# Define software versions.
ARG NGPOST_VERSION=4.16

# Define software download URLs.
ARG NGPOST_URL=https://github.com/mbruel/ngPost/archive/refs/tags/v${NGPOST_VERSION}.tar.gz

# Define working directory.
WORKDIR /tmp

# Install dependencies.
RUN sed -i 's/main$/main non-free/' /etc/apt/sources.list

RUN apt-get update && apt-get install --no-install-recommends -y \
        curl \
        qtbase5-dev \
        qtchooser \
        qt5-qmake \
        qtbase5-dev-tools \
        build-essential \
        ca-certificates \
        nodejs \
        npm \
        git \
        wget \
        bash \
        tar \
        && rm -rf /var/lib/apt/lists/*

# Compile and install ngPost.

RUN \
    # Download sources for ngPost.
    echo "Downloading ngPost package..." && \
    mkdir ngPost && \
    curl -# -L ${NGPOST_URL} | tar xz --strip 1 -C ngPost && \
    # Compile.
    cd ngPost/src && \
    qmake && \
    make -j$(nproc) && \
    cp ngPost /usr/bin/ngPost && \
    cd && \
    # Cleanup.
    rm -rf /tmp/* /tmp/.[!.]*

# Install 7z (not p7zip)
# new: https://7-zip.org/a/7z2201-linux-x64.tar.xz
# old: https://www.7-zip.org/a/7z2103-linux-x64.tar.xz

#RUN \
#    mkdir /temp && cd /temp && \
#    wget https://7-zip.org/a/7z2201-linux-x64.tar.xz && \
#    tar xvf 7z2201-linux-x64.tar.xz && \
#   cp 7zz /usr/bin/7z && \
#    cd && \
#    rm -rf /temp/* /temp/.[!.]*

COPY 7zip/7zz /usr/bin/7z

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