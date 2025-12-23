# Godot Engine - Education Mode ビルド手順

## 概要

Godot Engineに以下の教育モード機能を追加しました：

1. **自動起動**: "Education"プラグインが存在する場合、起動時に自動選択
2. **タブ非表示**: 他のエディタタブ（2D, 3D, Script等）を完全に非表示
3. **タブ切り替え防止**: キーボードショートカットやプログラム的なタブ切り替えを無効化

## 変更したファイル

### editor/editor_main_screen.cpp

3つの修正を加えました：

1. **NOTIFICATION_READY** (行43-54):
   - "Education"プラグインを自動検出
   - 自動選択
   - タブボタンコンテナを非表示化

2. **select()** (行180-185):
   - Educationモードからの切り替えを防止

3. **select_next() / select_prev()** (行139-175):
   - タブ切り替えショートカットを無効化

## ビルド手順

### macOS

```bash
cd /Users/k/Documents/GitHub/godot

# 開発版ビルド（デバッグ用）
scons platform=macos target=editor dev_build=yes

# リリース版ビルド（配布用）
scons platform=macos target=editor production=yes
```

ビルド完了後：
```
bin/godot.macos.editor.dev.universal       # 開発版
bin/godot.macos.editor.universal           # リリース版
```

### Linux

```bash
cd /Users/k/Documents/GitHub/godot

# 開発版
scons platform=linuxbsd target=editor dev_build=yes

# リリース版
scons platform=linuxbsd target=editor production=yes
```

### Windows

```bash
cd /Users/k/Documents/GitHub/godot

# 開発版
scons platform=windows target=editor dev_build=yes

# リリース版
scons platform=windows target=editor production=yes
```

### Android（エディタAPK）

```bash
cd /Users/k/Documents/GitHub/godot

# Android Editor APK
scons platform=android target=editor arch=arm64
cd platform/android/java
./gradlew generateGodotEditor
```

## 使用方法

### 1. プラグインの配置

```bash
# プラグインをプロジェクトに配置
mkdir -p your_project/addons
cp -r /Users/k/Documents/GitHub/godot/addons/hello_world_education your_project/addons/
```

### 2. project.godot の設定

```ini
[editor_plugins]

enabled=PackedStringArray("res://addons/hello_world_education/plugin.cfg")
```

### 3. 起動

```bash
# ビルドしたGodotエディタで起動
./bin/godot.macos.editor.dev.universal --editor --path your_project
```

**結果**:
- ✅ 起動と同時に "Education" タブが自動選択される
- ✅ 他のタブ（2D, 3D, Script等）が完全に非表示
- ✅ キーボードショートカットでタブ切り替え不可
- ✅ 完全な教育モード専用エディタとして動作

## 動作確認

### 正常動作の確認

1. Godotエディタを起動
2. 画面全体が "Hello World Education" パネルで埋まる
3. 上部にタブが**表示されない**
4. Ctrl+1, Ctrl+2 等のショートカットが無効

### 通常モードに戻す方法

プラグインを無効化すれば通常のGodotエディタとして使用できます：

```ini
# project.godot
[editor_plugins]

enabled=PackedStringArray()  # 空にする
```

または、プラグインフォルダを削除：
```bash
rm -rf addons/hello_world_education
```

## カスタマイズ

### プラグイン名の変更

他の名前にしたい場合は、C++コードも変更が必要です：

**editor/editor_main_screen.cpp** の3箇所を変更：
```cpp
// 変更前
if (E.key == "Education") {

// 変更後（例: "Learning"）
if (E.key == "Learning") {
```

プラグイン側も合わせて変更：
```gdscript
# plugin.gd
func _get_plugin_name() -> String:
    return "Learning"  # "Education" から変更
```

## トラブルシューティング

### ビルドエラー

```bash
# 依存関係を再インストール
brew install scons python@3.11

# クリーンビルド
scons --clean
scons platform=macos target=editor dev_build=yes
```

### タブが表示されてしまう

原因: プラグインが正しく読み込まれていない

確認:
```bash
# プラグインの存在確認
ls -la your_project/addons/hello_world_education/plugin.cfg

# project.godotの設定確認
grep "editor_plugins" your_project/project.godot
```

### プラグインが自動選択されない

原因: プラグイン名が一致していない

確認:
```gdscript
# plugin.gd の _get_plugin_name() が "Education" を返すか確認
func _get_plugin_name() -> String:
    return "Education"  # これが必須
```

## 開発者向け情報

### 修正の詳細

#### 1. 自動選択ロジック

```cpp
// NOTIFICATION_READY 内
for (const KeyValue<String, EditorPlugin *> &E : main_editor_plugins) {
    if (E.key == "Education") {
        select_by_name("Education");
        if (button_hb) {
            button_hb->hide();  // タブボタンを非表示
        }
        return;
    }
}
```

#### 2. タブ切り替え防止

```cpp
// select(), select_next(), select_prev() の先頭に追加
if (selected_plugin && selected_plugin->get_plugin_name() == "Education") {
    return;  // Educationモードからは切り替え不可
}
```

### 将来の拡張案

1. **コマンドライン引数**:
   ```cpp
   // main/main.cpp に追加
   } else if (arg == "--education-mode") {
       education_mode_enabled = true;
   ```

2. **設定ファイル**:
   ```cpp
   GLOBAL_DEF("application/run/education_mode", false);
   ```

3. **複数モード対応**:
   ```cpp
   GLOBAL_DEF("application/run/locked_plugin", "");
   // 任意のプラグインをロックできるように
   ```

## まとめ

この修正により、Godot Engineは完全な教育モード専用エディタとして動作します：

- ✅ 自動起動
- ✅ タブ非表示
- ✅ 切り替え不可
- ✅ 全画面教育UI

プラグインを配置するだけで、通常のGodotエディタが教育ソフトウェアに変身します！
