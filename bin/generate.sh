#!/bin/bash

dir="$(dirname "${0}")"
slug="${1}"
solution_dir="${2}"

printf "representing exercise %q in %q\n" "${slug}" "${solution_dir}"

"${dir}/elixir_representer" "${slug}" "${solution_dir}"
