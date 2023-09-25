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
echo "**** build 7zip ****" && \
  ln -s /usr/bin/clang-14 /usr/local/bin/clang && \
  ln -s /usr/bin/clang++-14 /usr/local/bin/clang++ && \
  mkdir /usr/local/src && cd /usr/local/src && git clone --branch v2.56.2 https://github.com/Terraspace/UASM.git && \
  cd /usr/local/src/UASM && make CC="clang -fcommon -static -std=gnu99 -Wno-error=int-conversion" -f gccLinux64.mak && \
  cp /usr/local/src/UASM/GccUnixR/uasm /usr/local/bin/uasm && \
  curl -o /tmp/7z${SEVENZIPVERSION}-src.tar.xz "https://www.7-zip.org/a/7z${SEVENZIPVERSION}-src.tar.xz" && \
  mkdir /usr/local/src/7z${SEVENZIPVERSION} && cd /usr/local/src/7z${SEVENZIPVERSION} && tar -xf /tmp/7z${SEVENZIPVERSION}-src.tar.xz && \
  cd /usr/local/src/7z${SEVENZIPVERSION} && sed -i -e '1i\OPTION FRAMEPRESERVEFLAGS:ON\nOPTION PROLOGUE:NONE\nOPTION EPILOGUE:NONE' Asm/x86/7zAsm.asm && \
  cd /usr/local/src/7z${SEVENZIPVERSION}/CPP/7zip/Bundles/Alone2 && make CFLAGS_BASE_LIST="-c -static -D_7ZIP_AFFINITY_DISABLE=1 -DZ7_AFFINITY_DISABLE=1 -D_GNU_SOURCE=1" MY_ASM=uasm MY_ARCH="-static" CFLAGS_WARN_WALL="-Wall -Wextra" -f ../../cmpl_clang_x64.mak && \
  strip /usr/local/src/7z${SEVENZIPVERSION}/CPP/7zip/Bundles/Alone2/b/c_x64/7zz && \
  mv /usr/local/src/7z${SEVENZIPVERSION}/CPP/7zip/Bundles/Alone2/b/c_x64/7zz /usr/bin/7z && \
  chmod +x /usr/bin/7z && \
  cd && \
  rm -rf /temp/* /temp/.[!.]*

# Compile and install ParPar.
# RUN \
#    # Download sources for parpar
#    echo "Downloading & Installing ParPar" && \
#    npm install -g @animetosho/parpar --unsafe-perm    

RUN \
    cd /temp && \
    mkdir ParPar && \
    curl -# -L https://github.com/animetosho/ParPar/tarball/master | tar xz --strip 1 -C ParPar && \
    cd ParPar && \
    npm install -g node-gyp --unsafe-perm && \
    node-gyp rebuild && \
    npm install && \
    ln -s /temp/ParPar/bin/parpar.js /usr/bin/parpar && \
    cd

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
