#!/bin/sh

if ! [ -d ".git" ]; then
    echo "Not in a git repository" >&2
    exit 1
fi

echo "Testing all pre-commit hooks!"
pre-commit try-repo ../ --all-files
