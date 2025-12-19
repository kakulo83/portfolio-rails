class Post < ApplicationRecord
  has_many :contents, -> { order(:order) }, dependent: :destroy
  
  accepts_nested_attributes_for :contents, allow_destroy: true
end
