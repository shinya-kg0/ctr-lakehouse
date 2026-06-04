# 広告クリックログ基盤のIaC化とCI/CDパイプライン構築

Avazuの広告クリックログデータ（約4,000万件）を活用し、データ収集からクレンジング・集計・可視化までを一気通貫で行うモダンなデータ基盤（レイクハウス）を構築したプロジェクト。  

## 技術スタック

| カテゴリ | 技術 |
|---|---|
| IaC | Terraform（AWS Provider・Databricks Provider） |
| CI/CD | GitHub Actions |
| ストレージ | AWS S3 |
| 権限管理 | AWS IAM |
| 処理エンジン | Databricks |
| テーブル形式 | Delta Lake |
| テーブル管理 | Unity Catalog |
| データ変換 | dbt |
| 言語 | Python / PySpark / SQL |
| バージョン管理 | GitHub |

## アーキテクチャ



### Medallion Architecture（データレイヤー設計）

| レイヤー | 内容 | 処理 |
|---|---|---|
| Bronze | 生データ（CSV→Delta変換） | PySpark：S3読み込み→Delta形式書き込み |
| Silver | クレンジング済みデータ | PySpark：型変換・NULL除去・hour_ts生成 |
| Gold | 集計・分析用データ | dbt：CTR集計・KPI算出 |

## リポジトリ構成

```
.
├── terraform/
│   ├── aws.tf          # S3バケット・IAMロール・IAMポリシー
│   ├── databricks.tf   # S3マウント・ノートブック・ジョブ定義
│   ├── variables.tf
│   └── outputs.tf
├── dbt/
│   ├── models/
│   │   ├── silver/
│   │   │   ├── silver_clicks.sql   # incrementalモデル
│   │   │   └── schema.yml          # データ品質テスト定義
│   │   └── gold/
│   │       ├── gold_ctr_by_hour.sql
│   │       └── schema.yml
│   ├── tests/
│   │   ├── assert_clicks_le_impressions.sql
│   │   ├── assert_ctr_between_0_and_100.sql
│   │   └── assert_silver_hour_ts_in_range.sql
│   └── macros/
│       └── generate_schema_name.sql
├── notebooks/
│   ├── bronze_ingestion.py   # CSV→Delta変換
│   └── silver_transform.py   # クレンジング処理
└── .github/
    └── workflows/
        ├── terraform.yml     # Terraform CI/CD
        └── dbt.yml           # dbt CI/CD
```

## 設計上の工夫

### TerraformによるAWS・Databricksの統合IaC管理

AWSリソース（S3・IAM）とDatabricksリソースを単一のTerraformプロジェクトで管理。`terraform apply` で環境全体を再現できる構成を実装。

AWSとDatabricks間のリソース依存関係（S3バケットIDをDatabricks Mountで参照するなど）もTerraformコード内で解決しており、手動設定の余地をゼロにした。

### IAM最小権限設計

IAM GroupやIAM Userを使用せず、**IAM Role + IAM Policy のみ**で完結する構成を採用。DatabricksのS3アクセスはロールベースで制御し、必要なバケット・操作のみを明示的に許可。

Unity Catalog経由のExternal Location設定と組み合わせることで、認証情報をコードに埋め込まずにDatabricks↔S3接続を実現。

### dbtテストによるデータ品質の自動検証

スキーマテスト（not_null・unique・accepted_values）とカスタムSQLテスト（業務ロジックの検証）を組み合わせ、16件のデータ品質テストをCI/CDに組み込んだ。

| テスト種別 | 件数 | 内容 |
|---|---|---|
| not_null | 8件 | 主要カラムのNULL禁止 |
| unique | 2件 | IDカラムの重複禁止 |
| accepted_values | 2件 | click・device_typeの値域チェック |
| カスタムSQL | 4件 | CTR範囲・クリック数の業務ロジック検証 |

