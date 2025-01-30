#!/usr/bin/env bash
set -e

# @describe List all files and directories tree in a specific directory

# @option --path! The path of the directory to list all files and directories

# @env LLM_OUTPUT=/dev/stdout The output path

main() {
	tree "$argc_path" >> "$LLM_OUTPUT"
}

eval "$(argc --argc-eval "$0" "$@")"
