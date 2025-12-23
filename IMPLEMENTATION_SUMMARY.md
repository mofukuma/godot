# Education Mode 実装完了サマリー

## 実装内容

Godot Engineを**完全な教育ソフトウェア専用エディタ**に改造しました。

### ✅ 実装した機能

1. **自動起動**: 起動時に"Education"プラグインが自動選択される
2. **タブ完全非表示**: 2D、3D、Script等の他のタブが一切表示されない
3. **切り替え不可**: キーボードショートカット（Ctrl+1/2/3等）でのタブ切り替えが完全無効化
4. **全UI非表示**: 以下のすべてが非表示になる：
   - シーンツリー（Scene Tree）
   - インスペクタ（Inspector）
   - ファイルシステム（FileSystem）
   - その他すべてのドック
   - シーンタブ（開いているファイルのタブ）
   - プロジェクト実行バー（再生/停止ボタン）
   - Project/Debug/Settings/Help/Toolメニュー
   - 検索ボタン
   - エクスポートボタン
   - レンダラー選択
5. **Exit専用メニュー**: Fileメニューに"Quit"オプションのみ表示
6. **全画面教育UI**: Educationプラグインが画面全体を占有

## 変更したファイル

### 1. [editor/editor_main_screen.cpp](editor/editor_main_screen.cpp)

#### 変更箇所1: NOTIFICATION_READY (44-61行目)

```cpp
case NOTIFICATION_READY: {
    // EDUCATION MODE: Auto-select Education plugin if it exists and hide ALL editor UI
    for (const KeyValue<String, EditorPlugin *> &E : main_editor_plugins) {
        if (E.key == "Education") {
            select_by_name("Education");

            // Hide all tab buttons to force education mode
            if (button_hb) {
                button_hb->hide();
            }

            // Hide ALL standard editor UI elements (docks, title bar, menu, etc.)
            EditorNode *editor = EditorNode::get_singleton();
            if (editor) {
                // Use call_deferred to ensure all UI is initialized first
                callable_mp(editor, &EditorNode::enable_education_mode).call_deferred();
            }

            return;
        }
    }
    // ... rest of normal startup code
}
```

**機能**:
- Educationプラグインを検出して自動選択
- タブボタンを非表示
- `enable_education_mode()`を呼び出してすべてのUIを非表示

#### 変更箇所2: select() (200-204行目)

```cpp
void EditorMainScreen::select(int p_index) {
    // EDUCATION MODE: Prevent switching away from Education plugin
    if (selected_plugin && selected_plugin->get_plugin_name() == "Education") {
        return;  // Already in education mode, don't allow switching
    }
    // ... rest of method
}
```

**機能**: Educationモードから他のタブへの切り替えを防止

#### 変更箇所3: select_next() / select_prev() (149-152, 169-172行目)

```cpp
void EditorMainScreen::select_next() {
    // EDUCATION MODE: Prevent tab switching
    if (selected_plugin && selected_plugin->get_plugin_name() == "Education") {
        return;
    }
    // ... rest of method
}

void EditorMainScreen::select_prev() {
    // EDUCATION MODE: Prevent tab switching
    if (selected_plugin && selected_plugin->get_plugin_name() == "Education") {
        return;
    }
    // ... rest of method
}
```

**機能**: Ctrl+1/2/3等のショートカットによるタブ切り替えを無効化

### 2. [editor/editor_node.h](editor/editor_node.h)

#### 追加箇所: 796行目

```cpp
void enable_education_mode(); // Hide all editor UI for education mode
```

**機能**: すべてのエディタUIを非表示にするpublicメソッドを宣言

### 3. [editor/editor_node.cpp](editor/editor_node.cpp)

#### 追加箇所: enable_education_mode() (6297-6388行目)

