FROM node:20

# Basic dev tools
RUN apt-get update && apt-get install -y --no-install-recommends \
  git curl ca-certificates unzip jq vim nano less procps sudo \
  && rm -rf /var/lib/apt/lists/*

# Create dirs and set ownership (as root)
RUN mkdir -p /workspace /home/node/.claude /home/node/.local/bin /home/node/.local/share \
  && chown -R node:node /workspace /home/node

WORKDIR /workspace

# Switch to node user and install Claude Code via native installer
USER node
RUN curl -fsSL https://claude.ai/install.sh | bash

# Add native install location to PATH
ENV PATH="/home/node/.local/bin:$PATH"

# Keep the container alive — exec into it to use Claude Code
CMD ["sleep", "infinity"]
