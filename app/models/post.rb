class Post < ApplicationRecord
  has_many :contents, -> { order(:order) }, dependent: :destroy
end
