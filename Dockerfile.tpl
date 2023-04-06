FROM golang:1.20-alpine AS build
ADD . /src
WORKDIR /src
RUN go get -d -v -t
RUN GOOS=linux GOARCH=amd64 go build -v -o [[.AppName]] 

FROM alpine:3.17.3
EXPOSE 8080
CMD ["[[.AppName]]"]
ENV VERSION 1.1.4
COPY --from=build /src/[[.AppName]] /usr/local/bin/[[.AppName]]
RUN chmod +x /usr/local/bin/[[.AppName]]
