class User < ApplicationRecord
  has_many :banners, dependent: :destroy
  has_secure_password

  validates :username, presence: true, uniqueness: true, format: { with: /\A[a-zA-Z0-9]+\z/, message: "は英数字のみ使用できます" }
  validates :password, presence: true, length: { minimum: 6, message: "は6文字以上で入力してください"}
end