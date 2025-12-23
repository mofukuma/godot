# Godot Engine - Education Mode Setup Guide

## 概要

Godot Engineを改造して、起動時に自動的に教育用プラグインを全画面で表示する方法。

## 作成したファイル

### 1. EditorPluginファイル

```
addons/hello_world_education/
├── plugin.cfg              # プラグイン設定
├── plugin.gd               # プラグインスクリプト
└── ui/
    ├── main_panel.tscn     # メインパネルシーン
    └── main_panel.gd       # メインパネルスクリプト
```

### 2. プラグインの機能

- **全画面メインパネル**: エディタのメインスクリーン領域全体を占有
- **Hello Worldインターフェース**: シンプルなボタンUI
- **終了機能**: アプリケーション終了ボタン

## Godot Engine改造方法

### ステップ1: プロジェクト設定に教育モードフラグを追加

**ファイル**: `core/config/project_settings.h`

```cpp
// 教育モード設定を追加
GLOBAL_DEF("application/run/education_mode", false);
GLOBAL_DEF("application/run/education_plugin_path", "res://addons/hello_world_education");
```

### ステップ2: エディタ起動時にプラグインを自動有効化

**ファイル**: `editor/editor_node.cpp`

**場所**: EditorNodeコンストラクタ、または初期化関数内

```cpp
// EditorNodeの初期化処理内に追加
void EditorNode::_load_education_mode_if_enabled() {
    // 教育モードが有効かチェック
    bool education_mode = GLOBAL_GET("application/run/education_mode");

    if (education_mode) {
        String plugin_path = GLOBAL_GET("application/run/education_plugin_path");

        // プラグインを有効化
        EditorPluginRegistry::register_plugin(plugin_path);

        // プラグインをロード
        EditorPlugin *education_plugin = EditorPluginRegistry::get_plugin(plugin_path);

        if (education_plugin && education_plugin->has_main_screen()) {
            // メインスクリーンとして選択
            call_deferred("_select_education_screen", plugin_path);
        }
    }
}

void EditorNode::_select_education_screen(const String &plugin_path) {
    // プラグイン名を取得
    EditorPlugin *plugin = EditorPluginRegistry::get_plugin(plugin_path);
    if (plugin) {
        String plugin_name = plugin->get_plugin_name();
        editor_main_screen->select_by_name(plugin_name);
    }
}
```

### ステップ3: より簡易的な方法（推奨）

**project.godot に設定を追加**:

```ini
[application]

run/education_mode=true
run/education_plugin="res://addons/hello_world_education"
run/auto_select_screen="Education"

[editor_plugins]

enabled=PackedStringArray("res://addons/hello_world_education/plugin.cfg")
```

**editor/editor_node.cpp の該当箇所を探す**:

```cpp
// EditorNodeの初期化後、シーン読み込み前に呼ばれる箇所
void EditorNode::_notification(int p_what) {
    switch (p_what) {
        case NOTIFICATION_READY: {
            // 既存コード...

            // 教育モード自動選択を追加
            String auto_screen = GLOBAL_GET("application/run/auto_select_screen");
            if (!auto_screen.is_empty()) {
                call_deferred("_select_main_screen_by_name", auto_screen);
            }
        } break;
    }
}

void EditorNode::_select_main_screen_by_name(const String &p_name) {
    editor_main_screen->select_by_name(p_name);
}
```

## 実装オプション

### オプションA: コマンドライン引数で起動

最も簡単な方法は、Godotをビルドして専用の起動スクリプトを作成：

```bash
#!/bin/bash
# launch_education_mode.sh

./godot.macos.editor.dev.universal --editor --education-mode
```

**main/main.cpp に引数処理を追加**:

```cpp
// main.cpp の引数パース処理に追加
} else if (arg == "--education-mode") {
    // 教育モードフラグを設定
    ProjectSettings::get_singleton()->set("application/run/education_mode", true);
    ProjectSettings::get_singleton()->set("application/run/auto_select_screen", "Education");
```

### オプションB: 専用ビルドターゲット作成

**SConstruct または platform specific build file**:

```python
# 教育版ビルド設定
if env["target"] == "education":
    env.Append(CPPDEFINES=["EDUCATION_BUILD"])
```

**コード内で条件コンパイル**:

```cpp
#ifdef EDUCATION_BUILD
    // 教育モード機能を有効化
    ProjectSettings::get_singleton()->set("application/run/education_mode", true);
#endif
```

### オプションC: project.godot の自動生成

教育版配布用に、起動時に project.godot を自動生成：

**create_education_project.sh**:

```bash
#!/bin/bash

cat > project.godot << 'EOF'
; Engine configuration file.

config_version=5

[application]

config/name="Godot Education System"
run/main_scene="res://addons/hello_world_education/ui/main_panel.tscn"
run/education_mode=true
run/auto_select_screen="Education"

[editor_plugins]

enabled=PackedStringArray("res://addons/hello_world_education/plugin.cfg")

[display]

window/size/viewport_width=1280
window/size/viewport_height=720
EOF

./godot --editor --path .
```

## 最も簡単な実装（推奨）

### 1. プラグインの作成（完了済み）

✅ `addons/hello_world_education/` フォルダ作成済み

### 2. project.godot を修正

```ini
[application]

config/name="Godot Education System"
run/main_scene="res://main.tscn"

[editor_plugins]

enabled=PackedStringArray("res://addons/hello_world_education/plugin.cfg")
```

### 3. エディタ設定ファイルを修正

**~/.godot/editor_settings-4.tres** または **.godot/editor/editor_layout.cfg**:

```ini
[EditorNode]

editor_main_screen/selected="Education"
```

### 4. 起動スクリプト作成

```bash
#!/bin/bash
# start_education.sh

# エディタ設定を上書き
mkdir -p .godot/editor
cat > .godot/editor/editor_layout.cfg << 'EOF'
[EditorNode]
editor_main_screen/selected="Education"
EOF

# Godotエディタを起動
./godot --editor --path .
```

## Android版対応

Android版Godot Editorでも同様の手法が使えます：

1. プラグインをAndroid互換にする
2. `project.godot` に設定を追加
3. Android版Godotエディタで起動

## テスト手順

### ステップ1: 通常起動でプラグインを確認

```bash
cd /Users/k/Documents/GitHub/godot
./bin/godot.macos.editor.dev.universal --editor --path .
```

エディタで：
1. プロジェクト設定 > プラグイン
2. "Hello World Education" を有効化
3. 上部のタブで "Education" を選択
4. Hello Worldパネルが表示されることを確認

### ステップ2: 自動起動の実装

最も簡単な方法は、エディタ設定ファイルの pre-generation です。

## 次のステップ

1. ✅ シンプルなHello Worldプラグインの作成（完了）
2. 🔄 起動時自動選択の実装（要C++修正またはスクリプト）
3. ⬜ 教育UIの拡張（レッスン、演習機能）
4. ⬜ クロスプラットフォームテスト

## 参考ファイル

- [editor/editor_node.cpp](editor/editor_node.cpp) - エディタメイン
- [editor/editor_main_screen.cpp](editor/editor_main_screen.cpp) - メインスクリーン管理
- [editor/plugins/editor_plugin.cpp](editor/plugins/editor_plugin.cpp) - プラグイン基底
- [core/config/project_settings.cpp](core/config/project_settings.cpp) - プロジェクト設定
