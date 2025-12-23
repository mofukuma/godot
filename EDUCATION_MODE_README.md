# Godot Engine - 教育モード完全版

## 🎓 概要

Godot Engineを**完全な教育ソフトウェア専用エディタ**に改造しました。

### ✨ 実装した機能

1. ✅ **自動起動**: 起動時に"Education"プラグインが自動選択
2. ✅ **タブ完全非表示**: 2D、3D、Script等の他のタブが表示されない
3. ✅ **切り替え不可**: キーボードショートカットでのタブ切り替えを完全無効化
4. ✅ **全画面教育UI**: エディタ全体が教育プラグインのUIで占有

## 📁 作成したファイル

### 1. EditorPlugin（教育UI）
```
addons/hello_world_education/
├── plugin.cfg              # プラグイン設定
├── plugin.gd               # EditorPluginメインスクリプト
├── README.md               # プラグインドキュメント
└── ui/
    ├── main_panel.tscn     # 全画面UIシーン
    └── main_panel.gd       # UIロジック
```

### 2. C++エンジン改造
- `editor/editor_main_screen.cpp` - 3箇所の修正
  - NOTIFICATION_READY: 自動選択 + タブ非表示
  - select(): タブ切り替え防止
  - select_next/prev(): ショートカット無効化

### 3. ドキュメント
- `BUILD_EDUCATION_MODE.md` - ビルド手順書
- `EDUCATION_MODE_SETUP.md` - 詳細セットアップガイド
- `EDUCATION_MODE_README.md` - このファイル

### 4. 起動スクリプト
- `start_education_mode.sh` - ワンクリック起動

## 🚀 クイックスタート

### Step 1: ビルド

```bash
cd /Users/k/Documents/GitHub/godot

# macOS
scons platform=macos target=editor dev_build=yes

# Linux
scons platform=linuxbsd target=editor dev_build=yes

# Windows
scons platform=windows target=editor dev_build=yes
```

### Step 2: プラグイン配置

```bash
# プロジェクトディレクトリにプラグインをコピー
mkdir -p your_project/addons
cp -r addons/hello_world_education your_project/addons/
```

### Step 3: プロジェクト設定

`your_project/project.godot` に追加：

```ini
[editor_plugins]

enabled=PackedStringArray("res://addons/hello_world_education/plugin.cfg")
```

### Step 4: 起動

```bash
# ビルドしたGodotで起動
./bin/godot.macos.editor.dev.universal --editor --path your_project
```

**または起動スクリプトを使用**:

```bash
cp start_education_mode.sh your_project/
cd your_project
./start_education_mode.sh
```

## 🎯 動作確認

### ✅ 成功時の挙動

1. Godotエディタが起動
2. **即座に**"Hello World - Godot Education System" が全画面表示
3. 上部に2D/3D/Scriptなどのタブが**一切表示されない**
4. Ctrl+1, Ctrl+2などのショートカットが無効
5. 完全に教育UIのみが表示される

### ❌ 失敗時のトラブルシューティング

#### タブが表示される

**原因**: 標準版Godotを使用している

**解決**: カスタムビルド版を使用
```bash
scons platform=macos target=editor dev_build=yes
```

#### プラグインが表示されない

**原因**: project.godotの設定が不足

**解決**: プラグインを有効化
```ini
[editor_plugins]
enabled=PackedStringArray("res://addons/hello_world_education/plugin.cfg")
```

#### 自動選択されない

**原因**: プラグイン名が一致していない

**解決**: plugin.gdを確認
```gdscript
func _get_plugin_name() -> String:
    return "Education"  # これが必須
```

## 📱 プラットフォーム対応

| プラットフォーム | 対応状況 | 備考 |
|---|---|---|
| **Windows** | ✅ 完全対応 | デスクトップ版 |
| **macOS** | ✅ 完全対応 | デスクトップ版 |
| **Linux** | ✅ 完全対応 | デスクトップ版 |
| **Android** | ✅ 対応 | エディタAPK版 |
| **Web** | ⚠️ 部分対応 | エディタWeb版 |
| **iOS** | ⚠️ 未テスト | 理論上は可能 |

### Android版の注意

Android版Godot Editor（Play Store版）でも同様に動作します：

1. カスタムビルドのAPKを作成
2. プラグインをプロジェクトに配置
3. 起動時に自動的に教育モード

## 🛠️ カスタマイズ

### UIの変更

`addons/hello_world_education/ui/main_panel.tscn` を編集：

- タイトルテキスト
- ボタン配置
- 色・テーマ
- レイアウト

### ロジックの追加

`addons/hello_world_education/ui/main_panel.gd` を編集：

```gdscript
func _on_start_button_pressed() -> void:
    # 学習開始ロジックを追加
    load_lesson("res://lessons/lesson_01.tscn")

func _on_settings_button_pressed() -> void:
    # 設定画面を表示
    show_settings_dialog()
```

### プラグイン名の変更

1. **C++コードを変更** (`editor/editor_main_screen.cpp`):
```cpp
if (E.key == "YourPluginName") {
```

2. **プラグインを変更** (`plugin.gd`):
```gdscript
func _get_plugin_name() -> String:
    return "YourPluginName"
```

3. **再ビルド**:
```bash
scons platform=macos target=editor dev_build=yes
```

## 📚 詳細ドキュメント

- [BUILD_EDUCATION_MODE.md](BUILD_EDUCATION_MODE.md) - ビルド詳細手順
- [EDUCATION_MODE_SETUP.md](EDUCATION_MODE_SETUP.md) - 実装方法の詳細解説
- [計画書2.md](計画書2.md) - エディタ拡張アプローチの設計書

## 🎨 スクリーンショット例

```
┌────────────────────────────────────────────────┐
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

## 🚧 今後の拡張案

### Phase 1: レッスンシステム
- [ ] レッスンリソース定義
- [ ] レッスンローダー
- [ ] 進捗管理

### Phase 2: インタラクティブチュートリアル
- [ ] EditorInterfaceを使ったシーン操作
- [ ] リアルタイムヒント表示
- [ ] ステップバイステップガイド

### Phase 3: ゲームプレビュー統合
- [ ] SubViewportでゲーム実行
- [ ] デバッグ機能
- [ ] コンソール出力キャプチャ

### Phase 4: マルチプラットフォーム最適化
- [ ] Web版対応
- [ ] Android版APK配布
- [ ] iOS版テスト

## 📄 ライセンス

Godot Engineと同じMITライセンス

## 🙏 謝辞

このプロジェクトは、Godot Engine 4.5のソースコードを基に作成されました。

- Godot Engine: https://godotengine.org
- ソースコード: https://github.com/godotengine/godot

## 📞 サポート

質問や問題がある場合：

1. [BUILD_EDUCATION_MODE.md](BUILD_EDUCATION_MODE.md) のトラブルシューティングを確認
2. Godot公式ドキュメントを参照
3. GitHubのIssueを作成

---

**Happy Learning with Godot! 🎓✨**
