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
SHELL:=/bin/bash
CONTAINER_TEST_VERSION:=1.8.0
FEDORA_VERSION:=30

ifeq ($(GIT_BRANCH), master)
	IMAGE_TAG:=$(IMAGE_NAME):$(XPRA_VERSION)-f$(FEDORA_VERSION)-$(GIT_SHA)
	PREFIX:=$(XPRA_VERSION)-f$(FEDORA_VERSION)
else
	IMAGE_TAG:=$(IMAGE_NAME):$(XPRA_VERSION)-f$(FEDORA_VERSION)-$(GIT_BRANCH)-$(GIT_SHA)
	PREFIX:=$(XPRA_VERSION)-f$(FEDORA_VERSION)
endif

GIT_DATE:="$(shell TZ=UTC git show --quiet --date='format-local:%Y-%m-%d %H:%M:%S +0000' --format='%cd')"
BUILD_DATE:="$(shell date -u '+%Y-%m-%d %H:%M:%S %z')"

buildcontainer:
	# Download container diff
	curl -L https://storage.googleapis.com/container-diff/latest/container-diff-$(OS)-amd64 -o container-diff
	chmod +x ./container-diff

	# "base" image
	docker build \
		--pull \
		--build-arg XPRA_VERSION=$(XPRA_VERSION) \
		--build-arg FEDORA_VERSION=$(FEDORA_VERSION) \
		--build-arg MAINTAINER=$(MAINTAINER) \
		--build-arg MAINTAINER_URL=$(MAINTAINER_URL) \
		--build-arg GIT_SHA="$(GIT_SHA)" \
		--build-arg GIT_DATE=$(GIT_DATE) \
		--build-arg BUILD_DATE=$(BUILD_DATE) \
		--tag $(IMAGE_TAG) \
		--tag $(IMAGE_NAME):$(PREFIX) \
		--file Dockerfile .

relabel:
	$(eval RPM_PACKAGES_INSTALLED:=$(shell ./container-diff analyze daemon://$(IMAGE_NAME):$(PREFIX) --type=rpm -j | gzip  -c | base64))
	$(eval RPM_PACKAGES_INSTALLED_HASH:=$(shell p=(`echo $(RPM_PACKAGES_INSTALLED)|sha1sum`); echo $$p))

	@echo Relabeling container with package list
	docker build \
		--pull \
		--build-arg XPRA_VERSION=$(XPRA_VERSION) \
		--build-arg FEDORA_VERSION=$(FEDORA_VERSION) \
		--build-arg MAINTAINER=$(MAINTAINER) \
		--build-arg MAINTAINER_URL=$(MAINTAINER_URL) \
		--build-arg GIT_SHA="$(GIT_SHA)" \
		--build-arg GIT_DATE=$(GIT_DATE) \
		--build-arg BUILD_DATE=$(BUILD_DATE) \
		--label packages.rpm.list="$(RPM_PACKAGES_INSTALLED)" \
		--tag $(IMAGE_TAG) \
		--tag $(IMAGE_NAME):$(PREFIX) \
		--tag $(IMAGE_NAME):$(PREFIX)-$(RPM_PACKAGES_INSTALLED_HASH) \
		--file Dockerfile .

build: buildcontainer relabel

output:
	docker save -o hmdc-xpra-$(PREFIX).tar $(IMAGE_NAME):$(PREFIX)

push:
	docker push $(IMAGE_NAME):$(PREFIX)

run:	
	docker run -d -p 8080:8080 $(IMAGE_NAME):$(PREFIX)