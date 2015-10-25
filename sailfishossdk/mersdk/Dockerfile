FROM scratch

ADD mersdk-1510.tar.xz entrypoint.sh /

# Grab gosu for easy step-down from root
RUN curl -L -o /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/1.4/gosu-amd64" \
    && echo '6f3a72f474cafacb3c7b4a7397a1f37d82fcc27b596cbb66e4ea0a8ee92eee76 */usr/local/bin/gosu' | sha256sum -c \
    && chmod +x /usr/local/bin/gosu \
    && chmod u+s /usr/local/bin/gosu

EXPOSE 22/tcp
ENTRYPOINT ["/entrypoint.sh"]
