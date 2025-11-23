# VS Code Remote Tunnel Docker Containers

Run VS Code remote tunnels in Docker containers with configurable development environments. Choose from different variants optimized for specific development workflows.

## Available Variants

### 1. Base Tunnel (`Dockerfile`)
Minimal installation with just VS Code CLI and basic tools.
- **Use case**: Lightweight remote access, basic editing
- **Includes**: git, curl, wget, bash

### 2. Python Development (`Dockerfile.python`)
Full Python development environment.
- **Use case**: Python projects, data science, scripting
- **Includes**: Python 3, pip, poetry, pipx, build tools

### 3. Web Development (`Dockerfile.web`)
Node.js and modern web development tools.
- **Use case**: JavaScript/TypeScript, React, Next.js, etc.
- **Includes**: Node.js LTS, npm, yarn, pnpm, TypeScript, ESLint, Prettier

## Quick Start

### Option 1: Using Docker Compose (Recommended)

1. **Choose your environment and start it:**

```bash
# Python development
docker-compose --profile python up -d

# Web development
docker-compose --profile web up -d

# Base environment
docker-compose --profile base up -d
```

2. **First time setup - Authenticate:**

```bash
# View logs to get the authentication URL
docker-compose logs -f tunnel-python  # or tunnel-web, tunnel-base
```

Click the URL shown in the logs and follow the GitHub authentication flow.

3. **Access your tunnel:**
   - Open VS Code or visit https://vscode.dev
   - Sign in with the same GitHub account
   - Your tunnel will appear in the Remote Tunnels list

### Option 2: Using Docker Directly

1. **Build the image:**

```bash
# For Python
docker build -f Dockerfile.python -t vscode-tunnel-python .

# For Web
docker build -f Dockerfile.web -t vscode-tunnel-web .

# For Base
docker build -t vscode-tunnel-base .
```

2. **Run the container:**

```bash
docker run -d \
  --name my-tunnel \
  -e TUNNEL_NAME=my-dev-tunnel \
  -v $(pwd)/workspace:/home/vscode/workspace \
  vscode-tunnel-python
```

3. **Authenticate (first time):**

```bash
docker logs -f my-tunnel
```

## Configuration

### Environment Variables

- `TUNNEL_NAME` (required): Unique name for your tunnel
- `GITHUB_TOKEN` (optional): GitHub personal access token for non-interactive auth

### Using GitHub Token for Non-Interactive Auth

1. Create a token at https://github.com/settings/tokens
2. Add to `.env` file (copy from `.env.example`):
```bash
GITHUB_TOKEN=your_token_here
```

3. Update `docker-compose.yml` to uncomment the GITHUB_TOKEN line

### Customizing Tunnel Names

Edit the `TUNNEL_NAME` environment variable in `docker-compose.yml` or pass it via command line:

```bash
docker run -d \
  -e TUNNEL_NAME=my-custom-name \
  vscode-tunnel-python
```

## Creating Custom Variants

You can create your own Dockerfile variants for specific needs:

1. Copy an existing Dockerfile (e.g., `Dockerfile.python`)
2. Modify the package installations
3. Save as `Dockerfile.custom`
4. Add to `docker-compose.yml`:

```yaml
tunnel-custom:
  build:
    context: .
    dockerfile: Dockerfile.custom
  environment:
    - TUNNEL_NAME=my-custom-tunnel
  volumes:
    - custom-workspace:/home/vscode/workspace
    - custom-vscode-server:/home/vscode/.vscode-cli
  profiles:
    - custom
```

### Example: Go Development Variant

```dockerfile
FROM ubuntu:22.04
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    curl wget git ca-certificates sudo bash \
    && rm -rf /var/lib/apt/lists/*

# Install Go
RUN wget https://go.dev/dl/go1.21.5.linux-amd64.tar.gz \
    && tar -C /usr/local -xzf go1.21.5.linux-amd64.tar.gz \
    && rm go1.21.5.linux-amd64.tar.gz

ENV PATH=$PATH:/usr/local/go/bin

# ... rest same as base Dockerfile
```

## Management Commands

```bash
# Start a specific tunnel
docker-compose --profile python up -d

# Stop a tunnel
docker-compose --profile python down

# View logs
docker-compose logs -f tunnel-python

# Rebuild after changes
docker-compose --profile python up -d --build

# Access container shell
docker exec -it vscode-tunnel-python bash

# Remove everything (including volumes)
docker-compose down -v
```

## Volumes

Each tunnel maintains two volumes:
- **workspace**: Your project files (`/home/vscode/workspace`)
- **vscode-server**: VS Code server data and settings (`/home/vscode/.vscode-cli`)

To backup or access your workspace:
```bash
docker run --rm -v code-tunnel_python-workspace:/workspace -v $(pwd):/backup ubuntu tar czf /backup/workspace-backup.tar.gz -C /workspace .
```

## Troubleshooting

### Tunnel won't start
- Check logs: `docker-compose logs tunnel-python`
- Ensure `TUNNEL_NAME` is unique and set
- Verify authentication completed

### Can't find tunnel in VS Code
- Ensure you're signed in with the same GitHub account
- Wait a few seconds for the tunnel to register
- Restart the container: `docker-compose restart tunnel-python`

### Permission issues
- The container runs as user `vscode` (UID 1000)
- Adjust `USER_UID` build arg if needed:
```bash
docker build --build-arg USER_UID=$(id -u) -f Dockerfile.python -t vscode-tunnel-python .
```

## Security Notes

- Tunnels are authenticated via GitHub
- Don't share your `GITHUB_TOKEN` 
- Use unique tunnel names per environment
- Regularly update the base images

## License

MIT
