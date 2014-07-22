class Thing < ActiveRecord::Base
  include Searchable

  searchable_columns :content
end
