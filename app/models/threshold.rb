class Threshold
  include Mongoid::Document
  field :limit, type: Integer
  field :raw_query, type: String

  embedded_in :project_configuration

  def met?

  end
end