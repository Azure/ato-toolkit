chart_dest := .
go_dest := bin

.PHONY:build
build:
	go build -o $(go_dest) ./...

.PHONY:fmt
fmt:
	go fmt ./...

.PHONY:test
test:
	go test ./...
