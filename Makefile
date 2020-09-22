# Make targets for building the TF.js example image analysis MMS edge service.

# This imports the variables from horizon/hzn.json. You can ignore these lines, but do not remove them.
-include horizon/.hzn.json.tmp.mk

# Transform the machine arch into some standard values: "arm", "arm64", or "amd64"
SYSTEM_ARCH := $(shell uname -m | sed -e 's/aarch64.*/arm64/' -e 's/x86_64.*/amd64/' -e 's/armv.*/arm/')

# To build for an arch different from the current system, set this env var to one of the values in the comment above
#export ARCH ?= $(SYSTEM_ARCH)

# Default ARCH to the architecture of this machines (as horizon/golang describes it)
export ARCH ?= $(shell hzn architecture)

DOCKER_IMAGE_BASE ?= iportilla/pynq-server
SERVICE_NAME ?=pynq-server-mms
SERVICE_VERSION ?=1.0.0
PORT_NUM ?=8888
DOCKER_NAME ?=pynq-server
OBJECT_TYPE ?=notebook
OBJECT_ID ?=2_python_environment.ipynb

default: all

all: build run

build:
	docker build -t $(DOCKER_IMAGE_BASE)_$(ARCH):$(SERVICE_VERSION) -f ./Dockerfile.$(ARCH) .

run:
	@echo "Open your browser and go to http://localhost:8888"
	docker run -d -p=$(PORT_NUM):8888 --name=$(DOCKER_NAME) $(DOCKER_IMAGE_BASE)_$(ARCH):$(SERVICE_VERSION)

  # unregiser node
unregister:
	hzn unregister -Df

#publish service
publish-service:
	hzn exchange service publish -O -f horizon/service.definition.json

# publish pattern
publish-pattern:
	hzn exchange pattern publish -f horizon/pattern.json

# Publish Service Policy target for exchange publish script
publish-service-policy:
	hzn exchange service addpolicy -f policy/service.policy.json $(HZN_ORG_ID)/$(SERVICE_NAME)_$(SERVICE_VERSION)_$(ARCH)

# Publish Deployment Policy target for exchange publish script
publish-deployment-policy:
	hzn exchange deployment addpolicy -f policy/deployment.policy.json $(HZN_ORG_ID)/policy-$(SERVICE_NAME)_$(SERVICE_VERSION)_$(ARCH)

  # target to publish new ML model file to mms
publish-mms-object:
	hzn mms object publish -m mms/object.json -f mms/2_python_environment.ipynb

  # target to list mms object
list-mms-object:
	hzn mms object list -t $(OBJECT_TYPE) -i $(OBJECT_ID) -d

list-notebooks:
	hzn mms object list -t $(OBJECT_TYPE) -i $(OBJECT_ID) -d

list-files:
	sudo ls -Rla /var/horizon/ess-store/sync/local

  # target to delete input.json file in mms
delete-mms-object:
	hzn mms object delete -t $(OBJECT_TYPE) --id $(OBJECT_ID)

  # Stop and remove a running container
stop:
	docker stop $(DOCKER_NAME); docker rm $(DOCKER_NAME)

# Clean the container
#clean:
#	-docker rm -f $(DOCKER_NAME) 2> /dev/null || :
clean:
	-docker rmi $(DOCKER_IMAGE_BASE)_$(ARCH):$(SERVICE_VERSION) 2> /dev/null || :

# This imports the variables from horizon/hzn.cfg. You can ignore these lines, but do not remove them.
horizon/.hzn.json.tmp.mk: horizon/hzn.json
	@ hzn util configconv -f $< | sed 's/=/?=/' > $@

.PHONY: build build-all-arches test publish-service build-test-publish publish-all-arches clean clean-all-archs
