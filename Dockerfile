# Build stage
FROM debian:stable-slim AS builder

# Install dependencies
RUN apt-get update && apt-get install -y \
    curl \
    git \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Install MoonBit
RUN curl -fsSL https://cli.moonbitlang.com/install/unix.sh | bash
ENV PATH="/root/.moon/bin:${PATH}"

WORKDIR /app

# Copy project files
COPY . .

# Build the project for native release
RUN moon update && moon build --target native --release

# Find the binary (the path can vary based on module name) and move it to a known location
RUN find _build -name "main.exe" -type f -exec cp {} ./server \;

# Final stage
FROM debian:stable-slim

WORKDIR /app

# Copy the binary from the builder stage
COPY --from=builder /app/server ./server

# Expose port (as specified in main.mbt)
EXPOSE 4000

# Run the server
ENTRYPOINT ["./server"]
