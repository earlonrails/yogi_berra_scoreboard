require 'spec_helper'

describe CaughtExceptionsHelper do

  include CaughtExceptionsHelper

  it "should parse search text" do
    text_array = parse_search_text("class= class_name")
    text_array.should == [{:field=>"class", :query=>"class_name", :type=>:extactly}]
  end

  it "should parse multi search text" do
    time = Time.now
    text_array = parse_search_text("class= class_name class* class_ created_at> #{time} created_at< #{time}")
    text_array.should == [{:field=>"class", :query=>"class_name", :type=>:extactly},
      {:field=>"class", :query=>"class_", :type=>:like},
      {:field=>"created_at", :query=>"#{time}", :type=>:gt},
      {:field=>"created_at", :query=>"#{time}", :type=>:lt}]
  end

end
