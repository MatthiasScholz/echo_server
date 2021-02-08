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

####################################
# Interact: User Input with defaults
####################################
app_name:=echo

# Force rebuild
.PHONY: dependencies build

#############
# User helper
#############
docker:
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
	conftest test --policy dockerfile-security.rego Dockerfile

hadolint:
	hadolint Dockerfile

########################################
# Internal: Used inside the docker build
########################################
init:
	go mod init $(app_name)/m/v2

# TODO make independent
dependencies:
	go get github.com/rs/cors

build: cleanup
	go build -o $(app_name)

run: build
	./$(app_name)

cleanup:
	go clean

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
