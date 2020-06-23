default: image

all: image

image:
	docker build . \
	-f Dockerfile \
	--build-arg VERSION_TAG=v1.1.0 \
	--tag matthewfeickert/skopeo-docker:debug-latest

run:
	docker run --rm -it matthewfeickert/skopeo-docker:debug-latest
