require 'spec_helper.rb'
require 'graph.rb'

describe Node do
  describe "create" do 
    before :each do  
      max_node = 1e9
      @node = { 
        id: rand(max_node), 
        in_degree:  rand(max_node), 
        out_degree: rand(max_node),
        visited_at: DateTime.now,
        private:    false
      }
      Node.create(@node)
    end

    %w(id in_degree out_degree visited_at private).each do |attr|
      it "should have #{attr}" do 
        Node.first.send(attr.to_sym).to_s.should == @node[attr.to_sym].to_s 
      end
    end
  end 
end