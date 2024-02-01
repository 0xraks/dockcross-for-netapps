# Base image
FROM ubuntu:20.04

LABEL maintainer="Rakshith rakshith152@gmail.com"
LABEL version="0.01"
LABEL description="Buildsystem for arm32-bit and arm64-bit libnl apps"

ENV TZ=Europe/Kiev
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install cross compilation toolchains
RUN DEBIAN_FRONTEND=noninteractive apt-get update && apt-get install -y \
    crossbuild-essential-armhf \
    crossbuild-essential-arm64

# Install dependencies for libnl and OpenSSL
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y \
    libnl-3-dev \
    libnl-genl-3-dev \
    libssl-dev git bc libc6-dev \
    libncurses5-dev build-essential libmnl-dev\
    pkg-config wget flex bison tree nano vim
    # libc-dev-arm64-cross unzip  expat nano vim

# Build and install libnl from source for arm 32 bit system (armv4)
WORKDIR /
RUN wget https://github.com/thom311/libnl/releases/download/libnl3_5_0/libnl-3.5.0.tar.gz
RUN tar -xvf libnl-3.5.0.tar.gz
WORKDIR /libnl-3.5.0
RUN ./configure --host=arm-linux-gnueabihf --prefix=/usr/arm-linux-gnueabihf/
RUN make -j$(nproc --ignore=1)
RUN make install -j$(nproc --ignore=1)

# Build and install OpenSSL from source for arm 32 bit system (armv4)
WORKDIR /
RUN wget https://www.openssl.org/source/openssl-1.1.1k.tar.gz
RUN tar -xvf openssl-1.1.1k.tar.gz
WORKDIR /openssl-1.1.1k
RUN ./Configure linux-armv4 --cross-compile-prefix=arm-linux-gnueabihf- --prefix=/usr/arm-linux-gnueabihf/
RUN make CC=arm-linux-gnueabihf-gcc -j$(nproc --ignore=1)
RUN make install_sw -j$(nproc --ignore=1)

# Build and install expat from source for arm 32 bit system (armv4)
WORKDIR /
RUN wget https://github.com/libexpat/libexpat/releases/download/R_2_4_1/expat-2.4.1.tar.gz
RUN tar -xvf expat-2.4.1.tar.gz
WORKDIR /expat-2.4.1
RUN ./configure --host=arm-linux-gnueabihf --prefix=/usr/arm-linux-gnueabihf/
# CFLAGS="-I/usr/arm-linux-gnueabihf/include" LDFLAGS="-L/usr/arm-linux-gnueabihf/lib"
RUN make CC=arm-linux-gnueabihf-gcc -j$(nproc --ignore=1)
RUN make install -j$(nproc --ignore=1)

WORKDIR /
RUN wget https://dbus.freedesktop.org/releases/dbus/dbus-1.14.2.tar.xz
RUN tar -xf dbus-1.14.2.tar.xz 
WORKDIR /dbus-1.14.2
ENV  PKG_CONFIG_PATH=/usr/arm-linux-gnueabihf/lib/pkgconfig/
RUN ./configure --host=arm-linux-gnueabihf --prefix=/usr/arm-linux-gnueabihf/
RUN make -j$(nproc --ignore=1)
RUN make install -j$(nproc --ignore=1)

WORKDIR /
RUN wget https://netfilter.org/projects/libmnl/files/libmnl-1.0.5.tar.bz2
RUN tar -xvf libmnl-1.0.5.tar.bz2
WORKDIR /libmnl-1.0.5
RUN ./configure --host=arm-linux-gnueabihf --prefix=/usr/arm-linux-gnueabihf/
# CFLAGS="-I/usr/arm-linux-gnueabihf/include" LDFLAGS="-L/usr/arm-linux-gnueabihf/lib"
RUN make CC=arm-linux-gnueabihf-gcc -j$(nproc --ignore=1)
RUN make install -j$(nproc --ignore=1)

#----------------------------------------------------------------------------------------------------------------------------------------------

# Build and install libnl from source for arm64 bit
WORKDIR /libnl-3.5.0
RUN make clean -j$(nproc --ignore=1)
RUN ./configure --host=aarch64-linux-gnu --prefix=/usr/aarch64-linux-gnu/
RUN make -j$(nproc --ignore=1)
RUN make install -j$(nproc --ignore=1)

# Build and install OpenSSL from source for arm64 bit
WORKDIR /openssl-1.1.1k
RUN make clean -j$(nproc --ignore=1)
RUN ./Configure linux-aarch64 --cross-compile-prefix=aarch64-linux-gnu- --prefix=/usr/aarch64-linux-gnu/
RUN make CC=aarch64-linux-gnu-gcc -j$(nproc --ignore=1)
RUN make install_sw -j$(nproc --ignore=1)


# Build and install expat from source for arm64 bit
WORKDIR /expat-2.4.1
RUN make clean -j$(nproc --ignore=1)
RUN ./configure --host=aarch64-linux-gnu --prefix=/usr/aarch64-linux-gnu/
# CFLAGS="-I/usr/aarch64-linux-gnu/include" LDFLAGS="-L/usr/aarch64-linux-gnu/lib"
RUN make CC=aarch64-linux-gnu-gcc -j$(nproc --ignore=1)
RUN make install -j$(nproc --ignore=1)


# Build and install dbus from source for arm64 bit
WORKDIR /dbus-1.14.2
RUN make clean -j$(nproc --ignore=1)
ENV PKG_CONFIG_PATH=/usr/aarch64-linux-gnu/lib/pkgconfig/
RUN ./configure --host=aarch64-linux-gnu --prefix=/usr/aarch64-linux-gnu/
RUN make -j$(nproc --ignore=1)
RUN make install -j$(nproc --ignore=1)

WORKDIR /libmnl-1.0.5
RUN make clean -j$(nproc --ignore=1)
ENV PKG_CONFIG_PATH=/usr/aarch64-linux-gnu/lib/pkgconfig/
RUN ./configure --host=aarch64-linux-gnu --prefix=/usr/aarch64-linux-gnu/
RUN make -j$(nproc --ignore=1)
RUN make install -j$(nproc --ignore=1)

# Build and install OpenSSL from source for arm64 bit

# Set working directory to /app
WORKDIR /app

# Mount a source code directory into the container
VOLUME /app
RUN echo "alias activate_arm64='export PKG_CONFIG_PATH=/usr/aarch64-linux-gnu/lib/pkgconfig/ && export LD_LIBRARY_PATH=/usr/aarch64-linux-gnu/lib/'" >> ~/.bashrc
RUN echo "alias activate_arm32='export PKG_CONFIG_PATH=/usr/arm-linux-gnueabihf/lib/pkgconfig/ && export LD_LIBRARY_PATH=/usr/arm-linux-gnueabihf/lib/'" >> ~/.bashrc
# Default command
COPY build_hostap.sh /bin
COPY build_wl.sh /bin
CMD ["/bin/bash"]

# make -j8 CC=aarch64-linux-gnu-gcc LDFLAGS+=-static LIBS+="-lssl -lcrypto  -lnl-genl-3 -lnl-3 -lpthread -ldl"
# CONFIG_DRIVER_NL80211=y
# CFLAGS += -I/usr/include/libnl3
# CONFIG_LIBNL32=y