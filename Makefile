# =============================================================
# Vix App — Cross-platform build helper
# =============================================================
# Usage:
#   make build               → configure + build (ALL)
#   make run                 → build + run (target 'run')
#   make clean               → delete build folders
#   make rebuild             → full rebuild
#   make preset=name run     → override configure preset (ex: dev-msvc)
#   make BUILD_PRESET=name   → override build preset (ex: build-msvc)
# =============================================================

# Configure preset (CMake 'configurePresets')
PRESET      ?= dev-ninja

# Build preset (CMake 'buildPresets')
# Par défaut on mappe intelligemment PRESET → BUILD_PRESET
BUILD_PRESET ?= $(PRESET)

# Mapping connu (ajoute ici si tu crées d'autres presets)
ifeq ($(PRESET),dev-ninja)
  BUILD_PRESET := build-ninja
endif
ifeq ($(PRESET),dev-msvc)
  BUILD_PRESET := build-msvc
endif

# Run preset (pour lancer la target 'run' via un build preset dédié)
RUN_PRESET ?= $(BUILD_PRESET)
ifeq ($(PRESET),dev-ninja)
  RUN_PRESET := run-ninja
endif
ifeq ($(PRESET),dev-msvc)
  RUN_PRESET := run-msvc
endif

CMAKE  ?= cmake

all: build

# Configure + build (ALL)
build:
	@$(CMAKE) --preset $(PRESET)
	@$(CMAKE) --build --preset $(BUILD_PRESET)

# Build + run via preset 'run-*' (ou BUILD_PRESET si pas de run-*)
run:
	@$(CMAKE) --preset $(PRESET)
	@$(CMAKE) --build --preset $(RUN_PRESET) --target run

# Clean all builds
clean:
	rm -rf build-* CMakeFiles CMakeCache.txt

# Force a full rebuild
rebuild: clean build

# Allow overriding preset from CLI: `make preset=dev-msvc run`
preset:
	@:
