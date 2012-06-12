require "spec_helper.rb"
require "sample.rb" 

describe Sample do
  describe "create" do 
    before :each do  
      @sample = Factory(:sample)
    end

    %w(node value monitor).each do |attr|
      it "should have #{attr}" do  
        Sample.first.send(attr.to_sym).to_s.should == @sample[attr.to_sym].to_s 
      end
    end
  end 
end