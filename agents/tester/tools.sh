#!/usr/bin/env bash
set -e

# @env LLM_OUTPUT=/dev/stdout The output path

ROOT_DIR="${LLM_ROOT_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)}"

# @cmd Create a new file at the specified path with contents.
# @option --path! The path where the file should be created
# @option --contents! The contents of the file
fs_create() {
    "$ROOT_DIR/utils/guard_path.sh" "$argc_path" "Create '$argc_path'?"
    mkdir -p "$(dirname "$argc_path")"
    printf "%s" "$argc_contents" > "$argc_path"
    echo "File created: $argc_path" >> "$LLM_OUTPUT"
}


# @cmd Run a given CLT test from .rec file.
# @option --path! The path to .rec file to run test from
fs_clt_test() {
	"$ROOT_DIR/utils/guard_path.sh" "$argc_path" "Run CLT test from  '$argc_path'?"
	tmp_path=$(mktemp)
	if clt test -d -t "$argc_path" ghcr.io/manticoresoftware/manticoresearch:test-kit-latest > $tmp_path; then
		echo "Test passed! Job done" >> "$LLM_OUTPUT"
	else
		# output=$(cat "${argc_path//.rec/.rep}")
		{
			echo "Test failed:"
			cat "$tmp_path" | sed "s/\x1B\[[0-9;]*[JKmsu]//g"
		}>> "$LLM_OUTPUT"
	fi
	cat "$tmp_path"
}

# @cmd List all tests we have in working directory test/clt-tests
fs_list_tests() {
	tree -P "*.rec*" --prune test/clt-tests >> "$LLM_OUTPUT"
}

# cmd List all manuals docs we have in .md format with documentation
fs_list_docs() {
	tree -P "*.md" --prune manual >> "$LLM_OUTPUT"
}

# See more details at https://github.com/sigoden/argc
eval "$(argc --argc-eval "$0" "$@")"
