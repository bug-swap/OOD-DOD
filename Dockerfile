# Use Ubuntu as base image with development tools
FROM ubuntu:22.04

# Avoid interactive prompts during build
ENV DEBIAN_FRONTEND=noninteractive

# Install build tools and profiling utilities
RUN apt-get update && apt-get install -y \
    build-essential \
    g++ \
    make \
    time \
    valgrind \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Copy source files
COPY particle_ood.cpp particle_dod.cpp ./

# Build the programs
RUN g++ -std=c++17 -O3 -Wall -o particle_ood particle_ood.cpp && \
    g++ -std=c++17 -O3 -Wall -o particle_dod particle_dod.cpp

# Default command: run the comparison
CMD ["/bin/bash", "-c", "echo '==========================================' && echo 'Running OOD Implementation...' && echo '==========================================' && ./particle_ood && echo '' && echo '==========================================' && echo 'Running DOD Implementation...' && echo '==========================================' && ./particle_dod"]
