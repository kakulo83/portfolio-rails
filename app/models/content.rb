class Content < ApplicationRecord
  belongs_to :post
  
  # Disable Single Table Inheritance since 'type' column is for content type, not inheritance
  self.inheritance_column = :_type_disabled
end
