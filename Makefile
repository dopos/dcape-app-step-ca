## dcape-app-step-ca Makefile
## This file extends Makefile.app from dcape
#:

SHELL               = /bin/bash
CFG                ?= .env
CFG_BAK            ?= $(CFG).bak

#- App name
APP_NAME        ?= stepca

#- Docker image name
IMAGE           ?= smallstep/step-ca

#- Docker image tag
IMAGE_VER       ?= 0.25.2

#- Admin password
ADMIN_PASSWORD  ?= $(shell openssl rand -hex 16; echo)

#- App data path
APP_DATA        ?= $(DCAPE_VAR)/$(APP_NAME)

APP_SITE        ?= stepca.dev.test

# PgSQL used as DB
USE_DB           = yes
DCAPE_DC_USED    = false

# ------------------------------------------------------------------------------

# if exists - load old values
-include $(CFG_BAK)
export

-include $(CFG)
export

# ------------------------------------------------------------------------------
# Find and include DCAPE_ROOT/Makefile
DCAPE_COMPOSE   ?= dcape-compose
DCAPE_ROOT      ?= $(shell docker inspect -f "{{.Config.Labels.dcape_root}}" $(DCAPE_COMPOSE))

ifeq ($(shell test -e $(DCAPE_ROOT)/Makefile.app && echo -n yes),yes)
  include $(DCAPE_ROOT)/Makefile.app
else
  include /opt/dcape/Makefile.app
endif

define CAJSON
{
	"db": {
		"type": "postgresql",
		"dataSource": "postgresql://",
		"badgerFileLoadingMode": ""
	},
	"authority": {
		"provisioners": [
			{
				"type": "ACME",
				"name": "acme",
				"claims": {
					"minTLSCertDuration": "20m0s",
					"maxTLSCertDuration": "2400h0m0s",
					"defaultTLSCertDuration": "240h0m0s",
					"enableSSHCA": true,
					"disableRenewal": false,
					"allowRenewalAfterExpiry": false
				},
			}
		],
	},
	"commonName": "Dcape Step Online CA"
}

endef


# create config dir
$(APP_DATA)/config:
	@mkdir -p $@

# create defaul config file
$(APP_DATA)/config/ca.json: $(APP_DATA)/config
	@echo "$$CAJSON" >> $@

# ca-create addon
ca-create: $(APP_DATA)/config/ca.json

# init storage
ca-create: $(APP_DATA)/config/ca.json
ca-create: CMD=run --rm app step ca init
ca-create: dc

# set times
ca-time: CMD=run --rm app step ca provisioner update acme --x509-min-dur=20m --x509-max-dur=2400h --x509-default-dur=240h
ca-time: dc

# add ACME provisioner
ca-acme: CMD=exec app step ca provisioner add acme --type ACME
ca-acme: dc

## install root cert on host machine
ca-install:
	sudo cp $(APP_DATA)/certs/root_ca.crt /usr/local/share/ca-certificates/$(APP_NAME).crt
	sudo /usr/sbin/update-ca-certificates

ca-test:
	curl https://$(APP_SITE)/health

DO ?= sh

## run command if container is running
## Example: make exec DO=ls
exec: CMD=exec app $(DO)
exec: dc

## run new container and run command in it
## Example: make run DO=ls
run: CMD=run --rm app $(DO)
run: dc
