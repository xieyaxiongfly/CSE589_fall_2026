#!/usr/bin/env bash
#
# Preview the course website locally.
#
#     ./start-site.sh
#
# Companion to start.sh: that one runs the editing dashboard, this one runs
# the Jekyll site so you can see what the edits actually look like.
#
# Gems install into ~/.gems/cse589-site, never into the project folder or the
# system gem path. The project lives inside Dropbox, and Jekyll's native-extension
# gems (racc, json, eventmachine, ...) are thousands of small files -- Dropbox
# syncing them mid-write corrupts the compiled extensions ("missing extensions"
# errors on start). Same reasoning as start.sh's venv living outside Dropbox.
# macOS ships Ruby 2.6.10, which Jekyll no longer supports and which should
# not be written to anyway. A Homebrew Ruby is required; see the error below.

set -euo pipefail

DASHBOARD_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SITE_ROOT="$(dirname "$DASHBOARD_DIR")"   # same layout app.py assumes
GEMS_ROOT="$HOME/.gems/cse589-site"       # kept outside Dropbox on purpose
PORT=4000

cd "$SITE_ROOT"

# --- Find a usable Ruby -------------------------------------------------------
# /usr/bin/ruby is the system one (2.6.10). Jekyll 4 / github-pages need 3.x,
# and installing gems there needs sudo and pollutes the OS install.
RUBY_BIN=""
for candidate in /opt/homebrew/opt/ruby/bin /usr/local/opt/ruby/bin; do
    if [ -x "$candidate/ruby" ]; then RUBY_BIN="$candidate"; break; fi
done

if [ -z "$RUBY_BIN" ]; then
    cat >&2 <<'EOF'
✗ No Homebrew Ruby found.

  macOS only ships Ruby 2.6.10 (deprecated, unsupported by current Jekyll),
  and installing gems into it requires sudo and modifies the OS.

  Install a self-contained Ruby once:

      brew install ruby

  Then re-run this script. Nothing else on your Mac is affected -- gems for
  this site go into ~/.gems/cse589-site, outside the project.
EOF
    exit 1
fi

export PATH="$RUBY_BIN:$PATH"
export GEM_HOME="$GEMS_ROOT/gems"                 # keep bundler itself out of Dropbox
export PATH="$GEM_HOME/bin:$PATH"
export BUNDLE_PATH="$GEMS_ROOT/bundle"            # keep site gems out of Dropbox

echo "Using Ruby $("$RUBY_BIN/ruby" -e 'print RUBY_VERSION') from $RUBY_BIN"

# --- Bootstrap bundler + gems (first run only) --------------------------------
mkdir -p "$GEMS_ROOT"

if ! command -v bundle >/dev/null 2>&1; then
    echo "→ Installing bundler into $GEM_HOME..."
    gem install bundler --no-document --quiet
fi

if ! bundle check >/dev/null 2>&1; then
    echo "→ Installing/updating site gems into $BUNDLE_PATH (a few minutes)..."
    bundle install
fi

# --- Refuse to double-start ---------------------------------------------------
if lsof -nP -iTCP:"$PORT" -sTCP:LISTEN >/dev/null 2>&1; then
    echo "⚠️  Port $PORT is already in use -- the site may already be running." >&2
    echo "   Check with:  lsof -nP -iTCP:$PORT -sTCP:LISTEN" >&2
    echo "   Stop it with: kill <PID>" >&2
    exit 1
fi

# The site sets baseurl (/CSE589_fall_2026), so pages live under that prefix.
BASEURL="$(awk '/^baseurl:/ {print $2}' _config.yml)"

echo ""
echo "🌐 Site will be at http://localhost:$PORT${BASEURL}/"
echo "   Edits to _data/*.yml rebuild automatically. Ctrl+C to stop."
echo ""

exec bundle exec jekyll serve --port "$PORT" --livereload
