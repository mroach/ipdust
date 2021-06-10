.PHONY: build-base new-version push-release release serve shell test test-credo test-format

ELIXIR_VER = 1.11
PORT = 4000
APP = ipdust
DOCKER_ORG = mfroach
TAG = $(APP)_elixir_$(ELIXIR_VER)
VERSION = $(shell cat VERSION)
GIT_COMMIT = $(shell git rev-parse --verify HEAD)

word-dot = $(word $2,$(subst ., ,$1))
VERSION_MAJOR = $(call word-dot,$(VERSION),1)
VERSION_MINOR = $(call word-dot,$(VERSION),2)
VERSION_PATCH = $(call word-dot,$(VERSION),3)

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

test-format: build-base
	docker run --rm -v $(PWD):/opt/app $(TAG) mix format --check-formatted

new-version:
	@echo "This will:"
	@echo "  - Update the VERSION file"
	@echo "  - Commit the VERSION file with 'Version vx.x.x' as the message"
	@echo "  - Create a git tag named vx.x.x"
	@echo "  - Push the tag to GitHub"
	@echo

	@echo Current version is $(VERSION)
	@read -p "New version: " new_version; \
	echo $$new_version > VERSION; \
	git add VERSION; \
	git commit -m "Version $$new_version"; \
	git tag v$$new_version; \
	git push origin refs/tags/v$$new_version


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
	docker tag $(DOCKER_ORG)/$(APP):$(VERSION) $(DOCKER_ORG)/$(APP):$(VERSION_MAJOR).$(VERSION_MINOR)
	docker tag $(DOCKER_ORG)/$(APP):$(VERSION) $(DOCKER_ORG)/$(APP):$(VERSION_MAJOR)

push-release: release
	docker push $(DOCKER_ORG)/$(APP):$(VERSION)
	docker push $(DOCKER_ORG)/$(APP):$(VERSION_MAJOR)
	docker push $(DOCKER_ORG)/$(APP):$(VERSION_MAJOR).$(VERSION_MINOR)
	docker push $(DOCKER_ORG)/$(APP):latest
