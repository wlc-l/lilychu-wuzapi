# Wuzapi with SQLite — for Fly.io
# Uses git clone inside Docker build (self-contained)

FROM golang:1.25-bookworm AS builder
RUN apt-get update && apt-get install -y --no-install-recommends gcc g++ pkg-config ca-certificates git && rm -rf /var/lib/apt/lists/*
WORKDIR /app
RUN git clone --depth=1 https://github.com/asternic/wuzapi.git . && go mod download
ENV CGO_ENABLED=1
RUN go build -o wuzapi

FROM debian:bookworm-slim
RUN apt-get update && apt-get install -y --no-install-recommends ca-certificates curl ffmpeg openssl tzdata && rm -rf /var/lib/apt/lists/*
ENV TZ="Asia/Hong_Kong"
WORKDIR /app
COPY --from=builder /app/wuzapi /app/wuzapi
COPY --from=builder /app/static  /app/static
RUN chmod +x /app/wuzapi

# SQLite database goes here (mounted volume)
RUN mkdir -p /app/wuzapi_data

EXPOSE 8080
ENTRYPOINT ["/app/wuzapi", "-logtype=console", "-color=true"]
