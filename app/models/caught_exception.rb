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
  field :controller, type: Hash

  index({created_at: 1})

  scope :gt, lambda { |column, value| where(:created_at => { '$gt' => value }) if value }
  scope :lt, lambda { |column, value| where(:created_at => { '$lt' => value }) if value }

  scope :gte, lambda { |column, value| where(:created_at => { '$gte' => value }) if value }
  scope :lte, lambda { |column, value| where(:created_at => { '$lte' => value }) if value }

  scope :extactly, lambda { |column, value| where(column.to_sym => value) if column && value }
  scope :like, lambda { |column, value| where(column.to_s => /.*#{value}.*/i) if column && value }

  def self.group_by_error_message
    map = %Q{
      function() {
        emit(this.error_message, { count: 1, date: this.created_at, id: this._id });
      }
    }

    reduce = %Q{
      function(key, values) {
        var result = {count: 0, dates: [], ids: []};
        values.forEach(function(value){
          if (value.date) {
            result.count += value.count;
            result.dates.push(value.date.valueOf());
            result.ids.push(value.id)
          }
        });
        return result;
      }
    }
    where(:error_message => {'$exists' => true, '$ne' => ""}).map_reduce(map, reduce).out(inline: true).sort_by do |message|
      message["value"]["count"] = message["value"]["count"].to_i
      -message["value"]["count"]
    end
  end

  def error_title
    title = ""
    if controller
      title = "#{controller['name']}##{controller['action']}"
    elsif params['controller']
      title = "#{params['controller']}##{params['action']}"
    end
    "#{title} Line: #{line_number} #{created_at.strftime('%m/%d/%Y %X')}"
  end

  def first_line
    backtraces.first
  end

  def line_number
    first_line[/\:\d+\:/][1..-2]
  end
end
