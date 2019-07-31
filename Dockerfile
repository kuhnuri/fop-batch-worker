FROM golang:1.12.7 AS builder
WORKDIR $GOPATH/src/github.com/kuhnuri/batch-fop
RUN go get -v -u github.com/kuhnuri/go-worker
COPY docker/main.go .
#RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o app .
RUN go build -a -o main .

FROM adoptopenjdk/openjdk11:jdk-11.0.3_7-slim

RUN apt-get -y update \
    && apt-get -y install --no-install-recommends unzip \
    && apt-get -y clean \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /opt/app

#COPY build/dist /opt/app/lib
COPY docker/logback.xml /opt/app/config/logback.xml
COPY docker/fop.xconf /opt/app/fop.xconf
ADD https://www-eu.apache.org/dist/xmlgraphics/fop/binaries/fop-2.3-bin.zip /tmp/fop-2.3-bin.zip
RUN unzip /tmp/fop-2.3-bin.zip -d /tmp \
    && mkdir -p /opt/app/lib \
    && mv /tmp/fop-2.3/fop/build/fop.jar /opt/app/lib \
    && mv /tmp/fop-2.3/fop/lib/*.jar /opt/app/lib \
    && rm -rf tmp/fop-2.3*

COPY --from=builder /go/src/github.com/kuhnuri/batch-fop/main .

ENTRYPOINT ["./main"]



#
#COPY build/dist /opt/app/lib
#COPY docker/logback.xml /opt/app/config/logback.xml
#COPY docker/fop.xconf /opt/app/fop.xconf
#
#COPY docker/run.sh /opt/app/run.sh
#RUN chmod 755 /opt/app/run.sh
#
## EXPOSE 9000
## VOLUME ["/var/log/app", "/tmp/app", "/var/lib/app"]
## HEALTHCHECK CMD curl http://localhost:9000/health || exit 1
#
#WORKDIR /opt/app
#ENTRYPOINT ["./run.sh"]

