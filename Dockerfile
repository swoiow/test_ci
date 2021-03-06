FROM golang:alpine as builder

ENV CGO_ENABLED=0 \
    GOOS=linux \
    GOARCH=amd64

WORKDIR /app
RUN apk add git
RUN git clone https://github.com/v2ray/v2ray-core.git /app && \
    git fetch --tags
RUN latestTag=$(git describe --tags `git rev-list --tags --max-count=1`) && \
    git checkout $latestTag && \
    CODENAME=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w ${1:-64} | head -n 1) && \
    BUILDNAME=$(date +%s) && \
    sed -i "s/^[ \t]\+codename.\+$/\tcodename = \"${CODENAME}\"/;s/^[ \t]\+build.\+$/\tbuild = \"${BUILDNAME}\"/;" core.go
RUN go build -o ./v2ray -ldflags "-s -w" -i ./main && chmod +x ./v2ray

FROM alpine as upx
WORKDIR /app
RUN apk add wget
COPY --from=builder /app/v2ray /app/v2ray
RUN wget https://github.com/upx/upx/releases/download/v3.95/upx-3.95-amd64_linux.tar.xz
RUN tar --strip-components=1 -xf upx-3.95-amd64_linux.tar.xz && \
    ./upx --brute /app/v2ray

FROM alpine

ENV TZ=Asia/Shanghai
ADD https://github.com/Yelp/dumb-init/releases/download/v1.2.2/dumb-init_1.2.2_amd64 /usr/bin/dumb-init
RUN chmod +x /usr/bin/dumb-init

RUN apk update && \
    apk upgrade && \
    apk add ca-certificates && update-ca-certificates && \
    apk add --update tzdata && \
    rm -rf /var/cache/apk/*

ADD https://github.com/v2ray/ext/raw/master/docker/official/config.json /etc/v2ray/config.json
COPY --from=upx /app/v2ray /usr/bin/v2ray

ENTRYPOINT ["dumb-init", "--"]
CMD ["v2ray", "-config=/etc/v2ray/config.json"]
