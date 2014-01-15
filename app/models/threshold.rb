class Threshold
  include Mongoid::Document
  field :limit, type: Integer
  field :error_class, type: String
  field :controller, type: Hash
  field :raw_query, type: String

  embedded_in :project_configuration

  def met?

  end
end