FactoryGirl.define do
  factory :caught_exception do
    backtraces ["backtraces backtraces backtraces"]
    created_at Time.now
    session {{ :user => "Bob", :data => "Some data" }}
    params {{ :action => "/index", :id => "1" }}
    error_class "StandardError"
    error_message "StandardError: StandardError"
    server_address "0.0.0.0"
    user_agent "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_8_3) AppleWebKit/536.28.10 (KHTML, like Gecko) Version/6.0.3 Safari/536.28.10"
    server_name "server.dev"
    server_port "80"
    remote_address "127.0.0.1"
  end
end