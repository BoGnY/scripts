#!/bin/sh

if ! [ -d ".git" ]; then
    echo "Not in a git repository" >&2
    exit 1
fi

echo "Updating pre-commit package!"
pip install pre-commit

echo "Updating all pre-commit hooks!"
pre-commit autoupdate
