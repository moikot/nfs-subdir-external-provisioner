FROM --platform=$BUILDPLATFORM golang:1.14 as build-env

# xx wraps go to automatically configure $GOOS, $GOARCH, and $GOARM
# based on TARGETPLATFORM provided by Docker.
COPY --from=tonistiigi/xx:golang-1.0.0 / /

ARG APP_FOLDER

ADD . ${APP_FOLDER}
WORKDIR ${APP_FOLDER}

RUN apt-get update && apt-get install ca-certificates

# Compile independent executable using go wrapper from xx:golang
ARG TARGETPLATFORM
RUN CGO_ENABLED=0 go build -a -ldflags '-extldflags "-static"' -o /bin/main ./cmd/nfs-subdir-external-provisioner

FROM scratch

COPY --from=build-env /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
COPY --from=build-env /bin/main /app/main

ENTRYPOINT ["/app/main"]