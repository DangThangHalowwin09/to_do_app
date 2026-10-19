#!/usr/bin/env bash
# Cài công cụ cho Claude Code ở mức NGƯỜI DÙNG (~/.claude), dùng được cho mọi dự án Flutter/web trên máy này:
#   1. Skill ui-ux-pro-max (copy từ .claude/skills của dự án này)
#   2. Playwright MCP (để Claude mở trình duyệt, kiểm thử bản web)
# Chạy: bash scripts/setup-claude-tools.sh   (cần: Claude Code CLI, Node.js >= 18)
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SKILL_SRC="$ROOT/.claude/skills/ui-ux-pro-max"
SKILL_DST="$HOME/.claude/skills/ui-ux-pro-max"
PLAYWRIGHT_MCP="@playwright/mcp@0.0.83"

command -v claude >/dev/null || { echo "Chưa cài Claude Code CLI (https://claude.com/claude-code)"; exit 1; }
command -v npx >/dev/null || { echo "Chưa cài Node.js (cần npx)"; exit 1; }

echo "==> Cài skill ui-ux-pro-max vào $SKILL_DST"
mkdir -p "$HOME/.claude/skills"
rm -rf "$SKILL_DST"
cp -r "$SKILL_SRC" "$SKILL_DST"

echo "==> Đăng ký Playwright MCP (phạm vi user)"
claude mcp remove playwright --scope user >/dev/null 2>&1 || true
claude mcp add playwright --scope user -- npx -y "$PLAYWRIGHT_MCP"

echo "==> Tải trình duyệt Chromium cho Playwright"
npx -y playwright@latest install chromium

echo "Xong. Mở lại Claude Code rồi chạy /mcp để kiểm tra 'playwright' đang kết nối."
