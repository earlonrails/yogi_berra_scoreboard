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
end
