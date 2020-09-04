#!/bin/bash

set -euo pipefail

dir="$(dirname "${0}")"
slug="${1}"
solution_dir="${2}"
output_dir="${3}"

printf "representing exercise %q in %q to %q\n" "${slug}" "${solution_dir}" "${output_dir}"

"${dir}/elixir_representer" "${slug}" "${solution_dir}" "${output_dir}"
