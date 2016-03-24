# Definition of objects mapped to database 
class Price < ActiveRecord::Base
  belongs_to :name
  belongs_to :dating
end

class Name < ActiveRecord::Base
  has_many :prices, :dependent => :destroy
end

class Dating < ActiveRecord::Base
  has_many :prices, :dependent => :destroy
end
