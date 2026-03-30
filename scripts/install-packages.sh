#!/bin/bash

TARGET_ORG="KlausSelfDevOrg"

# The list of package version IDs (04t...) from the sandbox
declare -a packages=(
    "04t0I000000f7TsQAI" # Common LookUp Component
    "04t1a000000AWcDAAW" # SalesforceIQ Inbox
    "04t30000001DUvrAAG" # Salesforce Connected Apps
    "04t4V000001i8c0QAA" # Salesforce Mobile Apps
    "04t40000000U78PAAS" # SalesforceA Connected Apps
    "04t50000000EcdrAAC" # Salesforce.com CRM Dashboards
    "04t58000000SGw3AAG" # Sales Insights
    "04tKe0000011MxJIAU" # Salesforce Standard Data Model (ssot)
    "04t5f000000ZYmTAAW" # Video Viewer
    "04t700000007ySvAAI" # TimbaSurveys
    "04tRQ0000007FojYAE" # Cuneiform for Salesforce (pnova)
    "04tB0000000BYKvIAO" # Sales Cloud (cdp_crm_dk1)
    "04tEE0000005cB7YAI" # Salesforce Data Cloud - Flow Integration
    "04tKh000002NIDlIAO" # Rollup Helper (rh2)
    "04tJ3000000LP1xIAG" # SFDC File Manager (FileX)
    "04tKA000000PbyMYAS" # Plauti Deduplicate (dupcheck)
)

echo "=========================================================="
echo "Starting batch package installation to $TARGET_ORG"
echo "Note: Packages requiring premium licenses (like Data Cloud)"
echo "will inevitably fail to install in a Developer Edition Org."
echo "=========================================================="

for pkg in "${packages[@]}"; do
    # Extract the ID and the comment for display
    pkg_id=$(echo $pkg | awk '{print $1}')
    pkg_name=$(echo $pkg | cut -d'#' -f2)
    
    echo ""
    echo "----------------------------------------------------------"
    echo "Installing: $pkg_name ($pkg_id)"
    echo "----------------------------------------------------------"
    
    sf package install \
        --target-org "$TARGET_ORG" \
        --package "$pkg_id" \
        --wait 15 \
        --no-prompt

    if [ $? -ne 0 ]; then
         echo "⚠️ Failed to install $pkg_name. This is usually due to missing licenses/features in Dev Edition."
    else
         echo "✅ Successfully installed $pkg_name!"
    fi
done

echo ""
echo "=========================================================="
echo "Batch installation attempt finished."
echo "=========================================================="
