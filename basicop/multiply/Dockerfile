FROM golang:alpine AS build-env
RUN mkdir /app
COPY main.go  /app/main.go
RUN go env -w GO111MODULE=off
RUN cd /app && go build -o goapp

FROM alpine
RUN apk update && apk add ca-certificates && \
    update-ca-certificates && rm -rf /var/cache/apk/*

RUN mkdir /app
WORKDIR /app
COPY --from=build-env /app/goapp /app

EXPOSE 8080
ENTRYPOINT ./goapp
