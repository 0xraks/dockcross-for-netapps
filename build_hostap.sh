#!/bin/bash

# mkdir -p -v /app/bin/static/arm32 /app/bin/static/arm64 /app/bin/dyn/arm32 /app/bin/dyn/arm64  /app/bin/x86
# export LD_LIBRARY_PATH=/usr/aarch64-linux-gnu/:/usr/arm-linux-gnueabihf/

mkdir -p -v /app/bin/arm32/dynamic /app/bin/arm32/static /app/bin/arm64/dynamic /app/bin/arm64/static  /app/bin/x86/static /app/bin/x86/dynamic
# ====================================================================================================================
# 
# x86 Builds
#
# cd /app/hostap/hostapd
# make clean
# cp defconfig_base .config
# sed -i 's/CONFIG_DRIVER_NL80211=.*/CONFIG_DRIVER_NL80211=y/' .config
# sed -i 's/CONFIG_LIBNL32=.*/CONFIG_LIBNL32=y/' .config
# make LDFLAGS+=-static LIBS+="-lssl -lcrypto  -lnl-genl-3 -lnl-3 -lpthread -ldl"  -j$(nproc --ignore=1)
# cp hostapd /app/bin/x86/static
# cp hostapd_cli /app/bin/x86/static

# make clean
# cp defconfig_base .config
# sed -i 's/CONFIG_DRIVER_NL80211=.*/CONFIG_DRIVER_NL80211=y/' .config
# sed -i 's/CONFIG_LIBNL32=.*/CONFIG_LIBNL32=y/' .config
# make -j$(nproc --ignore=1)
# cp hostapd /app/bin/x86/dynamic
# cp hostapd_cli /app/bin/x86/dynamic

# cd /app/hostap/wpa_supplicant/
# make clean
# cp defconfig_base .config
# sed -i 's/CONFIG_DRIVER_NL80211=.*/CONFIG_DRIVER_NL80211=y/' .config
# sed -i 's/CONFIG_LIBNL32=.*/CONFIG_LIBNL32=y/' .config
# make LDFLAGS+="-static -Wno-as-needed" LIBS="-lpthread -lnl-3 -pthread -lnl-genl-3 -lnl-route-3 -ldbus-1 -lssl -lcrypto -ldl" -j$(nproc --ignore=1)
# cp wpa_supplicant /app/bin/x86/static
# cp wpa_cli /app/bin/x86/static
# cp wpa_passphrase /app/bin/x86/static

# make clean
# cp defconfig_base .config
# sed -i 's/CONFIG_DRIVER_NL80211=.*/CONFIG_DRIVER_NL80211=y/' .config
# sed -i 's/CONFIG_LIBNL32=.*/CONFIG_LIBNL32=y/' .config
# make -j$(nproc --ignore=1)
# cp wpa_supplicant /app/bin/x86/dynamic
# cp wpa_cli /app/bin/x86/dynamic
# cp wpa_passphrase /app/bin/x86/dynamic

# ====================================================================================================================
# 
# ARM64 Builds
#
export PKG_CONFIG_PATH=/usr/aarch64-linux-gnu/lib/pkgconfig/ && export LD_LIBRARY_PATH=/usr/aarch64-linux-gnu/lib/
cd /app/hostap/hostapd
make clean
cp defconfig_base .config
sed -i 's/CONFIG_DRIVER_NL80211=.*/CONFIG_DRIVER_NL80211=y/' .config
sed -i 's/CONFIG_LIBNL32=.*/CONFIG_LIBNL32=y/' .config
make CC=aarch64-linux-gnu-gcc  LDFLAGS+=-static LIBS+="-lssl -lcrypto  -lnl-genl-3 -lnl-3 -lpthread -ldl"  -j$(nproc --ignore=1)
cp hostapd /app/bin/arm64/static
cp hostapd_cli /app/bin/arm64/static

make clean
cp defconfig_base .config
sed -i 's/CONFIG_DRIVER_NL80211=.*/CONFIG_DRIVER_NL80211=y/' .config
sed -i 's/CONFIG_LIBNL32=.*/CONFIG_LIBNL32=y/' .config
make CC=aarch64-linux-gnu-gcc -j$(nproc --ignore=1)
cp hostapd /app/bin/arm64/dynamic
cp hostapd_cli /app/bin/arm64/dynamic

