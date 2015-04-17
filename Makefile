DOCKER_REPO?=registry.gocurb.internal:80
CONTAINER=$(DOCKER_REPO)/consul

all: build push clean

build:
	ansible-galaxy install -r requirements.yml -f
	docker build -t $(CONTAINER):latest . 

push:
	docker push $(CONTAINER)

clean:
	rm -r roles
