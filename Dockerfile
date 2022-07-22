# Stage to build Sync Gateway binary
FROM golang:1.18

RUN apt update -y && apt install -y file

# setup gomodules for private modules, must use buildkit
RUN git config --global --add url."git@github.com:".insteadOf "https://github.com/"
ENV GOPRIVATE=github.com/couchbaselabs/go-fleecedelta
RUN mkdir -p -m 0700 ~/.ssh && ssh-keyscan github.com >> ~/.ssh/known_hosts

# used to cache go build, makes builds faster 
RUN --mount=type=cache,target=/root/.cache/go-build --mount=type=ssh \
 cd /CBG-1712/sync_gateway && go mod download

RUN git clone ssh://github.com/couchbase/sync_gateway.git && cd sync_gateway && git checkout 469277ef1e1249acd06cd6684583ae98f4561c7c


RUN --mount=type=cache,target=/root/.cache/go-build --mount=type=ssh \
 cd sync_gateway && go build -buildvcs=false -tags cb_sg_enterprise .
RUN --mount=type=cache,target=/root/.cache/go-build --mount=type=ssh \
 cd sync_gateway && go build ./...

ENTRYPOINT ["/CBG-1712/CBG-1712_entrypoint"]