cd /app/hostap/wpa_supplicant/
make clean
cp defconfig_base .config
sed -i 's/CONFIG_DRIVER_NL80211=.*/CONFIG_DRIVER_NL80211=y/' .config
sed -i 's/CONFIG_LIBNL32=.*/CONFIG_LIBNL32=y/' .config
make CC=aarch64-linux-gnu-gcc  -j$(nproc --ignore=1)
cp wpa_supplicant /app/bin/arm64/dynamic
cp wpa_cli /app/bin/arm64/dynamic
cp wpa_passphrase /app/bin/arm64/dynamic

make clean
cp defconfig_base .config
sed -i 's/CONFIG_DRIVER_NL80211=.*/CONFIG_DRIVER_NL80211=y/' .config
sed -i 's/CONFIG_LIBNL32=.*/CONFIG_LIBNL32=y/' .config
make CC=aarch64-linux-gnu-gcc LDFLAGS+="-static -Wno-as-needed" LIBS="-lpthread -lnl-3 -pthread -lnl-genl-3 -lnl-route-3 -ldbus-1 -lssl -lcrypto -ldl" -j$(nproc --ignore=1)
cp wpa_supplicant /app/bin/arm64/static
cp wpa_cli /app/bin/arm64/static
cp wpa_passphrase /app/bin/arm64/static

# ====================================================================================================================
# 
# ARM32 Builds
#
export PKG_CONFIG_PATH=/usr/arm-linux-gnueabihf/lib/pkgconfig/ && export LD_LIBRARY_PATH=/usr/arm-linux-gnueabihf/lib/
cd /app/hostap/hostapd
make clean
cp defconfig_base .config
sed -i 's/CONFIG_DRIVER_NL80211=.*/CONFIG_DRIVER_NL80211=y/' .config
sed -i 's/CONFIG_LIBNL32=.*/CONFIG_LIBNL32=y/' .config
make CC=arm-linux-gnueabihf-gcc  LDFLAGS+=-static LIBS+="-lssl -lcrypto  -lnl-genl-3 -lnl-3 -lpthread -ldl"  -j$(nproc --ignore=1)
cp hostapd /app/bin/arm32/static
cp hostapd_cli /app/bin/arm32/static

cd /app/hostap/hostapd
make clean
cp defconfig_base .config
sed -i 's/CONFIG_DRIVER_NL80211=.*/CONFIG_DRIVER_NL80211=y/' .config
sed -i 's/CONFIG_LIBNL32=.*/CONFIG_LIBNL32=y/' .config
make CC=arm-linux-gnueabihf-gcc  -j$(nproc --ignore=1)
cp hostapd /app/bin/arm32/dynamic
cp hostapd_cli /app/bin/arm32/dynamic

cd /app/hostap/wpa_supplicant/
make clean
cp defconfig_base .config
sed -i 's/CONFIG_DRIVER_NL80211=.*/CONFIG_DRIVER_NL80211=y/' .config
sed -i 's/CONFIG_LIBNL32=.*/CONFIG_LIBNL32=y/' .config
make CC=arm-linux-gnueabihf-gcc  -j$(nproc --ignore=1)
cp wpa_supplicant /app/bin/arm32/dynamic
cp wpa_cli /app/bin/arm32/dynamic
cp wpa_passphrase /app/bin/arm32/dynamic

cd /app/hostap/wpa_supplicant/
make clean
cp defconfig_base .config
sed -i 's/CONFIG_DRIVER_NL80211=.*/CONFIG_DRIVER_NL80211=y/' .config
sed -i 's/CONFIG_LIBNL32=.*/CONFIG_LIBNL32=y/' .config
make CC=arm-linux-gnueabihf-gcc LDFLAGS+="-static -Wno-as-needed" LIBS="-lpthread -lnl-3 -pthread -lnl-genl-3 -lnl-route-3 -ldbus-1 -lssl -lcrypto -ldl" -j$(nproc --ignore=1)
cp wpa_supplicant /app/bin/arm32/static
cp wpa_cli /app/bin/arm32/static
cp wpa_passphrase /app/bin/arm32/static

tree /app/bin >> /app/bin/README.txt
tar -czvf /app/hostap_bin.tar.gz /app/bin/