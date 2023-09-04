class Image < ApplicationRecord
    has_one_attached :picture
    validates :picture, presence: true
    has_many :annotations, dependent: :destroy
end
