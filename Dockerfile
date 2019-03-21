FROM golang:1.9.3-stretch as builder

ENV GIT_REPO=https://github.com/lomik/carbon-clickhouse.git
ENV GIT_TAG=v0.9.1

RUN git clone ${GIT_REPO} && \
    cd carbon-clickhouse && \
    git checkout tags/${GIT_TAG} && \
    CGO_ENABLED=0 make

WORKDIR /go/carbon-clickhouse
RUN ls /go/carbon-clickhouse

FROM alpine:latest

RUN apk --update add bash

RUN mkdir -p /data/carbon-clickhouse && \
    mkdir -p /var/log/carbon-clickhouse && \
    mkdir -p /etc/carbon-clickhouse && \
    mkdir -p /usr/bin/

COPY --from=builder /go/carbon-clickhouse/carbon-clickhouse /usr/bin/carbon-clickhouse

# Add default config
ADD config.conf /etc/carbon-clickhouse/carbon-clickhouse.conf

EXPOSE 2003
EXPOSE 2004
EXPOSE 2005
EXPOSE 2006
EXPOSE 2007
EXPOSE 7007

VOLUME /etc/carbon-clickhouse
VOLUME /var/lib/carbon-clickhouse
VOLUME /var/log/carbon-clickhouse

CMD ["/usr/bin/carbon-clickhouse", "-config=/etc/carbon-clickhouse/carbon-clickhouse.conf"]
