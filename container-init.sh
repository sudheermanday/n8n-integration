#!/bin/sh
# Container initialization script for n8n SDLC Integration
# This script runs when the container starts (optional)

echo "=========================================="
echo "n8n SDLC Integration - Container Starting"
echo "=========================================="
echo ""

# Display setup information
if [ -f /home/node/.n8n/setup-info.sh ]; then
    /home/node/.n8n/setup-info.sh
fi

echo ""
echo "Available resources:"
echo "  - Workflows: /home/node/.n8n/workflows/"
echo "  - Scripts: /home/node/.n8n/scripts/"
echo "  - Templates: /home/node/.n8n/templates/"
echo ""

# List available workflows
if [ -d /home/node/.n8n/workflows ] && [ "$(ls -A /home/node/.n8n/workflows)" ]; then
    echo "Available workflow files:"
    ls -1 /home/node/.n8n/workflows/*.json 2>/dev/null | sed 's|.*/||' | sed 's/^/  - /'
    echo ""
fi

# Check if workflows need to be imported
echo "To import workflows:"
echo "  1. Access n8n UI at http://localhost:5678"
echo "  2. Go to Workflows → Import from File"
echo "  3. Import files from /home/node/.n8n/workflows/"
echo ""

echo "Container is ready!"
echo "=========================================="

