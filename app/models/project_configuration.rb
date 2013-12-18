class ProjectConfiguration
  include Mongoid::Document
  field :created_at, type: Time
  field :updated_at, type: Time
  field :project_name, type: String

  index({created_at: 1})
end
