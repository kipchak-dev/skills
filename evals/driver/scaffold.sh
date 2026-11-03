#!/bin/bash
# Every case starts in a new project created from the Kipchak starter. AGENTS.md is removed so that the run measures
# what the assistant knows, as in a project created before the starter included it. The Composer cache is shared
# between runs, so that parallel runs do not each download every package.
set -euo pipefail
export COMPOSER_CACHE_DIR="${TMPDIR:-/tmp}/kipchak-eval-composer-cache"
composer create-project kipchak/starter . --no-interaction --quiet
rm -f AGENTS.md
