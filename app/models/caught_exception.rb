class CaughtException
  include Mongoid::Document

  field :backtraces, type: Array
  field :created_at, type: DateTime
  field :session, type: Hash
  field :params, type: Hash
  field :error_class, type: String
  field :error_message, type: String
  field :server_address, type: String
  field :user_agent, type: String
  field :server_name, type: String
  field :server_port, type: String
  field :remote_address, type: String
  field :project, type: String
  field :dismissed, type: Boolean


  scope :gt, lambda { |column, value| where(:created_at => { '$gt' => value }) if value }
  scope :lt, lambda { |column, value| where(:created_at => { '$lt' => value }) if value }

  scope :gte, lambda { |column, value| where(:created_at => { '$gte' => value }) if value }
  scope :lte, lambda { |column, value| where(:created_at => { '$lte' => value }) if value }

  scope :extactly, lambda { |column, value| where(column.to_sym => value) if column && value }
  scope :like, lambda { |column, value| where(column.to_s => /.*#{value}.*/) if column && value }

  def self.search(query)
    if query.blank?
      scoped
    else
      sql = query.split.map do |word|
        %w[first_name last_name].map do |column|
        sanitize_sql ["#{column} LIKE ?", "%#{word}%"]
        end.join(" or ")
      end.join(") and (")
      where("(#{sql})")
    end
  end

  def self.search_w_hash(hash)
    sql = query.split.map do |word|
      %w[first_name last_name].map do |column|
      sanitize_sql ["#{column} LIKE ?", "%#{word}%"]
      end.join(" or ")
    end.join(") and (")
    where("(#{sql})")
  end
end
