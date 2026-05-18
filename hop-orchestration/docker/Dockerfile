FROM apache/hop:2.15.0

WORKDIR /files

COPY workflows /files/workflows
COPY pipelines /files/pipelines
COPY jdbc /files/jdbc
COPY config /files/config
COPY scripts /files/scripts

RUN chmod +x /files/scripts/*.sh || true

EXPOSE 8080

CMD ["/bin/sh", "-c", "/opt/hop/start-hop-server.sh"]