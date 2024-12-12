#!/bin/bash

fastqc_version=0.12.1
multiqc_version=1.25.2

################################################################################
# Report errors and exit if detected
trap 'echo "Error on line $LINENO: $BASH_COMMAND"; exit 1' ERR
set -e


if [ -f ~/miniforge3/etc/profile.d/conda.sh ]; then
    source ~/miniforge3/etc/profile.d/conda.sh
    conda activate base
    echo "Conda environment: $(conda info --envs | grep '*' | awk '{print $1}')"
fi

iso_datetime=$(date +"%Y-%m-%dT%H:%M:%S%z")


# Detect the semantic release version number
cd $(git rev-parse --show-toplevel)
semvar_version=$(semantic-release version --print 2>/dev/null)

# We may read the "image_version.txt" if we cannot get a semantic release version
version_file="image_version.txt"

if git rev-parse --git-dir > /dev/null 2>&1; then
    echo "Semantic Release Auto Version: '$semvar_version'"

    if [ -n "$semvar_version" ]; then
        set_version="v$semvar_version"
        echo "$set_version" > "$version_file"

    else
        if [ -f "$version_file" ]; then
            set_version=$(<"$version_file" tr -d '[:space:]')
        else
            echo "Warning: $version_file not found. Using 'dev' as default."
            set_version="dev"
        fi
    fi
else
    echo "Not a Git repository. Using $version_file or 'dev' as default."
    if [ -f "$version_file" ]; then
        set_version=$(<"$version_file" tr -d '[:space:]')
    else
        echo "Warning: $version_file not found. Using 'dev' as default."
        set_version="dev"
    fi
fi


# Function to send notification
send_notification() {
    local message="$1"
    curl -u ":$NTFY_DRPM_TOKEN" \
    -H "Markdown: yes" \
    -H "Genomics Studio: Build" \
    -d "$message" \
    https://ntfy.drpranavmishra.com/faxlab-build || echo "Error occurred while sending ntfy message. Continuing execution..."
}

# send_notification "Multi-FastQC: Build process started"




echo "Image version: $set_version"

# Write the chosen version number to the version file
echo "$set_version" >"$version_file"

# Write these values to the env file
echo "ISO_DATETIME=$iso_datetime" > .env
echo "IMAGE_VERSION=$set_version" >> .env

wget -nc https://www.bioinformatics.babraham.ac.uk/projects/fastqc/fastqc_v0.12.1.zip


# Build the container

export DOCKER_BUILDKIT=1 # use docker buildx caching
export BUILDX_METADATA_PROVENANCE=max

docker build \
  --build-arg IMAGE_VERSION=${set_version} \
  --build-arg FASTQC_VERSION=${fastqc_version} \
  --build-arg MULTIQC_VERSION=${multiqc_version} \
  --build-arg ISO_DATETIME=${iso_datetime} \
  -t pranavmishra90/multi-fastqc:${set_version} \
  -t pranavmishra90/multi-fastqc:latest .

# docker push --all pranavmishra90/multi-fastqc


send_notification "Multi-FastQC: Build process completed"