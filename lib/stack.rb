# Ruby Stack, John, July 30, 2012

class Stack

  def initialize
   @the_stack = []
  end

  def push(item)
    @the_stack.push item
  end

  def pop
    @the_stack.pop
  end

  def count
    @the_stack.length
  end
end