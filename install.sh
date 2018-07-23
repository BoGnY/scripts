#!/bin/sh

if ! [ -d ".git" ]; then
    echo "Not in a git repository" >&2
    exit 1
fi

if ! command -v pre-commit &>/dev/null; then
    echo "Installing pre-commit package!"
    pip install pre-commit
fi

echo "Installing pre-commit hooks into .git hooks dir!"
pre-commit install

echo "Creating pre-commit package config file!"
tee .pre-commit-config.yaml <<EOF >/dev/null
# Pre-commit configuration file
# @see http://pre-commit.com/

fail_fast: false

repos:
-   repo: https://github.com/pre-commit/pre-commit-hooks
    rev: v1.3.0
    hooks:
    -   id: check-executables-have-shebangs
        files: ^\.(sh)$
    -   id: check-json
    -   id: check-symlinks
    -   id: check-yaml
    -   id: detect-private-key
    -   id: end-of-file-fixer
    -   id: mixed-line-ending
    -   id: trailing-whitespace
-   repo: https://github.com/pre-commit/pre-commit
    rev: v1.7.0
    hooks:
    -   id: validate_manifest
-   repo: https://github.com/Lucas-C/pre-commit-hooks
    rev: v1.1.5
    hooks:
    -   id: remove-tabs
        args: [ --whitespaces-count, '4' ]
        exclude_types: [text, markdown]
- repo: https://github.com/BoGnY/pre-commit-hooks
  rev: master
  hooks:
    -   id: remove-byte-order-mark
EOF

echo "Installing all pre-commit hooks from config file!"
pre-commit install-hooks

# Starting by Git v2.9.0 hooks dir can be set using `git config core.hooksPath`

SCRIPT_DIR=$(pwd)"/scripts/git-hooks"
DESTINATION_DIR="./.git/hooks"
SCRIPTS=$(ls "$SCRIPT_DIR" | tr "\n" " ")

for SCRIPT in $SCRIPTS; do
    if ! [[ -d "$SCRIPT_DIR/$SCRIPT" || -L "$SCRIPT_DIR/$SCRIPT" ]]; then
        ln -fns "$SCRIPT_DIR/$SCRIPT" "$DESTINATION_DIR/$SCRIPT"
        chmod +x "$DESTINATION_DIR/$SCRIPT"
        if [ -e "$DESTINATION_DIR/$SCRIPT" ]; then
            echo "Hook $SCRIPT successfully installed!"
        else
            echo "Error while installing $SCRIPT's hook!"
        fi
    fi
done
