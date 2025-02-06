#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Base directory for security rules
RULES_DIR="Firebase/SecurityRules"

# Check if Firebase CLI is installed
if ! command -v firebase &> /dev/null; then
    echo -e "${RED}Firebase CLI is not installed. Please install it first:${NC}"
    echo "npm install -g firebase-tools"
    exit 1
fi

# Check if user is logged in to Firebase
if ! firebase projects:list &> /dev/null; then
    echo -e "${RED}You are not logged in to Firebase. Please login first:${NC}"
    echo "firebase login"
    exit 1
fi

# Function to deploy rules
deploy_rules() {
    local rule_type=$1
    local file_path=$2
    
    echo -e "${YELLOW}Deploying $rule_type rules...${NC}"
    
    # Check if rules file exists
    if [ ! -f "$file_path" ]; then
        echo -e "${RED}Error: $file_path not found${NC}"
        return 1
    }
    
    # Deploy rules
    if firebase deploy --only "$rule_type" --rules "$file_path"; then
        echo -e "${GREEN}Successfully deployed $rule_type rules${NC}"
        return 0
    else
        echo -e "${RED}Failed to deploy $rule_type rules${NC}"
        return 1
    fi
}

# Deploy Firestore rules
deploy_rules "firestore" "$RULES_DIR/firestore.rules"
FIRESTORE_RESULT=$?

# Deploy Storage rules
deploy_rules "storage" "$RULES_DIR/storage.rules"
STORAGE_RESULT=$?

# Check if both deployments were successful
if [ $FIRESTORE_RESULT -eq 0 ] && [ $STORAGE_RESULT -eq 0 ]; then
    echo -e "\n${GREEN}All security rules deployed successfully!${NC}"
    exit 0
else
    echo -e "\n${RED}Some deployments failed. Please check the errors above.${NC}"
    exit 1
fi 