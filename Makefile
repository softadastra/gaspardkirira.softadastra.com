# =============================================================
# Project Build & Release Helper
# =============================================================
# Usage:
#   make build               → configure + build (ALL)
#   make run                 → build + run
#   make clean               → delete build folders
#   make rebuild             → full rebuild
#   make commit              → add + commit changes on dev branch
#   make push                → push dev branch
#   make merge               → merge dev → main
#   make release VERSION=vX.Y.Z → full release pipeline
# =============================================================

# ---------- Configuration ----------
VERSION        ?= v0.1.0
BRANCH_DEV     = dev
BRANCH_MAIN    = main

# CMake presets
PRESET         ?= dev-ninja
BUILD_PRESET   ?= $(PRESET)
RUN_PRESET     ?= $(BUILD_PRESET)
CMAKE          ?= cmake

# Mapping connu (configure → build → run)
ifeq ($(PRESET),dev-ninja)
  BUILD_PRESET := build-ninja
  RUN_PRESET   := run-ninja
endif
ifeq ($(PRESET),dev-msvc)
  BUILD_PRESET := build-msvc
  RUN_PRESET   := run-msvc
endif

.PHONY: all build run clean rebuild \
        help commit push merge tag release test changelog preset

# =============================================================
# ------------------- BUILD COMMANDS ---------------------------
# =============================================================

all: build

# Configure + build (ALL)
build:
	@$(CMAKE) --preset $(PRESET)
	@$(CMAKE) --build --preset $(BUILD_PRESET)

# Build + run via preset 'run-*'
run:
	@$(CMAKE) --preset $(PRESET)
	@$(CMAKE) --build --preset $(RUN_PRESET) --target run

# Clean all builds
clean:
	rm -rf build-* CMakeFiles CMakeCache.txt

# Force a full rebuild
rebuild: clean build

# Allow overriding preset from CLI
preset:
	@:

# =============================================================
# -------------------- GIT COMMANDS ----------------------------
# =============================================================

help:
	@echo "Available commands:"
	@echo "  make build/run/clean/rebuild     - Build management"
	@echo "  make commit                      - Commit all files on $(BRANCH_DEV)"
	@echo "  make push                        - Push $(BRANCH_DEV)"
	@echo "  make merge                       - Merge $(BRANCH_DEV) → $(BRANCH_MAIN)"
	@echo "  make tag VERSION=vX.Y.Z          - Create Git tag (default: $(VERSION))"
	@echo "  make release VERSION=vX.Y.Z      - Full release pipeline"
	@echo "  make test                        - Run tests (ctest)"
	@echo "  make changelog                   - Update CHANGELOG.md"

commit:
	git checkout $(BRANCH_DEV)
	@if [ -n "$$(git status --porcelain)" ]; then \
		echo "📝 Committing changes..."; \
		git add .; \
		git commit -m "chore(release): prepare $(VERSION)"; \
	else \
		echo "✅ Nothing to commit."; \
	fi

push:
	git push origin $(BRANCH_DEV)

merge:
	git checkout $(BRANCH_MAIN)
	git merge --no-ff --no-edit $(BRANCH_DEV)
	git push origin $(BRANCH_MAIN)

tag:
	@if git rev-parse $(VERSION) >/dev/null 2>&1; then \
		echo "❌ Tag $(VERSION) already exists."; \
		exit 1; \
	else \
		echo "🏷️  Creating annotated tag $(VERSION)..."; \
		git tag -a $(VERSION) -m "Release version $(VERSION)"; \
		git push origin $(VERSION); \
	fi

release:
	make changelog
	make commit
	make push
	make merge
	make tag VERSION=$(VERSION)

# =============================================================
# --------------------- TESTS / DOCS ---------------------------
# =============================================================

test:
	cd build && ctest --output-on-failure

changelog:
	bash scripts/update_changelog.sh

