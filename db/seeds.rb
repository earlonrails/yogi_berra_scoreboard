# These errors that are generated just have the bare minimum to be created, ie no server info, request info, params etc...

def create_exception
  error = nil
  begin
    error_array = [
      lambda { raise Exception }, lambda { raise StandardError }, lambda { raise NoMethodError },
      lambda { raise ArgumentError }, lambda { raise NameError }, lambda { raise NoMemoryError },
      lambda { raise ScriptError }, lambda { raise LoadError }, lambda { raise NotImplementedError },
      lambda { raise SyntaxError }, lambda { raise SignalException }, lambda { raise IOError },
      lambda { raise ActiveResource::ConnectionError }, lambda { raise ActiveResource::TimeoutError },
      lambda { raise ActiveRecord::RecordNotFound }, lambda { raise ActiveRecord::SubclassNotFound },
      lambda { raise ActiveRecord::RecordInvalid }, lambda { raise ActiveRecord::StatementInvalid }
    ]
    error_array[rand(error_array.size)].call

  rescue Exception => e
    error = e
  end
  error
end

# 10 errors that just happened
10.times do
  error = create_exception

  CaughtException.create({
    "error_class" => error.class,
    "project" => "scoreboard_dev",
    "error_message" => error.message,
    "backtraces" => error.backtrace,
    "created_at" => Time.now
  })
end

# 10 errors that happened randomly within 1 month
10.times do
  one_month_ago = Time.now - 1.month
  random_time = Time.at((Time.now.to_f - one_month_ago.to_f)*rand + one_month_ago.to_f)
  error = create_exception

  CaughtException.create({
    "error_class" => error.class,
    "project" => "scoreboard_dev",
    "backtraces" => error.backtrace,
    "error_message" => error.message,
    "created_at" => random_time
  })
end
