FROM golang:alpine as builder
MAINTAINER Jessica Frazelle <jess@linux.com>

ENV PATH /go/bin:/usr/local/go/bin:$PATH
ENV GOPATH /go

RUN	apk add --no-cache \
	ca-certificates

COPY . /go/src/github.com/genuinetools/sshb0t

RUN set -x \
	&& apk add --no-cache --virtual .build-deps \
		git \
		gcc \
		libc-dev \
		libgcc \
		make \
	&& cd /go/src/github.com/genuinetools/sshb0t \
	&& GOOS=linux GOARCH=arm GOARM=6 go build . \
	&& mv sshb0t /usr/bin/sshb0t \
	&& apk del .build-deps \
	&& rm -rf /go \
	&& echo "Build complete."

FROM scratch

COPY --from=builder /usr/bin/sshb0t /usr/bin/sshb0t
COPY --from=builder /etc/ssl/certs/ /etc/ssl/certs

ENTRYPOINT [ "sshb0t" ]
CMD [ "--help" ]
