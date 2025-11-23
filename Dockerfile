# Dockerfile for n8n SDLC Integration
# Customized n8n image with SDLC integration workflows, scripts, and templates

FROM n8nio/n8n:latest

# Set working directory
WORKDIR /home/node

# Install additional tools needed for SDLC integration
USER root

# Install git, curl, and other utilities needed for scripts
RUN apk add --no-cache \
    git \
    curl \
    wget \
    bash \
    && rm -rf /var/cache/apk/*

# Switch back to node user
USER node

# Create directories for SDLC integration files
RUN mkdir -p /home/node/.n8n/sdlc-integration \
    /home/node/.n8n/workflows \
    /home/node/.n8n/scripts \
    /home/node/.n8n/templates

# Copy workflows directory
COPY --chown=node:node workflows/ /home/node/.n8n/workflows/

# Copy helper scripts
COPY --chown=node:node scripts/ /home/node/.n8n/scripts/

# Copy templates
COPY --chown=node:node templates/ /home/node/.n8n/templates/

# Copy documentation (optional - for reference)
COPY --chown=node:node docs/ /home/node/.n8n/docs/ 2>/dev/null || true
COPY --chown=node:node README.md /home/node/.n8n/README.md 2>/dev/null || true

# Make scripts executable
RUN chmod +x /home/node/.n8n/scripts/*.js 2>/dev/null || true

# Set environment variables for SDLC integration
ENV N8N_CUSTOM_EXTENSIONS=/home/node/.n8n/custom
ENV N8N_USER_FOLDER=/home/node/.n8n

# Create initialization script that can be used to set up workflows
RUN echo '#!/bin/sh\n\
# SDLC Integration Setup Script\n\
echo "n8n SDLC Integration - Custom Image"\n\
echo "Workflows available at: /home/node/.n8n/workflows/"\n\
echo "Scripts available at: /home/node/.n8n/scripts/"\n\
echo "Templates available at: /home/node/.n8n/templates/"\n\
' > /home/node/.n8n/setup-info.sh && \
    chmod +x /home/node/.n8n/setup-info.sh

# Expose n8n port
EXPOSE 5678

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=3 \
    CMD wget --quiet --tries=1 --spider http://localhost:5678/healthz || exit 1

# Use the default n8n entrypoint (from base image)
# The official n8n image handles the startup automatically
