#!/bin/sh
set -eu

here=$(cd "$(dirname "$0")" && pwd)
skein_bin=${SKEIN_BIN:-"$here/../skein-lang/target/release/skein"}
if [ ! -x "$skein_bin" ]; then
    printf '%s\n' "linnet: Skein executable not found at $skein_bin" >&2
    exit 1
fi

# skein-ui comes from git without its renderer: use SKEIN_UI_HOST if it's
# set, else one built in a skein-ui checkout beside this project.
if [ -z "${SKEIN_UI_HOST:-}" ] && [ -x "$here/../skein-libs/skein-ui/target/release/skein-ui-host" ]; then
    SKEIN_UI_HOST="$here/../skein-libs/skein-ui/target/release/skein-ui-host"
    export SKEIN_UI_HOST
fi

cd "$here"
exec "$skein_bin" linnet.skn "$@"
