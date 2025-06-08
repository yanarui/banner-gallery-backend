class Api::BannersController < ApplicationController
  require "cloudinary"
  require "cloudinary/uploader"
  require "cloudinary/utils"

  def index
    if params[:tag]
      tag_name = params[:tag]
      banners = Banner.joins(:tags).where(tags: { name: tag_name }).distinct.order(id: :desc)
      Rails.logger.info("Found banners: #{banners.pluck(:id)}")
    else
      banners = Banner.includes(:tags).order(id: :desc)
    end

    render json: banners.map { |banner|
      {
        id: banner.id,
        image_url: banner.image_url,
        company_name: banner.company_name,
        tags: banner.tags.map { |tag| { name: tag.name, tag_type: tag.tag_type } }
      }
    }, status: :ok
  end

  def show
    banner = Banner.includes(:tags).find(params[:id])

    tags_by_type = banner.tags.group_by(&:tag_type)

    render json: {
      id: banner.id,
      image_url: banner.image_url,
      company_name: banner.company_name,
      tags: tags_by_type
    }
  end

  def create
    uploaded_file = params[:file]
    company_name = params[:company_name]
    user = current_user

    return render json: { error: "ユーザーが認証されていません" }, status: :unauthorized unless user
    return render json: { error: "ファイルが選択されていません" }, status: :unprocessable_entity unless uploaded_file

    begin
      # Cloudinary にアップロード
      file_url = upload_to_cloudinary(uploaded_file)

      # データベースに保存
      banner = Banner.create!(
        image_url: file_url,
        company_name: company_name,
        user_id: user.id
      )

      # タグ情報を処理
      if params[:tags]
        tags = JSON.parse(params[:tags]) # フロントエンドから送信された JSON をパース
        tags.each do |tag_data|
          tag = Tag.find_or_create_by!(name: tag_data["name"], tag_type: tag_data["tag_type"])
          BannerTag.create!(banner: banner, tag: tag)
        end
      end

      detail_url = "https://banner-gallery-frontend.vercel.app/bannerdetailpage?id=#{banner.id}"

      render json: { message: "アップロード成功", banner: banner, detail_url: detail_url }, status: :created
    rescue Cloudinary::Api::Error => e
      Rails.logger.error("Cloudinary API Error: #{e.message}")
      render json: { error: "Cloudinary API Error: #{e.message}" }, status: :unprocessable_entity
    rescue ActiveRecord::RecordInvalid => e
      Rails.logger.error("Database save error: #{e.message}")
      render json: { error: "Database save error: #{e.message}" }, status: :unprocessable_entity
    rescue => e
      Rails.logger.error("Upload error: #{e.full_message}")
      render json: { error: e.message }, status: :unprocessable_entity
    end
  end

  def destroy
    banner = current_user.banners.find_by(id: params[:id])
    if banner
      banner.destroy
      render json: { message: "バナーを削除しました" }, status: :ok
    else
      render json: { error: "バナーが見つかりません" }, status: :not_found
    end
  end

  # バナーの更新
  def update
  banner = current_user.banners.find(params[:id])
  banner.company_name = params[:company_name] if params[:company_name].present?
    if params[:tags]
      tags = JSON.parse(params[:tags])
      banner.banner_tags.destroy_all
      tags.each do |tag_data|
        tag = Tag.find_or_create_by!(name: tag_data["name"], tag_type: tag_data["tag_type"])
        BannerTag.create!(banner: banner, tag: tag)
      end
    end

    if banner.save
      detail_url = "https://banner-gallery-frontend.vercel.app/bannerdetailpage?id=#{banner.id}"
      render json: { message: "バナーを更新しました", banner: banner, detail_url: detail_url }, status: :ok
    else
      render json: { error: banner.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def my_banners
    # 現在のユーザーのバナーを取得
    banners = current_user.banners.includes(:tags).order(created_at: :desc)
    render json: banners.map { |banner|
      {
        id: banner.id,
        image_url: banner.image_url,
        company_name: banner.company_name,
        tags: banner.tags.map { |tag| { name: tag.name, tag_type: tag.tag_type } }
      }
    }, status: :ok
  end

  private

  def banner_params
    params.require(:banner).permit(:company_name, :image_url, tags_attributes: [ :id, :name, :tag_type, :_destroy ])
  end

  def banner_params
    params.permit(:title, :description, :company_name, :file)
  end

  def authenticate_user!
    unless current_user
      render json: { error: "ユーザーが認証されていません" }, status: :unauthorized
    end
  end

  def current_user
    auth_header = request.headers["Authorization"]
    return nil unless auth_header

    token = auth_header.split(" ").last
    begin
      secret_key = Rails.application.credentials.secret_key_base
      decoded_token = JWT.decode(token, secret_key, true, { algorithm: "HS256" })
      user_id = decoded_token[0]["user_id"]
      @current_user ||= User.find_by(id: user_id)
    rescue JWT::DecodeError
      nil
    end
  end

  def upload_to_cloudinary(uploaded_file)
    result = Cloudinary::Uploader.upload(uploaded_file.path, folder: "banners/by_user/")
    result["secure_url"]
  end
end
