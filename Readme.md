# Cross-Build Docker Image

This Docker image is designed for cross-compilation, targeting both ARM32 (armv4) and ARM64 architectures. It includes necessary dependencies and tools for building networking realted  projects that require cross-compilation.

## Usage

### Build the Docker Image

```bash
DOCKER_BUILDKIT=0 docker build -t cross-build .
```

## Run the Docker Container
```bash
docker run -v /path/to/your/source/code:/app -it rakss/cross-build bash
```

## Activate ARM64 Environment
```bash
activate_arm64
```
This alias sets the necessary environment variables for ARM64 cross-compilation.

## Activate ARM32 Environment
```bash
activate_arm32
```
This alias sets the necessary environment variables for ARM32 cross-compilation.

Use the provided build scripts or execute your own build commands within the container.
