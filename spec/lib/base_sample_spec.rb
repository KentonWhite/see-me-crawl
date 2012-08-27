require "spec_helper.rb"
require "base_sample.rb" 

describe BaseSample do
  describe "create" do 
    before :each do  
      @sample = Factory(:base_sample)
    end

    %w(node value monitor).each do |attr|
      it "should have #{attr}" do  
        BaseSample.first.send(attr.to_sym).to_s.should == @sample[attr.to_sym].to_s 
      end
    end
  end 
end