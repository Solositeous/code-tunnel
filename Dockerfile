# Web development environment with VS Code tunnel
FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# Install basic dependencies
RUN apt-get update && apt-get install -y \
    curl \
    wget \
    git \
    ca-certificates \
    sudo \
    bash \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Install Node.js LTS (via NodeSource)
RUN curl -fsSL https://deb.nodesource.com/setup_lts.x | bash - \
    && apt-get install -y nodejs \
    && rm -rf /var/lib/apt/lists/*

# Install common web dev tools globally
RUN npm install -g \
    yarn \
    pnpm \
    typescript \
    ts-node \
    nodemon \
    prettier \
    eslint

# Download and install VS Code CLI
RUN curl -Lk 'https://code.visualstudio.com/sha/download?build=stable&os=cli-alpine-x64' --output /tmp/vscode-cli.tar.gz \
    && tar -xf /tmp/vscode-cli.tar.gz -C /usr/local/bin \
    && rm /tmp/vscode-cli.tar.gz \
    && chmod +x /usr/local/bin/code

WORKDIR /root

# Environment variables
ENV TUNNEL_NAME=""
ENV GITHUB_TOKEN=""

# Create a default workspace directory
RUN mkdir -p /root/workspace

COPY entrypoint.sh /root/entrypoint.sh
RUN chmod +x /root/entrypoint.sh

ENTRYPOINT ["/root/entrypoint.sh"]
