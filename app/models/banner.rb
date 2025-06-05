class Banner < ApplicationRecord
  belongs_to :user
  has_many :banner_tags, dependent: :destroy
  has_many :tags, through: :banner_tags
  has_one_attached :image
end
