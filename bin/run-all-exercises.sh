#!/usr/bin/env bash

exercise_dir="elixir/exercises"
tmp_exercise_dir="tmp-exercises"
rm -rf "${tmp_exercise_dir}"
mkdir -p "${tmp_exercise_dir}"
cp -R ${exercise_dir}/practice/* "${tmp_exercise_dir}"
cp -R ${exercise_dir}/concept/* "${tmp_exercise_dir}"

exercises=$(echo $tmp_exercise_dir/*)

exercise_count=0
pass_count=0
fail_count=0

# Iterate over all exercises
for test_dir in $exercises
do
  exercise_count=$((exercise_count+1))

  test_dir_name=$(basename "${test_dir}")
  test_dir_path=$(realpath "${test_dir}")

  printf "\\033[33mRepresenting\\033[0m: "; printf '%s' "${test_dir_name} "

  exercise_config="$test_dir/.meta/config.json"
  files_to_remove=($(jq -r '.files.solution[]' "${exercise_config}"))

  # Move the example into the lib file
  for file in "${files_to_remove[@]}"
  do
    rm -r "${test_dir:?}/$file"
  done

  # concept exercises have "exemplar" solutions (ideal, to be strived to)
  if [ -f "${test_dir:?}/.meta/exemplar.ex" ]; then
    mv "${test_dir:?}/.meta/exemplar.ex" "${test_dir:?}/lib/solution.ex"
  fi

  # practice exercises have "example" solutions (one of many possible solutions with no single ideal approach)
  if [ -f "${test_dir:?}/.meta/example.ex" ]; then
    mv "${test_dir:?}/.meta/example.ex" "${test_dir:?}/lib/solution.ex"
  fi

  mkdir "${test_dir_path}/out"
  # shellcheck disable=SC2034
  single_run_result=$(bin/run.sh "${test_dir_name}" "${test_dir_path}" "${test_dir_path}")
  single_run_exit_code="$?"

  if [ "${single_run_exit_code}" -eq 0 ]
  then
    printf "\\033[32mPass\\033[0m\n"
    pass_count=$((pass_count+1))
  else
    fail_count=$((fail_count+1))
    failing_representations+=( $test_dir_name )
    printf "\\033[31mFail\\033[0m\n"
  fi

  printf -- '-%.0s' {1..80}; echo ""
done

# clean up
rm -rf tmp-exercises

# report
printf -- '-%.0s' {1..80}; echo ""
printf '%s\n' "${pass_count}/${exercise_count} exercises represented successfully.";

if [ "${fail_count}" -eq 0 ]
then
  # everything is good, exit
  exit 0;
else
  # There was at least one problem, list the exercises with problems.
  printf '%s\n' "${fail_count} representation(s) failing:"

  for exercise in "${failing_representations[@]}"
  do
    printf '%s\n' " - ${exercise}"
  done

  exit 1;
fi
