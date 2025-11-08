LUAC ?= luac5.4
LUA ?= lua5.4
DELIVERY_DIR ?= ./delivery

DEV_PLUGIN = metadataPatch.lrdevplugin
REL_PLUGIN = metadataPatch.lrplugin

INFO_FILE = ${DEV_PLUGIN}/Info.lua

TVERSION = $(shell ${LUA} ${INFO_FILE} --version-table)
SVERSION = $(shell ${LUA} ${INFO_FILE} --version)

LUA_SOURCES = $(shell find ${DEV_PLUGIN} -name *.lua)
LUA_OBJECTS  := $(LUA_SOURCES:$(DEV_PLUGIN)/%.lua=$(DELIVERY_DIR)/$(REL_PLUGIN)/%.lua)

LUA_TEST_PATH = "./${DEV_PLUGIN}/?.lua;./test/?.lua;;"
LUA_TEST_ENV = "_G.use=require"

DELIVERY_ARCHIVE = ${REL_PLUGIN}-v${SVERSION}.zip
DELIVERY_ARCHIVE_PATH = ${DELIVERY_DIR}/${DELIVERY_ARCHIVE}

.PHONY:
bump_build:
	@sed -i~ "s|${TVERSION}|${shell ${LUA} ${DEV_PLUGIN}/Info.lua --next-build}|" ${INFO_FILE}

.PHONY:
bump_revision:
	@sed -i~ "s|${TVERSION}|${shell ${LUA} ${DEV_PLUGIN}/Info.lua --next-revision}|" ${INFO_FILE}

.PHONY: sversion
sversion:
	@echo ${SVERSION}

deliver : ${DELIVERY_ARCHIVE_PATH}
	@echo ALL DONE

${DELIVERY_ARCHIVE_PATH}: ${DELIVERY_DIR}/${REL_PLUGIN} \
		${DELIVERY_DIR}/${REL_PLUGIN}/Config.txt \
		${DELIVERY_DIR}/${REL_PLUGIN}/exiftool \
		${DELIVERY_DIR}/${REL_PLUGIN}/LICENSE \
		$(LUA_OBJECTS)
	rm -f ${DELIVERY_ARCHIVE_PATH}
	cd ${DELIVERY_DIR} && zip -r ${DELIVERY_ARCHIVE} ${REL_PLUGIN}
	rm -rf ${DELIVERY_DIR}/${REL_PLUGIN}

.PHONY: ${DELIVERY_DIR}/${REL_PLUGIN}
${DELIVERY_DIR}/${REL_PLUGIN}:
	rm -rf ${DELIVERY_DIR}/${REL_PLUGIN}
	mkdir -p ${DELIVERY_DIR}/${REL_PLUGIN}

${DELIVERY_DIR}/${REL_PLUGIN}/Config.txt:
	cp ${DEV_PLUGIN}/Config.txt ${DELIVERY_DIR}/${REL_PLUGIN}

.PHONY: ${DELIVERY_DIR}/${REL_PLUGIN}/exiftool
${DELIVERY_DIR}/${REL_PLUGIN}/exiftool:
	cp -r ${DEV_PLUGIN}/exiftool ${DELIVERY_DIR}/${REL_PLUGIN}

${DELIVERY_DIR}/${REL_PLUGIN}/LICENSE:
	cp LICENSE ${DELIVERY_DIR}/${REL_PLUGIN}

$(LUA_OBJECTS) : $(DELIVERY_DIR)/$(REL_PLUGIN)/%.lua : $(DEV_PLUGIN)/%.lua
	mkdir -p $(shell dirname $@)
	${LUAC} -o $@ $<

.PHONY: test
test:
	@for f in $(shell ls test/*.lua); do	\
		echo Test: $${f}			;		\
		LUA_PATH=${LUA_TEST_PATH} ${LUA} -e "${LUA_TEST_ENV}" $${f} -o TAP || exit 1 				\
	; done
	@echo "ALL TEST PASS"
