#!/bin/bash

TARGET_ORG="KlausSelfDevOrg"

echo "=========================================================="
echo "Starting phased deployment to $TARGET_ORG"
echo "Note: Deploying from Sandbox to Dev Edition WILL have errors."
echo "This script attempts to deploy in a logical order to minimize them."
echo "=========================================================="

# Helper function to deploy specific metadata types
deploy_metadata() {
    local types=$1
    local phase_name=$2
    
    echo ""
    echo "----------------------------------------------------------"
    echo "Deploying Phase: $phase_name ($types)"
    echo "----------------------------------------------------------"
    
    # We use --ignore-errors here because it's guaranteed some things will fail
    # (e.g., fields referencing missing features). We want the rest to succeed.
    sf project deploy start \
        --target-org "$TARGET_ORG" \
        --metadata $types \
        --ignore-errors \
        --wait 30
}

# Phase 1: Foundation (Objects, Fields, Global Value Sets)
# We need the schema in place first.
deploy_metadata "CustomObject GlobalValueSet StandardValueSet" "Foundation Schema (Objects & Value Sets)"

# Phase 2: Logic (Apex classes, Triggers)
# Apex code needs the objects/fields to exist to compile successfully.
deploy_metadata "ApexClass ApexTrigger" "Backend Logic (Apex)"

# Phase 3: Frontend UI Components
# LWC and Aura components.
deploy_metadata "LightningComponentBundle AuraDefinitionBundle" "Frontend Components (LWC/Aura)"

# Phase 4: Automation & UI Configuration
# Flows, Layouts, Flexipages, Custom Tabs, Apps.
deploy_metadata "Flow Layout FlexiPage CustomTab CustomApplication" "Automation & UI Config (Flows, Layouts)"

# Phase 5: Security & Sharing (Optional, usually throws the most errors)
# Profiles and Permission Sets are highly dependent on the org's features/licenses.
deploy_metadata "PermissionSet Profile SharingRules" "Security & Sharing (Profiles, Perm Sets)"

echo ""
echo "=========================================================="
echo "Phased deployment completed."
echo "Please review the output above for any deployment errors."
echo "You will likely need to manually fix errors caused by missing features"
echo "in your Developer Edition org."
echo "=========================================================="
