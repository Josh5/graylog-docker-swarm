FROM library/fluentd:latest

LABEL maintainer="Josh.5 <jsunnex@gmail.com>"

USER root

RUN \
    echo "**** Install entrypoint dependencies ****" \
        && apk add --no-cache \
            bash \
            certbot \
            wget \
    && \
    echo "**** Install out_gelf plugin ****" \
        && wget -q "https://raw.githubusercontent.com/emsearcy/fluent-plugin-gelf/master/lib/fluent/plugin/out_gelf.rb" \
            -O "/fluentd/plugins/out_gelf.rb" \
        && fluent-gem install gelf  \
    && \
    echo "**** Install fluent-plugin-s3 plugin ****" \
        && fluent-gem install fluent-plugin-s3  \
    && \
    echo

USER fluent
