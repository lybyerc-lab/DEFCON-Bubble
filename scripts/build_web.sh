#!/usr/bin/env bash
set -euo pipefail

GODOT_VERSION="4.7.1-stable"
GODOT_DIR="${PWD}/.godot-web"
GODOT_BIN="${GODOT_DIR}/Godot_v4.7.1-stable_linux.x86_64"
TEMPLATE_ROOT="${HOME}/.local/share/godot/export_templates/4.7.1.stable"

mkdir -p "${GODOT_DIR}" "${TEMPLATE_ROOT}" build/web

if [ ! -x "${GODOT_BIN}" ]; then
  curl -fL --retry 3 -o /tmp/godot.zip "https://github.com/godotengine/godot/releases/download/${GODOT_VERSION}/Godot_v4.7.1-stable_linux.x86_64.zip"
  unzip -q /tmp/godot.zip -d "${GODOT_DIR}"
  chmod +x "${GODOT_BIN}"
fi

if [ ! -f "${TEMPLATE_ROOT}/web_release.zip" ]; then
  curl -fL --retry 3 -o /tmp/godot-templates.tpz "https://github.com/godotengine/godot/releases/download/${GODOT_VERSION}/Godot_v4.7.1-stable_export_templates.tpz"
  rm -rf /tmp/godot-export-templates
  mkdir -p /tmp/godot-export-templates
  unzip -q /tmp/godot-templates.tpz -d /tmp/godot-export-templates
  cp -R /tmp/godot-export-templates/templates/. "${TEMPLATE_ROOT}/"
fi

"${GODOT_BIN}" --headless --path . --import
"${GODOT_BIN}" --headless --path . --export-release Web build/web/index.html

test -f build/web/index.html
