# fable-mode

Claude Fable 5 の「行動の規律」を Sonnet 以下のモデルで再現するためのツールキット。

Fable 5 の賢さは①モデル固有の生の能力(vision・一発正解率・長期指示保持)と②行動パターンの規律の掛け算。①は移植できないが、②はシステムプロンプト/スキルとして注入できる — その②を抽出したのがこのリポジトリ。

## 構成

```
fable-mode/
├── docs/
│   └── claude-fable-5-analysis.md   # Fable 5 の賢さの分析ドキュメント(調査ソース付き)
├── prompts/
│   └── fable-emulation-prompt.md    # システムプロンプト本体(行動規範10ブロック)
├── skills/
│   └── fable-mode/SKILL.md          # Claude Code スキル版(行動ループ + 能力ギャップ補正表)
└── bin/
    ├── claude-fable                 # Git Bash / WSL 用ランチャー
    └── claude-fable.cmd             # cmd / PowerShell 用ランチャー
```

## インストール

```bash
# プロンプトとスキルを配置
cp prompts/fable-emulation-prompt.md ~/.claude/
mkdir -p ~/.claude/skills/fable-mode
cp skills/fable-mode/SKILL.md ~/.claude/skills/fable-mode/

# ランチャーを PATH の通った場所に配置
cp bin/claude-fable bin/claude-fable.cmd ~/.local/bin/
chmod +x ~/.local/bin/claude-fable
```

## 使い方

```bash
claude-fable                    # Fable 規律つきで Claude Code を起動
claude-fable --model sonnet     # Sonnet で起動(引数はそのまま claude に渡る)
```

またはセッション内でスキルとして:

```
/fable-mode
```

## 行動規範の要点

- **行動原則**: 情報が揃ったら行動。確立済みの事実を再導出しない
- **スコープ規律**: 頼まれていないリファクタ・抽象化・防御コード禁止
- **境界**: 問題の説明・質問のときは評価が成果物。修正は頼まれてから
- **証拠ベース報告**: ツール結果で裏付けられる主張のみ報告。未検証は未検証と明示
- **ターン終了前チェック**: 約束(「〜します」)で終わらず、今その作業をやる
- **報告スタイル**: 結果先頭・完全な文・矢印チェーン禁止

詳細は [docs/claude-fable-5-analysis.md](docs/claude-fable-5-analysis.md) のセクション6を参照。

## 検証

`--append-system-prompt-file` の反映はセンチネルテストで確認済み:

```bash
printf '回答の末尾に必ず [FABLE-OK] を付けること。' > /tmp/sentinel.md
claude --append-system-prompt-file /tmp/sentinel.md --print "1+1は?"
# => 2
#    [FABLE-OK]
```

## ソース

主要参照: [Prompting Claude Fable 5 (公式)](https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/prompting-claude-fable-5)。全ソースは分析ドキュメント末尾に記載。
