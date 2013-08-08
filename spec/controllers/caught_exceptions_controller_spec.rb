require 'spec_helper'

describe CaughtExceptionsController do

  before(:all) do
    @current_time = Time.now + 1.minute
    15.times do
      FactoryGirl.create(:caught_exception)
    end
  end

  it "should get all exceptions" do
    get 'index', { :format => :json }
    json_response = JSON.parse(response.body)
    json_response.size.should == 15
  end

  context "match the search critera" do
    it "should check an extact match" do
      get 'index', { :search_text => "error_class= StandardError", :format => :json }
      json_response = JSON.parse(response.body)
      json_response.size.should == 15
    end

    it "should check a like match" do
      get 'index', { :search_text => "user_agent* Macintosh", :format => :json }
      json_response = JSON.parse(response.body)
      json_response.size.should == 15
    end

    it "should check a greater than match" do
      get 'index', { :search_text => "created_at> #{@current_time - 1.hour}", :format => :json }
      json_response = JSON.parse(response.body)
      json_response.size.should == 15
    end

    it "should check a less than match" do
      get 'index', { :search_text => "created_at< #{@current_time}", :format => :json }
      json_response = JSON.parse(response.body)
      json_response.size.should == 15
    end

    it "should check that many matchers work together" do
      get 'index', { :search_text => "error_class= StandardError user_agent* Macintosh created_at> #{@current_time - 1.hour} created_at< #{@current_time}", :format => :json }
      json_response = JSON.parse(response.body)
      json_response.size.should == 15

      get 'index', { :search_text => "error_class= StandardError error_message= StandardError: StandardError user_agent* Macintosh server_name* server created_at> #{@current_time - 1.hour} created_at< #{@current_time}", :format => :json }
      json_response = JSON.parse(response.body)
      json_response.size.should == 15
    end
  end
end
