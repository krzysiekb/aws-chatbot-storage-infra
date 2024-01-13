FROM golang:1.21-alpine as builder
COPY ./lambda/store-message/ /app
WORKDIR /app
RUN GOOS=linux GOARCH=amd64 go build -o build/main
#-------------------------------------------------
FROM alpine
COPY --from=builder /app/build/main /app/main
ENTRYPOINT ["/app/main"]