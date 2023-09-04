class Annotation < ApplicationRecord
    belongs_to :image
    validates :key, presence: true
    validates :value, presence: true
end
