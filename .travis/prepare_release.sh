#!/bin/bash

# ----------------------------------------------------------------------
# Push the kabanero operator container to docker hub.
# ----------------------------------------------------------------------
make push-image

# ----------------------------------------------------------------------
# Populate the kabanero operator CSV with "relatedImages" for
# air-gapped installs.
# ----------------------------------------------------------------------
.travis/pre_build_image.sh

# ----------------------------------------------------------------------
# Build the operator registry, using the modified CSV.
# ----------------------------------------------------------------------
make build-registry-image
make push-registry-image

# ----------------------------------------------------------------------
# Prepare the files that will get put into the tagged release
# ----------------------------------------------------------------------
if [ -n "$TRAVIS_TAG" ] ; then
    # Split the REGISTRY_IMAGE variable into repository and tag parts
    # e.g. kabanero/kabanero-operator-registry:0.3.0 -> kabanero/kabanero-operator-registry
    IFS=’:’ read -ra REPOSITORY <<< "$REGISTRY_IMAGE"

    # Set the tag for the kabanero CatalogSource
    REGISTRY_IMAGE_REPO_DIGEST=$(docker image inspect kabanero/kabanero-operator-registry:$TRAVIS_TAG --format="{{index .RepoDigests 0}}")
    sed -i.bak -e 's,kabanero/kabanero-operator-registry:.*,'$REGISTRY_IMAGE_REPO_DIGEST',' deploy/kabanero-subscriptions.yaml

    # Set the tag for the install script
    sed -i.bak -e 's/RELEASE=.*/RELEASE="${RELEASE:-'$TRAVIS_TAG'}"/' deploy/install.sh

    # Set the tag for the uninstall script
    sed -i.bak -e 's/RELEASE=.*/RELEASE="${RELEASE:-'$TRAVIS_TAG'}"/' deploy/uninstall.sh

    # Set the tag for the full.yaml
    sed -i.bak -e 's/TRAVIS_TAG/'$TRAVIS_TAG'/' config/samples/full.yaml
fi
