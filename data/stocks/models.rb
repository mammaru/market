# Definition of objects mapped to database 
class Price < ActiveRecord::Base
  belongs_to :name, :date
end

class Name < ActiveRecord::Base
  has_many :prices dependent: :destroy
end

class Date < ActiveRecord::Base
  has_many :prices
end
