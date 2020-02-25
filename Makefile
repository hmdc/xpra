# default build target
all::

all:: build
.PHONY: all push test

XPRA_VERSION:=3.0
MAINTAINER:="Harvard-MIT Data Center <linux@lists.hmdc.harvard.edu>"
MAINTAINER_URL:="https://github.com/hmdc/xpra"
IMAGE_NAME:=hmdc/xpra
GIT_SHA:=$(shell git rev-parse HEAD)
OS:=$(shell uname | tr '[:upper:]' '[:lower:]')
GIT_BRANCH:=$(shell git rev-parse --abbrev-ref HEAD)
CONTAINER_TEST_VERSION:=1.8.0

ifeq ($(GIT_BRANCH), master)
	IMAGE_TAG:=$(IMAGE_NAME):$(XPRA_VERSION)-$(GIT_SHA)
	PREFIX:=$(XPRA_VERSION)
else
	IMAGE_TAG:=$(IMAGE_NAME):$(XPRA_VERSION)-$(GIT_BRANCH)-$(GIT_SHA)
	PREFIX:=$(XPRA_VERSION)-$(GIT_BRANCH)
endif

GIT_DATE:="$(shell TZ=UTC git show --quiet --date='format-local:%Y-%m-%d %H:%M:%S +0000' --format='%cd')"
BUILD_DATE:="$(shell date -u '+%Y-%m-%d %H:%M:%S %z')"

build:

	# "base" image
	docker build \
		--pull \
		--build-arg XPRA_VERSION=$(XPRA_VERSION) \
		--build-arg MAINTAINER=$(MAINTAINER) \
		--build-arg MAINTAINER_URL=$(MAINTAINER_URL) \
		--build-arg GIT_SHA="$(GIT_SHA)" \
		--build-arg GIT_DATE=$(GIT_DATE) \
		--build-arg BUILD_DATE=$(BUILD_DATE) \
		--tag $(IMAGE_TAG) \
		--tag $(IMAGE_NAME):$(PREFIX) \
		--file Dockerfile .

output:
	docker save -o hmdc-xpra-$(PREFIX).tar $(IMAGE_NAME):$(PREFIX)

push:
	docker push $(IMAGE_NAME):$(PREFIX)

test:	
	# No reporting available yet.
	# https://github.com/GoogleContainerTools/container-structure-test/issues/207
	# Downloading container-structure-test
	echo Done