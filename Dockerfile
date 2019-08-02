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
