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

  def self.search(str, options={})
    options[:limit] = options[:limit] || 50
    # default limit: 50 (mongoDB default: 100)

    res = self.mongo_session.command({ text: self.collection.name, search: str}.merge(options))

    # We shall now return a criteria of resulting objects!!
    self.where(:id.in => res['results'].collect {|o| o['obj']['_id']})
  end

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

  def self.group_by_first_line
    map = %Q{
      function() {
        emit(this.backtraces[0], { count: 1, date: this.created_at, id: this._id, remote_address: this.remote_address, user_agent: this.user_agent });
      }
    }

    reduce = %Q{
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
