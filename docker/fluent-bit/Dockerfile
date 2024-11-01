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
    echo "**** install wait-for-it script ****" \
        && curl https://raw.githubusercontent.com/vishnubob/wait-for-it/81b1373f17855a4dc21156cfe1694c31d7d1792e/wait-for-it.sh \
            -o /usr/bin/wait-for-it \
        && chmod +x /usr/bin/wait-for-it \
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
    HOST_HOSTNAME=graylog-fluent-bit \
    FORWARD_SHARED_KEY=1234567890 \
    FLUENT_STORAGE_PATH=/var/fluent-bit/storage \
    ENABLE_FORWARD_TLS=true \
    CERTIFICATES_DIRECTORY=/etc/fluent-bit/certs \
    USE_EXISTING_CERT=false \
    EXISTING_KEY_PATH=/etc/fluent-bit/certs/1.key \
    EXISTING_CERT_PATH=/etc/fluent-bit/certs/1.pem \
    USE_CERTBOT_TO_GENERATE_KEY=false \
    CERT_FQDN=example.com \
    CERT_EMAIL=admin@example.com \
    ENABLE_S3_BUCKET_COLD_STORAGE_OUTPUT=false \
    ENABLE_GRAYLOG_GELF_OUTPUT=true

ENTRYPOINT ["/usr/bin/tini", "--", "/entrypoint.sh"]
CMD []
