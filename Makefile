AWS_ECR_IMAGE_REPO ?= 745368277267.dkr.ecr.us-east-1.amazonaws.com

IMAGE_NAME ?= store-message
IMAGE_VERSION  ?= 0.0.1

FULL_IMAGE_NAME="${AWS_ECR_IMAGE_REPO}/${IMAGE_NAME}:${IMAGE_VERSION}"

tf-validate:
	cd prod && terraform validate

tf-plan:
	cd prod && terraform plan

go-build:
	cd lambda/store-message && \
	rm -f build/main build/main.zip && \
	GOOS=linux GOARCH=amd64 go build -o build/main && \
	zip build/main.zip build/main

docker-build:
	docker build -t ${FULL_IMAGE_NAME} -f lambda/store-message/Dockerfile . 

docker-push: docker-build
	aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin ${AWS_ECR_IMAGE_REPO}
	docker push ${FULL_IMAGE_NAME}

.PHONY: tf-validate tf-plan go-build