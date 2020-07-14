.PHONY: help pep8 install deploy release startdev
.DEFAULT_GOAL= help

#include .env
#export $(shell sed 's/=.*//' envfile)
PORT?=8000
HOST?=127.0.0.1
COM_COLOR   = \033[0;34m
OBJ_COLOR   = \033[0;36m
OK_COLOR    = \033[0;32m
ERROR_COLOR = \033[0;31m
WARN_COLOR  = \033[0;33m
NO_COLOR    = \033[m

APP_VERSION = $(shell date +"%Y%m%d%H%M")
APP_NAME = "brightsoftwares_corporate_website"
LATEST_RELEASE = $(shell ls -tp -w 1 *zip | head --lines=1)

IMAGE_QUALITY=86


help:
	@awk 'BEGIN {FS = ":.*##"; } /^[a-zA-Z_-]+:.*?##/ { printf "$(PRIMARY_COLOR)%-20s$(NO_COLOR) %s\n", $$1, $$2 }' $(MAKEFILE_LIST) | sort



images: portfolio logo team ## Generate images in portfolio and logo

portfolio:  ## Generate portfolio thumbnail and large images
	@echo Processing thumbnails
	-mogrify -path img/portfolio/thumbnail -resize 400x390 -quality $(IMAGE_QUALITY) img/portfolio/original/*.png
	-mogrify -path img/portfolio/thumbnail -resize 400x390 -quality $(IMAGE_QUALITY) img/portfolio/original/*.jpg
	-mogrify -path img/portfolio/thumbnail -resize 400x390 -quality $(IMAGE_QUALITY) img/portfolio/original/*.gif
	
	@echo Processing large
	-mogrify -path img/portfolio/large -resize 600x450 -quality $(IMAGE_QUALITY) img/portfolio/original/*.png 
	-mogrify -path img/portfolio/large -resize 600x450 -quality $(IMAGE_QUALITY) img/portfolio/original/*.jpg
	-mogrify -path img/portfolio/large -resize 600x450 -quality $(IMAGE_QUALITY) img/portfolio/original/*.gif

logo:  ## Generate logo thumbnail
	@echo Processing thumbnails
	-mogrify -path img/logos/thumbnail -resize 50x50 -quality $(IMAGE_QUALITY) img/logos/original/*.png
	-mogrify -path img/logos/thumbnail -resize 50x50 -quality $(IMAGE_QUALITY) img/logos/original/*.jpg
	-mogrify -path img/logos/thumbnail -resize 50x50 -quality $(IMAGE_QUALITY) img/logos/original/*.gif

	@echo Processing large
	-mogrify -path img/logos/large -resize 50x50 -quality $(IMAGE_QUALITY) img/logos/original/*.png
	-mogrify -path img/logos/large -resize 50x50 -quality $(IMAGE_QUALITY) img/logos/original/*.jpg
	-mogrify -path img/logos/large -resize 50x50 -quality $(IMAGE_QUALITY) img/logos/original/*.gif


team:  ## Generate team images in the right size
	@echo Processing thumbnails
	@-mogrify -path img/team/thumbnail -resize 225x225 -quality $(IMAGE_QUALITY) img/team/original/*.png
	@-mogrify -path img/team/thumbnail -resize 225x225 -quality $(IMAGE_QUALITY) img/team/original/*.jpg
	@-mogrify -path img/team/thumbnail -resize 225x225 -quality $(IMAGE_QUALITY) img/team/original/*.gif

	@echo Processing large
	@-mogrify -path img/team/large -resize 225x225 -quality $(IMAGE_QUALITY) img/team/original/*.png
	@-mogrify -path img/team/large -resize 225x225 -quality $(IMAGE_QUALITY) img/team/original/*.jpg
	@-mogrify -path img/team/large -resize 225x225 -quality $(IMAGE_QUALITY) img/team/original/*.gif