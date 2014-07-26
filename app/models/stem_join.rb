class StemJoin < ActiveRecord::Base
  belongs_to :searchable, polymorphic: true
  belongs_to :stem
end