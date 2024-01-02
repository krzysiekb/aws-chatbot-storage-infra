tf-validate:
	cd prod && terraform validate

tf-plan:
	cd prod && terraform plan

go-build:
	cd lambda/store-message && GOOS=linux go build -o build/main

.PHONY: tf-validate tf-plan go-build