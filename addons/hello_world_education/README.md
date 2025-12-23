# Hello World Education Plugin

Godot Engine用の教育プラグインのサンプル実装です。

## 機能

- エディタのメインスクリーンとして全画面表示
- シンプルなHello Worldインターフェース
- ボタンUI（Start Learning, Settings, Exit）

## 使い方

### 方法1: 通常のプラグインとして使用

1. Godotエディタを起動
2. `プロジェクト設定` > `プラグイン`
3. "Hello World Education" を有効化
4. 上部タブの "Education" をクリック

### 方法2: 起動スクリプトで自動選択

```bash
cd /Users/k/Documents/GitHub/godot
./start_education_mode.sh
```

## ファイル構成

```
addons/hello_world_education/
├── plugin.cfg              # プラグイン設定
├── plugin.gd               # EditorPluginメインスクリプト
├── README.md               # このファイル
└── ui/
    ├── main_panel.tscn     # メインパネルUI
    └── main_panel.gd       # メインパネルロジック
```

## カスタマイズ

### UI の変更

`ui/main_panel.tscn` をGodotエディタで開いて編集してください。

### ロジックの追加

`ui/main_panel.gd` にボタンのイベントハンドラが定義されています：

- `_on_start_button_pressed()` - Start Learningボタン
- `_on_settings_button_pressed()` - Settingsボタン
- `_on_exit_button_pressed()` - Exitボタン

## 拡張例

このプラグインは教育システムのベースとして使えます：

1. **レッスンシステム**
   - `lessons/` ディレクトリにレッスンリソースを追加
   - レッスンローダーを実装

2. **インタラクティブチュートリアル**
   - EditorInterfaceを使ってシーンツリーやインスペクタにアクセス
   - 学習者のアクションを検出

3. **進捗管理**
   - user://にJSONで進捗を保存
   - レッスンの完了状態を追跡

## 技術詳細

### EditorPluginの主要メソッド

- `_has_main_screen()`: メインスクリーンとして表示するかどうか
- `_make_visible(visible)`: タブ選択時の表示/非表示制御
- `_get_plugin_name()`: タブに表示される名前
- `_get_plugin_icon()`: タブのアイコン

### EditorInterfaceへのアクセス

```gdscript
var editor = EditorInterface

# シーン操作
editor.open_scene_from_path("res://scene.tscn")
var root = editor.get_edited_scene_root()

# ゲーム実行
editor.play_current_scene()
editor.stop_playing_scene()
```

## ライセンス

Godot Engineと同じMITライセンス
