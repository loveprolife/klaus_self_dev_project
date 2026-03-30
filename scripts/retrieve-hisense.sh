#!/bin/bash
# Retrieve all metadata from hisenseintTestuatSandboxLightning in batches
# Each batch is under 5000 members to avoid the 10000 file limit

TARGET_ORG="hisenseintTestuatSandboxLightning"

for i in 1 2 3; do
    MANIFEST="manifest/hisense-batch-${i}.xml"
    echo ""
    echo "=========================================="
    echo "  Batch ${i}/3: ${MANIFEST}"
    echo "=========================================="
    echo ""
    
    sf project retrieve start \
        --manifest "${MANIFEST}" \
        --target-org "${TARGET_ORG}"
    
    if [ $? -ne 0 ]; then
        echo "❌ Batch ${i} failed!"
        echo "You can retry from this batch by running:"
        echo "  sf project retrieve start --manifest ${MANIFEST} --target-org ${TARGET_ORG}"
        exit 1
    fi
    
    echo "✅ Batch ${i} completed successfully!"
done

echo ""
echo "=========================================="
echo "  All 3 batches completed! 🎉"
echo "=========================================="
