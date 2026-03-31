#!/usr/bin/env bash
set -euo pipefail

repo_root="${1:-.}"
manifest_path="${2:-${repo_root%/}/.release-subprojects.lock}"

cd "${repo_root}"

if ! command -v meson >/dev/null 2>&1; then
        echo "meson is required to prepare subprojects." >&2
        exit 1
fi

mapfile -t wrap_files < <(find subprojects -maxdepth 1 -type f -name '*.wrap' -print | LC_ALL=C sort)
if [ "${#wrap_files[@]}" -eq 0 ]; then
        : > "${manifest_path}"
        exit 0
fi

subprojects=()
for wrap_file in "${wrap_files[@]}"; do
        subprojects+=("$(basename "${wrap_file}" .wrap)")
done

meson subprojects download "${subprojects[@]}"

: > "${manifest_path}"
for subproject in "${subprojects[@]}"; do
        subproject_dir="subprojects/${subproject}"
        if [ -d "${subproject_dir}/.git" ]; then
                remote_url="$(git -C "${subproject_dir}" remote get-url origin 2>/dev/null || printf '%s' 'unknown')"
                revision="$(git -C "${subproject_dir}" rev-parse HEAD)"
        else
                remote_url="archive"
                revision="non-git"
        fi
        printf '%s\t%s\t%s\n' "${subproject}" "${remote_url}" "${revision}" >> "${manifest_path}"
done
