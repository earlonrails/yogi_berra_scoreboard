class ProjectConfiguration
  include Mongoid::Document
  field :created_at, type: Time
  field :name, type: String

  index({created_at: 1})
  embeds_many :thresholds

  validates_uniqueness_of :name #, :message => "", :case_sensitive => false
end
