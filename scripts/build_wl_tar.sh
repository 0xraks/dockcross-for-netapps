#!/bin/bash

# Variables
ARCHIVE="server_build"
TEMP_DIR=$(mktemp -d)
CUSTOM_MSG="Add your custom message here"  # You can set this before running the script
JOBS=${BUILD_JOBS:-$(nproc --ignore=1)}  # Number of jobs for parallelization
LOG_FILE="/app/wl_bin/build.log"
README="/app/wl_bin/README.txt"

# Dry run option
if [[ "$1" == "--dry-run" ]]; then
    echo "This is a dry run. Commands that would be executed:"
    set -x  # Enable debug output
fi

# Function to check if required tools are installed
check_dependency() {
    command -v "$1" >/dev/null 2>&1 || { echo >&2 "$1 is required but not installed. Aborting."; exit 1; }
}

# Check for required tools
check_dependency make
check_dependency gcc
check_dependency tar
check_dependency unzip

# Extract the archive
echo "Extracting archive..." | tee -a "$LOG_FILE"
if [[ -f "$ARCHIVE.tgz" ]]; then
    tar -xf "$ARCHIVE.tgz" -C "$TEMP_DIR" || { echo "Extraction failed!"; exit 1; }
elif [[ -f "$ARCHIVE.tar.gz" ]]; then
    tar -xf "$ARCHIVE.tar.gz" -C "$TEMP_DIR" || { echo "Extraction failed!"; exit 1; }
elif [[ -f "$ARCHIVE.zip" ]]; then
    unzip "$ARCHIVE.zip" -d "$TEMP_DIR" || { echo "Extraction failed!"; exit 1; }
else
    echo "Unsupported archive format!" | tee -a "$LOG_FILE"
    exit 1
fi

# Find and edit the makefile
MAKEFILE=$(find "$TEMP_DIR" -name "linux_external.mk")
if [[ -z "$MAKEFILE" ]]; then
    echo "Makefile 'linux_external.mk' not found!" | tee -a "$LOG_FILE"
    exit 1
fi

echo "Modifying Makefile..." | tee -a "$LOG_FILE"
sed -i 's/\$(CC) \$(LDFLAGS) \$(LIBS) -o \$@ \$^/$(strip \$(CC) -o \$@ \$^ \$(LDFLAGS) \$(LIBS))/g' "$MAKEFILE" || exit 1

# Setup output directories
mkdir -p -v /app/wl_bin/fmac /app/wl_bin/dhd

# Create README and add custom message
echo "$CUSTOM_MSG" > "$README"
echo -e "\n### File Details:" >> "$README"

# Change to the directory containing the makefile
cd "$(dirname "$MAKEFILE")" || exit 1

# Function to build for an architecture
build_arch() {
    ARCH="$1"
    CC="$2"
    BIN_PATH="$3"
    NL80211_FLAG="$4"
    LDFLAGS="$5"

    echo "Building for $ARCH..." | tee -a "$LOG_FILE"
    make clean -f "$MAKEFILE" -j$JOBS >> "$LOG_FILE" 2>&1 || { echo "Make clean failed for $ARCH"; exit 1; }
    rm -rf wl_tool* >> "$LOG_FILE" 2>&1

    make CC="$CC" -f "$MAKEFILE" $NL80211_FLAG -j$JOBS LDFLAGS+="$LDFLAGS" >> "$LOG_FILE" 2>&1 || { echo "Build failed for $ARCH"; exit 1; }
    mv wl_tool* "$BIN_PATH" >> "$LOG_FILE" 2>&1
}

# Build for different architectures
build_arch "x86" "gcc" "/app/wl_bin/dhd/wl_tool_x86" "" "-Wl,--no-as-needed"
build_arch "x86 NL80211" "gcc" "/app/wl_bin/fmac/wl_tool_x86" "NL80211=1" "-Wl,--no-as-needed"

#======================== ARM64=============================
export PKG_CONFIG_PATH=/usr/aarch64-linux-gnu/lib/pkgconfig/
export LD_LIBRARY_PATH=/usr/aarch64-linux-gnu/lib/

build_arch "arm64" "aarch64-linux-gnu-gcc" "/app/wl_bin/dhd/wl_tool_arm64" "" "-Wl,--no-as-needed"
build_arch "arm64s" "aarch64-linux-gnu-gcc" "/app/wl_bin/dhd/wl_tool_arm64s" "" "-static -pthread"
build_arch "arm64 NL80211" "aarch64-linux-gnu-gcc" "/app/wl_bin/fmac/wl_tool_arm64" "NL80211=1" "-Wl,--no-as-needed"
build_arch "arm64s NL80211" "aarch64-linux-gnu-gcc" "/app/wl_bin/fmac/wl_tool_arm64s" "NL80211=1" "-static -pthread"

#======================== ARM32=============================
export PKG_CONFIG_PATH=/usr/arm-linux-gnueabihf/lib/pkgconfig/
export LD_LIBRARY_PATH=/usr/arm-linux-gnueabihf/lib/

build_arch "arm32" "arm-linux-gnueabihf-gcc" "/app/wl_bin/dhd/wl_tool_arm32" "" "-Wl,--no-as-needed"
build_arch "arm32s" "arm-linux-gnueabihf-gcc" "/app/wl_bin/dhd/wl_tool_arm32s" "" "-static -pthread"
build_arch "arm32 NL80211" "arm-linux-gnueabihf-gcc" "/app/wl_bin/fmac/wl_tool_arm32" "NL80211=1" "-Wl,--no-as-needed"
build_arch "arm32s NL80211" "arm-linux-gnueabihf-gcc" "/app/wl_bin/fmac/wl_tool_arm32s" "NL80211=1" "-static -pthread"

# Append the directory structure to README
echo -e "\n### Directory Structure:" >> "$README"
tree /app/wl_bin >> "$README"

echo "File command output:" > /app/wl_bin/README.txt
for binary in /app/wl_bin/dhd/* /app/wl_bin/fmac/*; do
    if [[ -f "$binary" ]]; then
        echo "=== $binary ===" >> /app/wl_bin/README.txt
        file "$binary" >> /app/wl_bin/README.txt
        echo "" >> /app/wl_bin/README.txt
    fi
done



# Create a temporary copy of the build.log
cp /app/wl_bin/build.log /app/wl_bin/build.log.tmp

# Compress the output and include README and logs
echo "Creating output archive..." | tee -a "$LOG_FILE"
tar_output=$(tar -czvf /app/wl_bin.tar.gz /app/wl_bin/README.txt /app/wl_bin/build.log.tmp /app/wl_bin/ 2>&1)

# Capture the exit status of the tar command
TAR_EXIT_STATUS=$?

# Print tar output for debugging
echo "$tar_output" | tee -a "$LOG_FILE"

# Check if the tar command was successful
if [ $TAR_EXIT_STATUS -eq 0 ]; then
    echo "Compression successful!" | tee -a "$LOG_FILE"
else
    echo "Compression failed with exit status $TAR_EXIT_STATUS" | tee -a "$LOG_FILE"
    exit 1
fi

# Clean up the temporary log file
rm -f /app/wl_bin/build.log.tmp


# Clean up
rm -rf "$TEMP_DIR"
echo "Build completed successfully!" | tee -a "$LOG_FILE"