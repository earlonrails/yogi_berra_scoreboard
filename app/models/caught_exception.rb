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
    map = <<-MAP_DOC
      function() {
        emit(this.error_message, { count: 1, date: this.created_at, id: this._id });
      }
    MAP_DOC

    reduce = <<-REDUCE_DOC
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
    REDUCE_DOC

    where(:error_message => {'$exists' => true, '$ne' => ""}).map_reduce(map, reduce).out(inline: true).sort_by do |message|
      message["value"]["count"] = message["value"]["count"].to_i
      -message["value"]["count"]
    end
  end

  def self.group_by_first_line
    map = <<-MAP_DOC
      function() {
        emit(this.backtraces[0], { count: 1, date: this.created_at, id: this._id, remote_address: this.remote_address, user_agent: this.user_agent });
      }
    MAP_DOC

    reduce = <<-REDUCE_DOC
      function(key, values) {
        var result = {count: 0, dates: [], ids: [], agents: {}, ips: {}};
        values.forEach(function(value){
          if (value.date) {
            result.count += value.count;
            result.dates.push(value.date.valueOf());
            result.ids.push(value.id);
            if (result.ips.hasOwnProperty(value.remote_address)) {
              result.ips[value.remote_address] += 1
            } else {
              result.ips[value.remote_address] = 1
            }

            if (result.agents.hasOwnProperty(value.user_agent)) {
              result.agents[value.user_agent] += 1
            } else {
              result.agents[value.user_agent] = 1
            }
          }
        });
        return result;
      }
    REDUCE_DOC

    exceptions = where(
      :error_message => {'$exists' => true, '$ne' => ""}
    ).or(
      {:dismissed => false},
      {:dismissed => {
        '$exists' => false
        }
      }
    ).map_reduce(map, reduce).out(inline: true)

    exceptions.sort_by do |exception|
      exception["value"]["count"] = exception["value"]["count"].to_i
      -exception["value"]["count"]
    end
  end

  def error_title
    title = ""
    if controller
      title = "#{controller['name']}##{controller['action']}"
    elsif params && params['controller']
      title = "#{params['controller']}##{params['action']}"
    end
    "#{title} Line: #{line_number} #{created_at.strftime('%m/%d/%Y %X')}"
  end

  def first_line
    backtraces.first
  end

  def line_number
    first_line[/\:\d+\:/] ? first_line[/\:\d+\:/][1..-2] : ""
  end
end
