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
PORTFOLIO_SRC=$(wildcard img/portfolio/original/*.png img/portfolio/original/*.gif img/portfolio/original/*.jpeg img/portfolio/original/*.jpg)
PORTFOLIO_THUMBNAIL_SRC=$(subst img/portfolio/original, img/portfolio/thumbnail, $(PORTFOLIO_SRC))
PORTFOLIO_LARGE_SRC=$(subst img/portfolio/original, img/portfolio/large, $(PORTFOLIO_SRC))

LOGO_SRC=$(wildcard img/logos/original/*.png img/logos/original/*.gif img/logos/original/*.jpeg img/logos/original/*.jpg)
LOGO_THUMBNAIL_SRC=$(subst img/logos/original, img/logos/thumbnail, $(LOGO_SRC))
LOGO_LARGE_SRC=$(subst img/logos/original, img/logos/large, $(LOGO_SRC))

TEAM_SRC=$(wildcard img/team/original/*.png img/team/original/*.gif img/team/original/*.jpeg img/team/original/*.jpg)
TEAM_THUMBNAIL_SRC=$(subst img/team/original, img/team/thumbnail, $(TEAM_SRC))
TEAM_LARGE_SRC=$(subst img/team/original, img/team/large, $(TEAM_SRC))


help:
	@awk 'BEGIN {FS = ":.*##"; } /^[a-zA-Z_-]+:.*?##/ { printf "$(PRIMARY_COLOR)%-20s$(NO_COLOR) %s\n", $$1, $$2 }' $(MAKEFILE_LIST) | sort



images: portfolio logo team ## Generate images in portfolio and logo


img/portfolio/thumbnail/%: img/portfolio/original/%
	mogrify -path $(dir $@) -resize 400x390 -quality $(IMAGE_QUALITY) $<

img/portfolio/large/%: img/portfolio/original/%
	mogrify -path $(dir $@) -resize 400x390 -quality $(IMAGE_QUALITY) $<

img/logos/thumbnail/%: img/logos/original/%
	mogrify -path $(dir $@) -resize 400x390 -quality $(IMAGE_QUALITY) $<

img/logos/large/%: img/logos/original/%
	mogrify -path $(dir $@) -resize 400x390 -quality $(IMAGE_QUALITY) $<

img/team/thumbnail/%: img/team/original/%
	mogrify -path $(dir $@) -resize 400x390 -quality $(IMAGE_QUALITY) $<

img/team/large/%: img/team/original/%
	mogrify -path $(dir $@) -resize 400x390 -quality $(IMAGE_QUALITY) $<
	

portfolio: $(PORTFOLIO_THUMBNAIL_SRC) $(PORTFOLIO_LARGE_SRC) ## Generate portfolio thumbnail and large images
	@echo Portfolio done.

logo: $(LOGO_THUMBNAIL_SRC) $(LOGO_LARGE_SRC) ## Generate logo thumbnail
	@echo Logos done.


team: $(TEAM_THUMBNAIL_SRC) $(TEAM_LARGE_SRC) ## Generate team images in the right size
	@echo Team done.

clean-images:
	rm $(PORTFOLIO_THUMBNAIL_SRC) $(PORTFOLIO_LARGE_SRC) $(LOGO_THUMBNAIL_SRC) $(LOGO_LARGE_SRC) $(TEAM_THUMBNAIL_SRC) $(TEAM_LARGE_SRC)