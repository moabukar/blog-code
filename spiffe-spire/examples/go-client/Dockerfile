# Build stage
FROM golang:1.22-alpine AS builder

WORKDIR /app

COPY go.mod go.sum ./
RUN go mod download

COPY main.go ./
RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o client .

# Final stage
FROM gcr.io/distroless/static-debian12:nonroot

COPY --from=builder /app/client /client

USER nonroot:nonroot

ENTRYPOINT ["/client"]
