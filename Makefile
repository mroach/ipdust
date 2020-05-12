.PHONY: build-base push-release release serve shell test test-credo

ELIXIR_VER = 1.10
PORT = 4000
APP = ipdust
DOCKER_ORG = mfroach
TAG = $(APP)_elixir_$(ELIXIR_VER)
VERSION = $(shell cat VERSION)
GIT_COMMIT = $(shell git rev-parse --verify HEAD)

build-base:
	docker build --build-arg elixir_ver=$(ELIXIR_VER) --target base -t $(TAG) .

serve: build-base
	docker run --rm -it \
		-v $(PWD):/opt/app \
		-p 4000:4000 \
		$(TAG) \
		mix do deps.get, phx.server

shell: build-base
	docker run --rm -it \
		-v $(PWD):/opt/app \
		-p $(PORT):4000 \
		$(TAG) \
		bash

test: build-base
	docker run --rm -v $(PWD):/opt/app -e MIX_ENV=test $(TAG) mix test

test-credo: build-base
	docker run --rm -v $(PWD):/opt/app $(TAG) mix credo --strict

release:
	@echo Building version $(VERSION)
	docker build \
		--build-arg elixir_ver=$(ELIXIR_VER) \
		--build-arg git_commit=$(GIT_COMMIT) \
		--build-arg app_version=$(VERSION) \
		--build-arg maxmind_license=$(MAXMIND_LICENSE) \
		--target release \
		--tag $(DOCKER_ORG)/$(APP):$(VERSION) .
	docker tag $(DOCKER_ORG)/$(APP):$(VERSION) $(DOCKER_ORG)/$(APP):latest

push-release: release
	docker push $(DOCKER_ORG)/$(APP):$(VERSION)
	docker push $(DOCKER_ORG)/$(APP):latest
