# Terraform GCP サンドボックス

Terraform の基本操作確認用プロジェクト。以下の GCP リソースを管理する。

- Service Account × 1
- Cloud Storage bucket × 1
- Cloud Run service × 1
- IAM binding (リソース単位) × 数個
- 必要 API の有効化 × 5

## 事前準備

### 1. gcloud CLI 認証

```bash
gcloud auth login
gcloud auth application-default login
gcloud config set project terraform-sandbox-490703
```

### 2. tfvars ファイル作成

```bash
cp terraform.tfvars.example terraform.tfvars
# 必要に応じて値を編集
```

## 実行手順

```bash
# 初期化
terraform init

# 差分確認
terraform plan

# 適用
terraform apply

# 削除
terraform destroy
```

## コスト・安全性に関する注記

| 設定 | 効果 |
|------|------|
| Cloud Run min_instance_count = 0 | リクエストがなければインスタンス起動なし。CPU/メモリ課金ゼロ |
| cpu_idle = true | リクエスト処理中のみ CPU 課金 |
| max_instance_count = 1 | 意図しないスケールアウトを防止 |
| startup_cpu_boost = false | 起動時の追加 CPU 割り当てを無効化 |
| memory = 128Mi | 最小メモリで課金を抑制 |
| allow_unauthenticated = false | 未認証アクセス不可。外部からのリクエスト発生を防止 |
| public_access_prevention = enforced | バケットの公開アクセスをブロック |
| uniform_bucket_level_access = true | ACL を無効化し IAM のみで制御 |
| force_destroy = true | バケット内にオブジェクトがあっても destroy 可能 |

## destroy 時の注意点

- `google_project_service` は `disable_on_destroy = true` にしているため、destroy 時に API が無効化される。他のリソースが同じ API に依存している場合は注意。
- Cloud Storage bucket は `force_destroy = true` のため、中にオブジェクトがあっても削除される。
- API の無効化が他の手動作成リソースに影響する場合は、destroy 前に `disable_on_destroy = false` に変更してから実行すること。
- Terraform state はローカル (`terraform.tfstate`) に保存される。destroy 後も state ファイルは残るため、不要なら手動削除する。

## ファイル構成

```
.
├── provider.tf              # provider / backend 設定
├── variables.tf             # 変数定義
├── main.tf                  # リソース定義
├── outputs.tf               # 出力定義
├── terraform.tfvars.example # 変数値のサンプル
└── README.md
```