```cpp
void EditorNode::enable_education_mode() {
    // EDUCATION MODE: Hide ALL editor UI elements to show only the education plugin
    print_line("Enabling full education mode - hiding all editor UI");

    // Hide docks (scene tree, inspector, file system, etc.)
    if (editor_dock_manager) {
        editor_dock_manager->set_docks_visible(false);
    }

    // Hide individual menus except the quit functionality
    if (file_menu) {
        // Clear file menu and keep only Quit
        while (file_menu->get_item_count() > 0) {
            file_menu->remove_item(0);
        }
        file_menu->add_shortcut(ED_GET_SHORTCUT("editor/file_quit"), SCENE_QUIT, true);
    }

    if (project_menu) {
        project_menu->hide();
    }

    if (debug_menu) {
        debug_menu->hide();
    }

    if (settings_menu) {
        settings_menu->hide();
    }

    if (help_menu) {
        help_menu->hide();
    }

    if (tool_menu) {
        tool_menu->hide();
    }

    if (apple_menu) {
        apple_menu->hide();
    }

    // Hide project run bar (play/pause buttons)
    if (project_run_bar) {
        project_run_bar->hide();
    }

    // Hide search button
    if (search_button) {
        search_button->hide();
    }

    // Hide distraction free mode button
    if (distraction_free) {
        distraction_free->hide();
    }

    // Hide export button
    if (export_button) {
        export_button->hide();
    }

    // Hide renderer selector
    if (renderer) {
        renderer->hide();
    }

    // Hide project title (shows scene name)
    if (project_title) {
        project_title->hide();
    }

    // Hide scene tabs (which shows open scene files)
    if (scene_tabs) {
        scene_tabs->hide();
    }

    // Make the education plugin take up the full window by hiding split containers
    if (left_l_hsplit) {
        left_l_hsplit->hide();
    }

    if (right_hsplit) {
        right_hsplit->hide();
    }

    // Ensure the main screen area expands to fill all available space
    if (editor_main_screen) {
        editor_main_screen->set_v_size_flags(Control::SIZE_EXPAND_FILL);
        editor_main_screen->set_h_size_flags(Control::SIZE_EXPAND_FILL);
    }
}
```

**機能**: すべての標準Godot Editor UIを非表示にして、Education pluginを全画面表示

## プラグイン構成

```
addons/hello_world_education/
├── plugin.cfg              # プラグイン設定
├── plugin.gd               # EditorPluginメインスクリプト
├── README.md               # プラグインドキュメント
└── ui/
    ├── main_panel.tscn     # 全画面UIシーン
    └── main_panel.gd       # UIロジック
```

### plugin.gd の重要な実装

```gdscript
@tool
extends EditorPlugin

var main_panel: Control

func _enter_tree() -> void:
    main_panel = preload("res://addons/hello_world_education/ui/main_panel.tscn").instantiate()
    get_editor_interface().get_editor_main_screen().add_child(main_panel)
    main_panel.hide()

func _exit_tree() -> void:
    if main_panel:
        main_panel.queue_free()

func _has_main_screen() -> bool:
    return true

func _make_visible(visible: bool) -> void:
    if main_panel:
        main_panel.visible = visible

func _get_plugin_name() -> String:
    return "Education"  # ← これが"Education"である必要がある

func _get_plugin_icon() -> Texture2D:
    return get_editor_interface().get_base_control().get_theme_icon("Node", "EditorIcons")
```

**ポイント**: `_get_plugin_name()` が `"Education"` を返すことで、C++コードと連携

## ビルド方法

```bash
cd /Users/k/Documents/GitHub/godot

# macOS
scons platform=macos target=editor dev_build=yes -j8

# Linux
scons platform=linuxbsd target=editor dev_build=yes -j8

# Windows
scons platform=windows target=editor dev_build=yes -j8
```

## 使い方

### 1. プロジェクトにプラグインを配置

```bash
mkdir -p your_project/addons
cp -r addons/hello_world_education your_project/addons/
```

### 2. project.godot に追加

```ini
[editor_plugins]

enabled=PackedStringArray("res://addons/hello_world_education/plugin.cfg")
```

