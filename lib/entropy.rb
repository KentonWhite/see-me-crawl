require 'dm-chunked_query'

class Entropy
  attr_accessor :distribution
  
  def initialize
    @distribution = Hash.new(0)
  end
  
  def load_distribution
    DataMapper.repository(:local) do
      Sample.each_chunk(20) do |chunk|
        chunk.each do |s|
          @distribution[s.value.to_i] += 1
        end
      end
    end
  end
end