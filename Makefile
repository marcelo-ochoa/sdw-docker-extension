all: clean extension install

ORG=mochoa
VERSION=23.2
MINOR=1
IMAGE_NAME=$(ORG)/sdw-docker-extension
TAGGED_IMAGE_NAME=$(IMAGE_NAME):$(VERSION).${MINOR}

clean:
	-docker extension rm $(IMAGE_NAME)
	-docker rmi $(TAGGED_IMAGE_NAME)

extension:
	docker buildx build -t $(TAGGED_IMAGE_NAME) --build-arg VERSION=$(VERSION) --build-arg MINOR=$(MINOR) .

install:
	docker extension install -f $(TAGGED_IMAGE_NAME)

validate: extension
	docker extension validate $(TAGGED_IMAGE_NAME)

update: extension
	docker extension update -f $(TAGGED_IMAGE_NAME)

multiarch:
	docker buildx create --name=buildx-multi-arch --driver=docker-container --driver-opt=network=host

build:
	docker buildx build --push --builder=buildx-multi-arch --platform=linux/amd64,linux/arm64 --build-arg VERSION=$(VERSION) --tag=$(TAGGED_IMAGE_NAME) .
