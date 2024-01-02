tf-validate:
	cd prod && terraform validate

tf-plan:
	cd prod && terraform plan

go-build:
	cd lambda/store-message && \
	rm -f build/main build/main.zip && \
	GOOS=linux go build -o build/main && \
	zip build/main.zip build/main

.PHONY: tf-validate tf-plan go-build