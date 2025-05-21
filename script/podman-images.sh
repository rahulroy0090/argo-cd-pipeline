#!/bin/bash

# Prompt user for image name (e.g. quarkus_mta_cbs_validatecharge)
read -p "Enter image name: " IMAGE_NAME

# Prompt user for image tag (e.g. 20241221155341)
read -p "Enter image tag: " IMAGE_TAG

# Define source and target registries
SOURCE_REGISTRY="nexus.uat.finopaymentbank.in:9443/repository/esb_uat_dev"
TARGET_REGISTRY="registry.preprod.finopaymentbank.in/p2mpay"

# Determine target image name
if [[ "$IMAGE_NAME" == quarkus_* ]]; then
    # Remove 'quarkus_' prefix and replace all underscores with hyphens
    MODIFIED_NAME="${IMAGE_NAME#quarkus_}"
    TARGET_IMAGE_NAME="${MODIFIED_NAME//_/-}"
else
    TARGET_IMAGE_NAME="$IMAGE_NAME"
fi

# Full image names
SOURCE_IMAGE="$SOURCE_REGISTRY/$IMAGE_NAME:$IMAGE_TAG"
TARGET_IMAGE="$TARGET_REGISTRY/$TARGET_IMAGE_NAME:$IMAGE_TAG"

# Pull the source image (disable TLS verification)
echo "👉 Pulling image: $SOURCE_IMAGE"
podman pull --tls-verify=false "$SOURCE_IMAGE" || { echo "❌ Failed to pull $SOURCE_IMAGE"; exit 1; }

# Tag the image with the new target name
echo "🔖 Tagging image as: $TARGET_IMAGE"
podman tag "$SOURCE_IMAGE" "$TARGET_IMAGE"

# Push the image to target registry (disable TLS verification)
echo "🚀 Pushing image: $TARGET_IMAGE"
podman push --tls-verify=false "$TARGET_IMAGE" || { echo "❌ Failed to push $TARGET_IMAGE"; exit 1; }

# Done
echo "✅ Image successfully pushed to $TARGET_IMAGE"
