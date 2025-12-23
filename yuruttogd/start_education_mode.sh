#!/bin/bash

# Godot Education Mode Launcher
# このスクリプトは教育モードでGodotを起動します

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "========================================="
echo "  Godot Education Mode Launcher"
echo "========================================="
echo ""

# エディタレイアウト設定ディレクトリを作成
mkdir -p .godot/editor

# エディタレイアウト設定を作成（Educationタブを自動選択）
cat > .godot/editor/editor_layout.cfg << 'EOF'
[EditorNode]

editor_main_screen/selected="Education"
EOF

echo "✓ エディタレイアウト設定を作成しました"

# project.godot が存在しない場合は作成
if [ ! -f "project.godot" ]; then
    cat > project.godot << 'EOF'
; Engine configuration file.

config_version=5

[application]

config/name="Godot Education System"
run/main_scene="res://main.tscn"

[editor_plugins]

enabled=PackedStringArray("res://addons/hello_world_education/plugin.cfg")
EOF
    echo "✓ project.godot を作成しました"
fi

# Godotエディタのバイナリを探す
GODOT_BIN=""

if [ -f "bin/godot.macos.editor.dev.arm64" ]; then
    GODOT_BIN="bin/godot.macos.editor.dev.arm64"
elif [ -f "bin/godot.windows.editor.x86_64.exe" ]; then
    GODOT_BIN="bin/godot.windows.editor.x86_64.exe"
else
    echo "❌ エラー: Godotエディタのバイナリが見つかりません"
    echo "   bin/ ディレクトリにビルド済みのエディタを配置してください"
    exit 1
fi

echo "✓ Godotエディタを発見: $GODOT_BIN"
echo ""
echo "========================================="
echo "  教育モードで起動中..."
echo "========================================="
echo ""
echo "注: エディタが起動したら、上部のタブで"
echo "    'Education' を選択してください"
echo ""

# Godotエディタを起動
"$GODOT_BIN" --editor --path .

echo ""
echo "Godotエディタを終了しました"
