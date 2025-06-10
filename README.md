# banner-gallery-backend

## 概要

バナーギャラリーサイトのバックエンド API です。ユーザー認証やバナー画像の管理などを提供します。

## 動作環境

- Ruby: 3.4.2
- Rails: 8.0.2
- データベース: PostgreSQL
- 認証: JWT

## セットアップ

1. リポジトリをクローン

   ```
   git clone https://github.com/yanarui/banner-gallery-backend.git
   cd banner-gallery-backend
   ```

2. 必要な Gem をインストール

   ```
   bundle install
   ```

3. データベースを作成・マイグレーション

   ```
   rails db:create db:migrate
   ```

4. サーバー起動
   ```
   rails server
   ```

## 主な API エンドポイント

| メソッド | パス                    | 説明                 |
| -------- | ----------------------- | -------------------- |
| POST     | /api/signup             | ユーザー登録         |
| POST     | /api/login              | ログイン             |
| GET      | /api/banners            | バナー一覧取得       |
| POST     | /api/banners            | バナー新規作成       |
| GET      | /api/banners/:id        | バナー詳細取得       |
| PUT      | /api/banners/:id        | バナー更新           |
| DELETE   | /api/banners/:id        | バナー削除           |
| GET      | /api/banners/my_banners | 自分のバナー一覧取得 |

## 使用技術・主な Gem

- rails
- puma
- pg
- bcrypt
- jwt
- cloudinary
- dotenv-rails
- rack-cors
