git:
	git init
	git add .
	git commit -m ":tada: Initial bootstrapping"
	git branch -M main

version_batect := 0.67.0
init-batect:
	brew install batect/batect/batect-zsh-completion
	curl --silent -L -O https://github.com/batect/batect/releases/download/$(version_batect)/batect
	curl --silent -L -O https://github.com/batect/batect/releases/download/$(version_batect)/batect.cmd
	chmod +x batect
	./batect --version
	touch batect.yml

uninstall-batect:
	brew uninstall batect/batect/batect-zsh-completion

batect-build:
	./batect build

####################################
# Interact: User Input with defaults
####################################
app_name:=echo

# Force rebuild
.PHONY: dependencies build

#############
# User helper
#############
docker: batect-build
	docker build --tag $(app_name) --build-arg app_name=$(app_name) .

up: down docker
	docker-compose up --detach

down:
	docker-compose down

logs: up
	docker-compose logs --follow $(app_name)

######
# Test
######
test:
	@curl --silent localhost:8080/test | grep test || (echo "ERROR :: Server not running!"; exit 1)

lint: conftest hadolint

conftest:
	conftest test --policy test/dockerfile-security.rego Dockerfile

hadolint:
	hadolint Dockerfile

########################################
# Internal: Used inside the docker build
########################################
init:
	go mod init $(app_name)/m/v2

build: cleanup
	go build -o $(app_name) cmd/echo/app.go

run: build
	./$(app_name)

cleanup:
	go clean
	rm -f $(app_name)

#########################
# All MacOSX dependenices
#########################
dependencies_macosx:
	brew install golang
	brew tap instrumenta/instrumenta
	brew install conftest
	brew install hadolint

dependencies_macosx_cleanup:
	brew uninstall golang
	brew untap instrumenta/instrumenta
	brew uninstall conftest
	brew uninstall hadolint
