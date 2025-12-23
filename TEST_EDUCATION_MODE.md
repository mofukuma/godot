# Education Mode テスト手順

## クイックテスト

### Step 1: ビルド

```bash
cd /Users/k/Documents/GitHub/godot

# macOS用にビルド
scons platform=macos target=editor dev_build=yes -j8
```

ビルド時間: 約5-15分（CPUコア数による）

### Step 2: テストプロジェクトの準備

```bash
# yuruttogdディレクトリを使用（既に設定済み）
cd yuruttogd

# プラグインが正しく配置されているか確認
ls -la addons/hello_world_education/
```

以下のファイルが存在するはず：
- `plugin.cfg`
- `plugin.gd`
- `ui/main_panel.tscn`
- `ui/main_panel.gd`

### Step 3: project.godot の確認

`yuruttogd/project.godot` に以下が含まれているか確認：

```ini
[editor_plugins]

enabled=PackedStringArray("res://addons/hello_world_education/plugin.cfg")
```

### Step 4: 起動テスト

```bash
cd /Users/k/Documents/GitHub/godot
./bin/godot.macos.editor.dev.arm64 --editor --path yuruttogd
```

または起動スクリプトを使用：

```bash
cd yuruttogd
./start_education_mode.sh
```

## 期待される動作

### ✅ 成功時の挙動

起動直後に以下のようになるはず：

```
┌────────────────────────────────────────────────┐
│ File ▼                              [×]        │  ← FileメニューとQuitのみ
├────────────────────────────────────────────────┤
│                                                │
│  Hello World - Godot Education System         │
│                                                │
│  Welcome to the Godot Education System!       │
│                                                │
│  This is a full-screen education interface    │
│  running as an EditorPlugin.                  │
│                                                │
│  Features:                                     │
│  • Full-screen main panel                     │
│  • Access to Godot editor APIs                │
│  • Auto-launch on startup                     │
│  • Cross-platform support                     │
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
```

### ✅ チェックリスト

起動後、以下を確認：

- [ ] **タブボタンが表示されない**: 2D/3D/Script等のタブが上部に表示されていない
- [ ] **シーンツリーが表示されない**: 左側にシーンツリーが表示されていない
- [ ] **インスペクタが表示されない**: 右側にインスペクタが表示されていない
- [ ] **シーンタブが表示されない**: 開いているファイルのタブが表示されていない
- [ ] **メニューがFileのみ**: Project/Debug/Settings/Help等のメニューが表示されていない
- [ ] **Fileメニューに"Quit"のみ**: Fileメニューをクリックすると"Quit"オプションだけ表示される
- [ ] **Education UIが全画面**: Hello World画面がウィンドウ全体を占有
- [ ] **Ctrl+1が無効**: Ctrl+1を押しても2Dエディタに切り替わらない
- [ ] **Ctrl+2が無効**: Ctrl+2を押しても3Dエディタに切り替わらない
- [ ] **実行ボタンが表示されない**: 再生/停止ボタンが表示されていない

### ❌ 失敗パターンと対処法

#### パターン1: タブが表示される

**症状**: 上部に2D/3D/Script等のタブが表示される

**原因**: 標準版のGodotを使用している

**対処**:
```bash
# カスタムビルド版を使用しているか確認
./bin/godot.macos.editor.dev.arm64 --version

# もう一度ビルド
scons platform=macos target=editor dev_build=yes
```

#### パターン2: "Education"プラグインが見つからない

**症状**: コンソールに "The editor name 'Education' was not found." エラー

**原因**: プラグインが正しく配置されていない、または有効化されていない

**対処**:
```bash
# プラグインの存在確認
ls -la yuruttogd/addons/hello_world_education/plugin.cfg

# project.godotの確認
grep -A 2 "editor_plugins" yuruttogd/project.godot
```

#### パターン3: シーンツリーやインスペクタが表示される

**症状**: 左側にシーンツリー、右側にインスペクタが表示される

**原因**: `enable_education_mode()` が正しく呼ばれていない

**対処**:
```bash
# コンソール出力を確認
./bin/godot.macos.editor.dev.arm64 --editor --path yuruttogd --verbose
```

コンソールに以下のメッセージが表示されるべき：
```
Enabling full education mode - hiding all editor UI
```

このメッセージが表示されない場合、C++コードの再ビルドが必要。

#### パターン4: ビルドエラー

**症状**: `scons` コマンドがエラーで終了

**対処**:
```bash
# 依存関係を確認
python3 --version  # Python 3.6以上が必要
scons --version    # SCons 4.0以上が必要

# クリーンビルド
scons --clean
scons platform=macos target=editor dev_build=yes -j8
```

## デバッグ

### コンソール出力の確認

起動時に `--verbose` フラグを付けると詳細ログが表示されます：

```bash
./bin/godot.macos.editor.dev.arm64 --editor --path yuruttogd --verbose
```

以下のメッセージが表示されるべき：
1. `"Enabling full education mode - hiding all editor UI"` - enable_education_mode() が呼ばれた
2. プラグインがロードされたメッセージ

### C++コードの確認

修正が反映されているか確認：

```bash
# editor_main_screen.cpp の確認
grep -A 5 "EDUCATION MODE" editor/editor_main_screen.cpp

# editor_node.cpp の確認
grep -A 10 "enable_education_mode" editor/editor_node.cpp

# editor_node.h の確認
grep "enable_education_mode" editor/editor_node.h
```

## 次のステップ

テストが成功したら：

1. **UIのカスタマイズ**: `addons/hello_world_education/ui/main_panel.tscn` を編集
2. **ロジックの追加**: `addons/hello_world_education/ui/main_panel.gd` にコードを追加
3. **レッスンシステムの構築**: 学習コンテンツの追加
4. **配布**: リリース版をビルドして配布

```bash
# リリース版ビルド
scons platform=macos target=editor production=yes
```

## 問題が解決しない場合

1. [BUILD_EDUCATION_MODE.md](BUILD_EDUCATION_MODE.md) のトラブルシューティングを確認
2. [EDUCATION_MODE_README.md](EDUCATION_MODE_README.md) の詳細ドキュメントを確認
3. ビルドログとコンソール出力を保存して、問題を報告

---

**Good luck with testing! 🎓✨**
