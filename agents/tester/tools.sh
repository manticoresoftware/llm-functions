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
	if /Users/dk/work/dev/manticore/manticoresearch/clt/clt test -d -t "$argc_path" ghcr.io/manticoresoftware/manticoresearch:test-kit-latest > $tmp_path; then
		echo "Test passed! Job done" >> "$LLM_OUTPUT"
	else
		output=$(cat "${argc_path//.rec/.rep}")
		{
			echo "Test failed, please review and repeat."
			echo "Here is the output of all test:"
			echo "\`\`\`"
			echo "$output"
			echo "\`\`\`"
			echo "And here are the diff that you should fix."
			echo "- ..."
			echo "+ ..."
			echo "It means that line in - not match in + and + .. is actual output of the test."
			echo "Look and fix it to match or if you think this is error in behaviour of the test, please report it."
			echo "\`\`\`"
			cat "$tmp_path"
			echo "\`\`\`"

		} >> "$LLM_OUTPUT"
	fi
	cat "$tmp_path"
}

# See more details at https://github.com/sigoden/argc
eval "$(argc --argc-eval "$0" "$@")"
