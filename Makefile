all: clean extension install

ORG=mochoa
VERSION=23.3
MINOR=0
IMAGE_NAME=$(ORG)/sdw-docker-extension
TAGGED_IMAGE_NAME=$(IMAGE_NAME):$(VERSION).${MINOR}

clean:
	-docker extension rm $(IMAGE_NAME)
	-docker rmi $(TAGGED_IMAGE_NAME)

extension:
	docker buildx build --load -t $(TAGGED_IMAGE_NAME) --build-arg VERSION=$(VERSION) --build-arg MINOR=$(MINOR) .

install:
	docker extension install -f $(TAGGED_IMAGE_NAME)

validate: extension
	docker extension validate $(TAGGED_IMAGE_NAME)

update: extension
	docker extension update -f $(TAGGED_IMAGE_NAME)
	docker exec mochoa_sdw-docker-extension-desktop-extension-service /home/sdw/cleanup.sh
	docker restart mochoa_sdw-docker-extension-desktop-extension-service

multiarch:
	docker buildx create --name=buildx-multi-arch --driver=docker-container --driver-opt=network=host

build:
	docker buildx build --push --builder=buildx-multi-arch --platform=linux/amd64,linux/arm64 --build-arg VERSION=$(VERSION) --tag=$(TAGGED_IMAGE_NAME) .
