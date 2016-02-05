# Definition of objects mapped to database 
class Name < ActiveRecord::Base
  has_one :price dependent: :destroy
end

class Price < ActiveRecord::Base
  belongs_to :name
end
