# IMAGE
IMAGE=quay.io/mangelajo/fedora-hdl-tools
TAG=latest

## For making multiarch builds and pushing to quay
.container-arm64: Containerfile
	podman build --platform linux/arm64 -f Containerfile . --tag $(IMAGE):$(TAG)-arm64
	touch .container-arm64

.container-amd64: Containerfile
	podman build --platform linux/amd64 -f Containerfile . --tag $(IMAGE):$(TAG)-amd64
	touch .container-amd64

.container-multiarch: .container-arm64 .container-amd64
	podman manifest create -a $(IMAGE):$(TAG) \
					containers-storage:$(IMAGE):$(TAG)-arm64 \
					containers-storage:$(IMAGE):$(TAG)-amd64

	touch .container-multiarch

container-multiarch: .container-multiarch

## For making local builds
.container: Containerfile
	podman build -f Containerfile . --tag $(IMAGE):$(TAG)
	touch .container

container: .container


clean:
	rm -f .container .container-multiarch .container-arm64 .container-amd64