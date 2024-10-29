#!/usr/bin/env bash
###
# File: entrypoint.sh
# Project: overlay
# File Created: Friday, 18th October 2024 5:05:51 pm
# Author: Josh5 (jsunnex@gmail.com)
# -----
# Last Modified: Tuesday, 29th October 2024 5:38:57 pm
# Modified By: Josh5 (jsunnex@gmail.com)
###
set -eu

################################################
# --- Create Logging Function
#
print_log() {
    timestamp=$(date +'%Y/%m/%d %H:%M:%S')
    level="$1"
    shift
    message="$*"
    echo "[${timestamp}] [ ${level}] ${message}"
}

# PEM_FILE="/fluentd-data/certs/fluent.${CONFIG_VERSION}.pem"

# TODO: Wait for GLEF to be available
print_log "info" "Waiting for GrayLog to be available..."
# read -t 5 < /dev/zero
# i=1
# while [ $i -le 60 ]; do
#     if [ -f "${PEM_FILE:?}" ]; then
#         echo "  - The Certificates are avaiable"
#         break
#     fi
#     echo "  - Certificate config container check #$i - Certificates not yet created. Recheck in 10 seconds..."
#     read -t 10 < /dev/zero
#     i=$((i + 1))
# done
# echo

if [[ -z "${ENABLE_S3_BUCKET_COLD_STORAGE_OUTPUT:-}" || "${ENABLE_S3_BUCKET_COLD_STORAGE_OUTPUT,,}" =~ ^(false|f|0|1)$ ]]; then
    print_log "info" "Leaving S3 Bucket cold storage output disabled"
else
    print_log "info" "Adding S3 Bucket cold storage output"
    cat <<EOF >/etc/fluent-bit/fluent-bit.s3-cold-storage.output.yaml
pipeline:
  outputs:
    # S3 Bucket cold storage output
    - name: s3
      match_regex:                  ^flb_glf(?!.*cld_st).*
      bucket                        ${AWS_COLD_STORAGE_BUCKET_NAME:?}
      region                        ${AWS_COLD_STORAGE_BUCKET_REGION:?}
      total_file_size               10M
      s3_key_format                 /$TAG/%Y/%m/%d/%H_%M_%S-$UUID.txt.gz
      use_put_object                On
      compression                   gzip
      store_dir                     ${FLUENT_STORAGE_PATH:?}/s3_buffer
      upload_timeout                10m
      retry_limit                   5
EOF
fi

if [[ -z "${ENABLE_GRAYLOG_GELF_OUTPUT:-}" || "${ENABLE_GRAYLOG_GELF_OUTPUT,,}" =~ ^(false|f|0|1)$ ]]; then
    print_log "info" "Leaving Graylog GELF output disabled"
else
    print_log "info" "Adding Graylog GELF output"
    cat <<EOF >/etc/fluent-bit/fluent-bit.graylog-gelf.output.yaml
pipeline:
  outputs:
    # Graylog GELF output
    - name: gelf
      match: flb_glf.*
      host: graylog
      port: 12201
      mode: udp
      compress: true
      gelf_timestamp_key: timestamp
      gelf_short_message_key: message
      gelf_full_message_key: message
      gelf_host_key: source
      retry_limit: 6
EOF
fi

mkdir -p "${FLUENT_STORAGE_PATH:?}"

print_log "info" "Starting Fluent-Bit"
exec /opt/fluent-bit/bin/fluent-bit -c /etc/fluent-bit/fluent-bit.yaml
