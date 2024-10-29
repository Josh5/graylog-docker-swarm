FROM ubuntu:latest

RUN \
    echo "**** update apt repositories ****" \
        && apt-get update \
    && \
    echo "**** install container runtime packages ****" \
        && apt-get install -y --no-install-recommends \
            bash \
            ca-certificates \
            certbot \
            curl \
            gnupg \
            tini \
    && \
    echo "**** install Fluent-bit ****" \
        && curl https://raw.githubusercontent.com/fluent/fluent-bit/master/install.sh \
            -o /tmp/install.sh \
        && chmod +x /tmp/install.sh \
        && /tmp/install.sh \
        && rm -f /tmp/install.sh \
    && \
    echo "**** install lua dependencies ****" \
        && apt-get install -y --no-install-recommends \
            lua-cjson \
    && \
    echo "**** cleanup apt cache ****" \
        && apt-get clean \
        && rm -rf /var/lib/apt/lists/* \
    && \
    echo

# Modify the Lua lib paths or Fluent-bit will not be able to import it
ENV \
    LUA_PATH="/usr/share/lua/5.1/?.lua;;" \
    LUA_CPATH="/usr/lib/x86_64-linux-gnu/lua/5.1/?.so;;"

COPY overlay/ /

ENV \
    FORWARD_SHARED_KEY=1234567890 \
    FLUENT_STORAGE_PATH=/var/fluent-bit/storage \
    CERTIFICATE_KEY_FILE_PATH=/etc/fluent-bit/certs/fluent-bit.key \
    CERTIFICATE_FILE_PATH=/etc/fluent-bit/certs/fluent-bit.pem \
    ENABLE_FORWARD_TLS=true \
    ENABLE_S3_BUCKET_COLD_STORAGE_OUTPUT=false \
    ENABLE_GRAYLOG_GELF_OUTPUT=true

ENTRYPOINT ["/entrypoint.sh"]
CMD []
