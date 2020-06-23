default: image

all: image

image:
	docker build . \
	-f Dockerfile \
	--tag matthewfeickert/skopeo-docker:debug-latest

run:
	docker run --rm -it matthewfeickert/skopeo-docker:debug-latest
