class Stem < ActiveRecord::Base
  has_many :stem_joins
  belongs_to :searchable, polymorphic: true

  has_many :things, through: :stem_joins, source: :searchable, source_type: 'Thing'
end
