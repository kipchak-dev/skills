#!/bin/bash
# Every case starts in a new project created from the Kipchak starter. AGENTS.md is removed so that the run measures
# what the assistant knows, as in a project created before the starter included it.
set -euo pipefail
composer create-project kipchak/starter . --no-interaction --quiet
rm -f AGENTS.md
