#!/bin/bash
#======================== X86============================
mkdir -p -v /app/wl_bin/fmac /app/wl_bin/dhd
cd /app/WL_TOOL/src/
make clean -f linux_external.mk -j$(nproc --ignore=1)
rm -rf wl_tool*
make -f linux_external.mk -j$(nproc --ignore=1) LDFLAGS+="-Wl,--no-as-needed"
mv wl_tool /app/wl_bin/dhd/wl_tool_x86

make clean -f linux_external.mk -j$(nproc --ignore=1)
rm -rf wl_tool*
make -f linux_external.mk NL80211=1 -j$(nproc --ignore=1) LDFLAGS+="-Wl,--no-as-needed"
mv wl_tool /app/wl_bin/fmac/wl_tool_x86

#======================== ARM64============================
export PKG_CONFIG_PATH=/usr/aarch64-linux-gnu/lib/pkgconfig/ && export LD_LIBRARY_PATH=/usr/aarch64-linux-gnu/lib/
make clean -f linux_external.mk -j$(nproc --ignore=1)
rm -rf wl_tool*
make  CC=aarch64-linux-gnu-gcc -f linux_external.mk -j$(nproc --ignore=1) LDFLAGS+="-Wl,--no-as-needed"
mv wl_tool /app/wl_bin/dhd/wl_tool_arm64

make clean -f linux_external.mk -j$(nproc --ignore=1)
rm -rf wl_tool*
make -f linux_external.mk NL80211=1 -j$(nproc --ignore=1) LDFLAGS+="-Wl,--no-as-needed"
mv wl_tool /app/wl_bin/dhd/wl_tool_arm64s

make clean -f linux_external.mk -j$(nproc --ignore=1)
rm -rf wl_tool*
make  CC=aarch64-linux-gnu-gcc -f linux_external.mk NL80211=1 -j$(nproc --ignore=1) LDFLAGS+="-Wl,--no-as-needed"
mv wl_tool_NL80211 /app/wl_bin/fmac/wl_tool_arm64

make clean -f linux_external.mk -j$(nproc --ignore=1)
rm -rf wl_tool*
make  CC=aarch64-linux-gnu-gcc -f linux_external.mk NL80211=1 LDFLAGS+="-static -pthread" -j$(nproc --ignore=1) LDFLAGS+="-Wl,--no-as-needed"
mv wl_tool_NL80211 /app/wl_bin/fmac/wl_tool_arm64s


#======================== ARM32============================
export PKG_CONFIG_PATH=/usr/arm-linux-gnueabihf/lib/pkgconfig/ && export LD_LIBRARY_PATH=/usr/arm-linux-gnueabihf/lib/
make clean -f linux_external.mk -j$(nproc --ignore=1)
rm -rf wl_tool*
make  CC=arm-linux-gnueabihf-gcc -f linux_external.mk -j$(nproc --ignore=1) LDFLAGS+="-Wl,--no-as-needed"
mv wl_tool /app/wl_bin/dhd/wl_tool_arm32

make clean -f linux_external.mk -j$(nproc --ignore=1)
rm -rf wl_tool*
make  CC=arm-linux-gnueabihf-gcc -f linux_external.mk LDFLAGS+="-static -pthread" -j$(nproc --ignore=1) LDFLAGS+="-Wl,--no-as-needed"
mv wl_tool /app/wl_bin/dhd/wl_tool_arm32s

make clean -f linux_external.mk -j$(nproc --ignore=1)
rm -rf wl_tool*
make  CC=arm-linux-gnueabihf-gcc -f linux_external.mk NL80211=1 -j$(nproc --ignore=1) LDFLAGS+="-Wl,--no-as-needed"
mv wl_tool_NL80211 /app/wl_bin/fmac/wl_tool_arm32

make clean -f linux_external.mk -j$(nproc --ignore=1)
rm -rf wl_tool*
make  CC=arm-linux-gnueabihf-gcc -f linux_external.mk NL80211=1 LDFLAGS+="-static -pthread" -j$(nproc --ignore=1) LDFLAGS+="-Wl,--no-as-needed"
mv wl_tool_NL80211 /app/wl_bin/fmac/wl_tool_arm32s

tree /app/wl_bin >> /app/wl_bin/README.txt
tar -czvf /app/wl_bin.tar.gz /app/wl_bin/