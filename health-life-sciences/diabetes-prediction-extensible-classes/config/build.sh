#!/usr/bin/env bash

set -euo pipefail

python -m venv --system-site-packages pharmmod
. pharmmod/bin/activate

pip install --upgrade pip uv
uv pip install -r requirements.txt --force-reinstall --upgrade


python -m ipykernel install --user --name=pharmmod


deactivate

# rm -rf pharmmod