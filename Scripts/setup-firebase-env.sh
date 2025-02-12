#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Base directories
APP_DIR="App/reelai/reelai"
CONFIG_DIR="$APP_DIR/Config"

# Configuration files
ENV_TEMPLATE="$CONFIG_DIR/Environment.xcconfig.template"
DEV_TEMPLATE="$CONFIG_DIR/Development.xcconfig.template"
PROD_TEMPLATE="$CONFIG_DIR/Production.xcconfig.template"
INFO_TEMPLATE="$APP_DIR/Info.plist.template"

ENV_CONFIG="$CONFIG_DIR/Environment.xcconfig"
DEV_CONFIG="$CONFIG_DIR/Development.xcconfig"
PROD_CONFIG="$CONFIG_DIR/Production.xcconfig"
INFO_PLIST="$APP_DIR/Info.plist"

# Function to copy template if config doesn't exist
setup_config() {
    local template=$1
    local config=$2
    local name=$3

    if [ ! -f "$config" ]; then
        echo -e "${YELLOW}Setting up $name configuration...${NC}"
        cp "$template" "$config"
        echo -e "${GREEN}Created $name configuration file at: $config${NC}"
        echo -e "${YELLOW}Please update $config with your actual values${NC}"
    else
        echo -e "${GREEN}$name configuration already exists at: $config${NC}"
    fi
}

# Create Config directory if it doesn't exist
mkdir -p "$CONFIG_DIR"

# Setup configuration files
setup_config "$ENV_TEMPLATE" "$ENV_CONFIG" "Environment"
setup_config "$DEV_TEMPLATE" "$DEV_CONFIG" "Development"
setup_config "$PROD_TEMPLATE" "$PROD_CONFIG" "Production"
setup_config "$INFO_TEMPLATE" "$INFO_PLIST" "Info.plist"

echo -e "\n${GREEN}Configuration setup complete!${NC}"
echo -e "${YELLOW}Next steps:${NC}"
echo "1. Update the configuration files with your actual Firebase values"
echo "2. Open Xcode and update your project settings:"
echo "   - Select your project in the navigator"
echo "   - Select your target"
echo "   - Go to the 'Build Settings' tab"
echo "   - Set 'Development.xcconfig' for Debug configuration"
echo "   - Set 'Production.xcconfig' for Release configuration"
echo -e "\n${RED}Security Reminder:${NC}"
echo "- Never commit the actual configuration files to version control"
echo "- Keep your API keys and credentials secure"
echo "- Use Firebase Emulator for local development" 