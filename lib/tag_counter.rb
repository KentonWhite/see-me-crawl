require 'set'

class TagCounter
  attr_accessor :counter
  def initialize
   @counter = Hash.new { |hash, key| hash[key] = Hash.new { |hash, key| hash[key] = Set.new } } 
  end
  
  def add(date, tag, node) 
    @counter[date][tag] << node
  end
  
  def each
    @counter.each do |date, value|
      value.each do |tag, set|
        yield date, tag, set
      end
    end
  end
end