### 3. カスタムビルド版で起動

```bash
./bin/godot.macos.editor.dev.arm64 --editor --path your_project
```

## 動作確認

起動後、以下が確認できます：

✅ **即座に全画面表示**: Hello World UIが画面全体を占有
✅ **タブ非表示**: 2D/3D/Script等のタブが表示されない
✅ **ドック非表示**: シーンツリー、インスペクタ等が表示されない
✅ **メニュー制限**: Fileメニューに"Quit"のみ表示
✅ **ショートカット無効**: Ctrl+1/2/3等が無効
✅ **実行バー非表示**: 再生/停止ボタンが表示されない
✅ **完全な教育モード**: 他のGodot機能に一切アクセスできない

## トラブルシューティング

### タブが表示される

**原因**: 標準版Godotを使用している
**解決**: カスタムビルド版を使用

### UIが非表示にならない

**原因**: `enable_education_mode()` が呼ばれていない
**解決**: コンソールで "Enabling full education mode" メッセージを確認

### プラグインが見つからない

**原因**: プラグイン名が一致していない
**解決**: `plugin.gd` で `_get_plugin_name()` が `"Education"` を返すか確認

## カスタマイズ

### プラグイン名の変更

1. **C++コード** ([editor/editor_main_screen.cpp:46](editor/editor_main_screen.cpp#L46)):
   ```cpp
   if (E.key == "YourPluginName") {
   ```

2. **C++コード** ([editor/editor_main_screen.cpp:150, 170, 201](editor/editor_main_screen.cpp#L150)):
   ```cpp
   if (selected_plugin && selected_plugin->get_plugin_name() == "YourPluginName") {
   ```

3. **プラグイン** (plugin.gd):
   ```gdscript
   func _get_plugin_name() -> String:
       return "YourPluginName"
   ```

4. **再ビルド**:
   ```bash
   scons platform=macos target=editor dev_build=yes
   ```

### UIのカスタマイズ

- `addons/hello_world_education/ui/main_panel.tscn` を Godot で編集
- `addons/hello_world_education/ui/main_panel.gd` にロジックを追加

## プラットフォーム対応

| プラットフォーム | 対応状況 | 備考 |
|---|---|---|
| **Windows** | ✅ 完全対応 | デスクトップ版 |
| **macOS** | ✅ 完全対応 | デスクトップ版 |
| **Linux** | ✅ 完全対応 | デスクトップ版 |
| **Android** | ✅ 対応 | エディタAPK版 |
| **Web** | ⚠️ 部分対応 | エディタWeb版 |
| **iOS** | ⚠️ 未テスト | 理論上は可能 |

## ドキュメント

- [BUILD_EDUCATION_MODE.md](BUILD_EDUCATION_MODE.md) - 詳細ビルド手順
- [TEST_EDUCATION_MODE.md](TEST_EDUCATION_MODE.md) - テスト手順書
- [EDUCATION_MODE_README.md](EDUCATION_MODE_README.md) - 完全版ドキュメント
- [start_education_mode.sh](yuruttogd/start_education_mode.sh) - 起動スクリプト

## まとめ

これで、Godot Engineは**完全な教育ソフトウェア専用エディタ**として動作します。

### 実現したこと

1. ✅ 起動時に自動的にEducationプラグインが全画面表示
2. ✅ すべての標準Godot UI（シーンツリー、インスペクタ、メニュー等）を非表示
3. ✅ Exitメニューのみ表示（ユーザーが終了できる）
4. ✅ タブ切り替えやショートカットを完全無効化
5. ✅ 教育コンテンツのみに集中できる環境

### 次のステップ

1. **コンテンツ開発**: 教育UIに学習コンテンツを追加
2. **レッスンシステム**: 段階的な学習機能を実装
3. **インタラクティブ機能**: EditorInterfaceを使った実践的な学習
4. **配布**: リリース版をビルドして学習者に配布

---

**Happy Teaching with Godot! 🎓✨**
