# Ruby Queue, John, July 30, 2012

class Queue

   def initialize
    @store = []
   end

   def enqueue(x)
    @store << x
   end

   def dequeue
    @store.shift
   end

   def peek
    @store.first
   end

   def length
    @store.length
   end

   def empty?
    @store.empty?
   end
   
   def element(i)
	@store.at[i]
   end

  end