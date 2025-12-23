#!/bin/bash

# Godot Education Mode Launcher
# このスクリプトは教育モード（カスタムビルド版）でGodotを起動します

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "========================================="
echo "  Godot Education Mode Launcher"
echo "  (カスタムビルド版 - 自動全画面)"
echo "========================================="
echo ""

# エディタレイアウト設定ディレクトリを作成
mkdir -p .godot/editor

# エディタレイアウト設定を作成（念のため）
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

if [ -f "bin/godot.macos.editor.dev.universal" ]; then
    GODOT_BIN="bin/godot.macos.editor.dev.universal"
elif [ -f "bin/godot.macos.editor.universal" ]; then
    GODOT_BIN="bin/godot.macos.editor.universal"
elif [ -f "bin/godot.macos.editor.dev.arm64" ]; then
    GODOT_BIN="bin/godot.macos.editor.dev.arm64"
elif [ -f "bin/godot.linuxbsd.editor.dev.x86_64" ]; then
    GODOT_BIN="bin/godot.linuxbsd.editor.dev.x86_64"
elif [ -f "bin/godot.linuxbsd.editor.x86_64" ]; then
    GODOT_BIN="bin/godot.linuxbsd.editor.x86_64"
elif [ -f "bin/godot.windows.editor.dev.x86_64.exe" ]; then
    GODOT_BIN="bin/godot.windows.editor.dev.x86_64.exe"
elif [ -f "bin/godot.windows.editor.x86_64.exe" ]; then
    GODOT_BIN="bin/godot.windows.editor.x86_64.exe"
else
    echo "❌ エラー: Godotエディタのバイナリが見つかりません"
    echo ""
    echo "カスタムビルドを作成してください："
    echo "  scons platform=macos target=editor dev_build=yes"
    echo ""
    echo "詳細は BUILD_EDUCATION_MODE.md を参照"
    exit 1
fi

echo "✓ Godotエディタを発見: $GODOT_BIN"
echo ""
echo "========================================="
echo "  教育モードで起動中..."
echo "========================================="
echo ""
echo "✨ カスタムビルド版の機能："
echo "   • Educationタブが自動選択されます"
echo "   • 他のタブ（2D, 3D等）は完全に非表示"
echo "   • タブ切り替えは無効化されています"
echo ""
echo "   完全な全画面教育モードをお楽しみください！"
echo ""

# Godotエディタを起動
"$GODOT_BIN" --editor --path .

echo ""
echo "Godotエディタを終了しました"
