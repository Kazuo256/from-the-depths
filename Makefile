
GAME_DIR=game
LIBS_DIR=$(GAME_DIR)/lib

LUX_LIB=$(LIBS_DIR)/lux
LUX_REPO=externals/luxproject

IMGUI_LIB=imgui.so
IMGUI_REPO=externals/love-imgui
IMGUI_BUILD_DIR=externals/love-imgui/build

CPML_LIB=$(LIBS_DIR)/cpml
CPML_REPO=externals/cpml

TOML_LIB=$(LIBS_DIR)/toml.lua
TOML_REPO=externals/lua-toml

DEPENDENCIES=$(LUX_LIB) $(IMGUI_LIB) $(CPML_LIB) $(TOML_LIB)

## MAIN TARGETS

all: $(DEPENDENCIES)
	love game $(FLAGS)

update:
	cd $(LUX_REPO); git pull

## LUX

$(LUX_LIB): $(LUX_REPO)
	cp -r $(LUX_REPO)/lib/lux $(LUX_LIB)

$(LUX_REPO):
	git clone https://github.com/Kazuo256/luxproject.git $(LUX_REPO)

## IMGUI

$(IMGUI_LIB): $(IMGUI_BUILD_DIR)
	cd $(IMGUI_BUILD_DIR); cmake .. && $(MAKE)
	cp $(IMGUI_BUILD_DIR)/imgui.so $(IMGUI_LIB)

$(IMGUI_BUILD_DIR): $(IMGUI_REPO)
	mkdir $(IMGUI_BUILD_DIR)

$(IMGUI_REPO):
	git clone -b 0.8 https://github.com/slages/love-imgui.git $(IMGUI_REPO)

## CPML

$(CPML_LIB): $(CPML_REPO)
	mkdir $(CPML_LIB)
	cp -r $(CPML_REPO)/modules $(CPML_LIB)
	cp -r $(CPML_REPO)/init.lua $(CPML_LIB)

$(CPML_REPO):
	git clone https://github.com/excessive/cpml.git $(CPML_REPO)

## TOML

$(TOML_LIB): $(TOML_REPO)
	cp $(TOML_REPO)/toml.lua $(TOML_LIB)

$(TOML_REPO):
	git clone -b v1.0.1 https://github.com/jonstoler/lua-toml.git $(TOML_REPO)

## CLEAN UP

.PHONY: clean
clean:
	rm -rf $(DEPENDENCIES)

.PHONY: purge
purge: clean
	rm -rf externals/*

