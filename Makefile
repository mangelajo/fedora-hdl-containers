# IMAGE
IMAGE=quay.io/mangelajo/fedora-hdl-tools
TAG=latest
GIT_REF=$(shell git rev-parse --short HEAD)

## For making multiarch builds and pushing to quay
.container-arm64: Containerfile
	podman build --platform linux/arm64 -f Containerfile .       --tag $(IMAGE):$(TAG)-arm64
	podman build --platform linux/arm64 -f Containerfile.litex . --tag $(IMAGE)-litex:$(TAG)-arm64
	touch .container-arm64

.container-amd64: Containerfile
	podman build --platform linux/amd64 -f Containerfile .       --tag $(IMAGE):$(TAG)-amd64
	podman build --platform linux/amd64 -f Containerfile.litex . --tag $(IMAGE)-litex:$(TAG)-amd64
	touch .container-amd64

.container-multiarch: .container-arm64 .container-amd64
	podman manifest rm $(IMAGE):$(TAG) || true
	podman image rm $(IMAGE):$(TAG) || true
	podman manifest create $(IMAGE):$(TAG) \
					containers-storage:$(IMAGE):$(TAG)-arm64 \
					containers-storage:$(IMAGE):$(TAG)-amd64
	podman manifest rm $(IMAGE)-litex:$(TAG) || true
	podman image rm $(IMAGE)-litex:$(TAG) || true
	podman manifest create $(IMAGE)-litex:$(TAG) \
					containers-storage:$(IMAGE)-litex:$(TAG)-arm64 \
					containers-storage:$(IMAGE)-litex:$(TAG)-amd64

	podman tag $(IMAGE):$(TAG) $(IMAGE):$(GIT_REF)
	podman tag $(IMAGE)-litex:$(TAG) $(IMAGE)-litex:$(GIT_REF)
	touch .container-multiarch

container-multiarch: .container-multiarch

push-multiarch-container: .container-multiarch
	podman manifest push $(IMAGE):$(TAG) $(IMAGE):$(TAG)
	podman manifest push $(IMAGE):$(GIT_REF) $(IMAGE):$(GIT_REF)
	podman manifest push $(IMAGE)-litex:$(TAG) $(IMAGE)-litex:$(TAG)
	podman manifest push $(IMAGE)-litex:$(GIT_REF) $(IMAGE)-litex:$(GIT_REF)

## For making local builds
.container: Containerfile
	podman build -f Containerfile .       --tag $(IMAGE):$(TAG)
	podman build -f Containerfile.litex . --tag $(IMAGE)-litex:$(TAG)
	touch .container

container: .container


clean:
	rm -f .container .container-multiarch .container-arm64 .container-amd64