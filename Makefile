# The Skein executable: the sibling skein-lang checkout's release build when
# there is one, otherwise skein on PATH.
SKEIN ?= $(if $(wildcard ../skein-lang/target/release/skein),$(CURDIR)/../skein-lang/target/release/skein,skein)

# skein-ui comes from git without its renderer: SKEIN_UI_HOST, else one built
# in a skein-ui checkout beside this project.
SKEIN_UI_HOST ?= $(wildcard $(CURDIR)/../skein-libs/skein-ui/target/release/skein-ui-host)
export SKEIN_UI_HOST

.PHONY: test fixtures screenshots readme-screenshot run package
test:
	SKEIN_UI_HEADLESS=1 "$(SKEIN)" test --serial tests

# Silent, tagged MP3s in folders, for the tests (needs ffmpeg with libmp3lame).
fixtures:
	tools/make-fixtures.sh

screenshots:
	SKEIN_UI_HEADLESS=1 "$(SKEIN)" tools/screenshots.skn shots

readme-screenshot:
	SKEIN_UI_HEADLESS=1 "$(SKEIN)" tools/readme-screenshot.skn

run:
	./run.sh

# dist/: the targets skein.edn's :package names, the renderer SKEIN_UI_HOST's.
# For Windows: make package ARGS="--windows --launcher …/skein.exe --helper skein-ui-host=…/skein-ui-host.exe"
package:
	"$(SKEIN)" package $(ARGS)
