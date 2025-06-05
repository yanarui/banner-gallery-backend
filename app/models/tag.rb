class Tag < ApplicationRecord
    has_many :banner_tags, dependent: :destroy
    has_many :banners, through: :banner_tags
  
    TAG_TYPES = %w[category taste shape media]
  
    validates :name, presence: true, uniqueness: { scope: :tag_type }
    validates :tag_type, presence: true, inclusion: { in: TAG_TYPES }
  end