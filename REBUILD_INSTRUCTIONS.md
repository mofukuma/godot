# 再ビルドと動作確認手順

## 実装内容

以下の修正を実施しました：

### 変更点

1. **常にUIを非表示**: EDUCATION MODEの条件分岐を削除し、**常に**すべてのUIを非表示にするように変更
2. **タブ切り替え完全無効**: select_next()、select_prev()を常にreturnするように変更
3. **すべてのメニューを非表示**: title_bar、main_menu_bar、main_menu_button、すべての個別メニューを非表示
4. **すべての分割コンテナを非表示**: left/right/main系のすべてのsplitコンテナを非表示
5. **ボトムパネルを非表示**: デバッグコンソール等のボトムパネルを非表示

### 修正ファイル

- [editor/editor_main_screen.cpp](editor/editor_main_screen.cpp) - 条件分岐を削除、常にUI非表示
- [editor/editor_node.cpp](editor/editor_node.cpp) - enable_education_mode()を強化

## ビルド手順

```bash
cd /Users/k/Documents/GitHub/godot

# クリーンビルド（推奨）
scons --clean
scons platform=macos target=editor dev_build=yes -j8

# または増分ビルド
scons platform=macos target=editor dev_build=yes -j8
```

## 起動手順

### 方法1: スクリプトで起動

```bash
cd /Users/k/Documents/GitHub/godot/yuruttogd
./start_education_mode.sh
```

### 方法2: 直接起動

```bash
cd /Users/k/Documents/GitHub/godot
./bin/godot.macos.editor.dev.arm64 --editor --path yuruttogd
```

## 期待される動作

起動後、以下がすべて確認できるはず：

### ✅ 非表示になるUI

- [ ] **タブボタン**: 2D/3D/Script等のタブボタンが表示されない
- [ ] **メニューバー**: File/Project/Debug/Settings/Help/Tool等のすべてのメニューが表示されない
- [ ] **タイトルバー**: ウィンドウ上部のタイトルバーが表示されない
- [ ] **シーンツリー**: 左側のシーンツリーパネルが表示されない
- [ ] **インスペクタ**: 右側のインスペクタパネルが表示されない
- [ ] **ファイルシステム**: ファイルシステムドックが表示されない
- [ ] **シーンタブ**: 開いているファイルのタブが表示されない
- [ ] **実行バー**: 再生/停止/デバッグボタンが表示されない
- [ ] **ボトムパネル**: デバッグコンソール等が表示されない
- [ ] **検索ボタン**: 検索ボタンが表示されない
- [ ] **エクスポートボタン**: エクスポートボタンが表示されない

### ✅ 表示されるUI

- [ ] **Educationプラグイン画面**: Hello World画面が全画面表示される
- [ ] **ウィンドウの閉じるボタンのみ**: macOSの赤い閉じるボタンのみ使用可能

### ✅ 無効化される機能

- [ ] **Ctrl+1/2/3**: タブ切り替えショートカットが無効
- [ ] **タブクリック**: タブボタンがないのでクリック不可
- [ ] **メニュー操作**: メニューが表示されないので操作不可

## 終了方法

以下のいずれかの方法で終了：

1. **ウィンドウの閉じるボタン**: macOSの赤い閉じるボタンをクリック
2. **Cmd+Q**: macOSの標準終了ショートカット
3. **Educationプラグイン内のExitボタン**: プラグインが実装している場合

## トラブルシューティング

### 問題1: メニューがまだ表示される

**考えられる原因**: ビルドが正しく反映されていない

**対処法**:
```bash
cd /Users/k/Documents/GitHub/godot
scons --clean
scons platform=macos target=editor dev_build=yes -j8
```

### 問題2: シーンツリー/インスペクタが表示される

**考えられる原因**: enable_education_mode()が呼ばれていない

**確認方法**:
```bash
./bin/godot.macos.editor.dev.arm64 --editor --path yuruttogd --verbose 2>&1 | grep "Enabling full education mode"
```

このメッセージが表示されるはず：
```
Enabling full education mode - hiding all editor UI
```

表示されない場合、call_deferred()のタイミングの問題が考えられます。

### 問題3: 画面が真っ白

**考えられる原因**: Educationプラグインが正しくロードされていない

**確認方法**:
```bash
ls -la yuruttogd/addons/hello_world_education/
cat yuruttogd/project.godot | grep -A 2 editor_plugins
```

プラグインが存在し、project.godotで有効化されているか確認。

### 問題4: ビルドエラー

**エラー例**: `'bottom_panel' was not declared in this scope`

**対処法**: 該当する変数がeditor_node.hで宣言されているか確認

```bash
grep "bottom_panel" editor/editor_node.h
```

## デバッグ方法

### コンソール出力を確認

```bash
cd /Users/k/Documents/GitHub/godot
./bin/godot.macos.editor.dev.arm64 --editor --path yuruttogd --verbose
```

以下のメッセージが表示されることを確認：
1. `"Enabling full education mode - hiding all editor UI"` - enable_education_mode()が呼ばれた
2. プラグインロードメッセージ

### C++コードの確認

修正が正しく反映されているか確認：

```bash
# editor_main_screen.cppの確認
grep -A 10 "ALWAYS hide" editor/editor_main_screen.cpp

# editor_node.cppの確認
grep -A 50 "enable_education_mode" editor/editor_node.cpp | head -60
```

## 成功時のスクリーンショット

```
┌────────────────────────────────────────────────┐
│                                                │  ← メニューバーなし
│                                                │
│  Hello World - Godot Education System         │
│                                                │
│  Welcome to the Godot Education System!       │
│                                                │
│  This is a full-screen education interface    │
│  running as an EditorPlugin.                  │
│                                                │
│         ┌────────────────┐                     │
│         │ Start Learning │                     │
│         └────────────────┘                     │
│         ┌────────────────┐                     │
│         │   Settings     │                     │
│         └────────────────┘                     │
│         ┌────────────────┐                     │
│         │     Exit       │                     │
│         └────────────────┘                     │
│                                                │
│  Powered by Godot Engine 4.5                  │
└────────────────────────────────────────────────┘

シーンツリー: なし
インスペクタ: なし
タブボタン: なし
メニューバー: なし
```

## 次のステップ

成功したら：

1. **プラグインUIのカスタマイズ**: `yuruttogd/addons/hello_world_education/ui/main_panel.tscn`を編集
2. **教育コンテンツの追加**: GDScriptでレッスンシステムを実装
3. **配布用ビルド**: リリース版をビルド

```bash
# リリース版ビルド
scons platform=macos target=editor production=yes -j8
```

---

**すべてのUIが完全に非表示になるはずです！**
