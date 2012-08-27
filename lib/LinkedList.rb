# refer to http://www.koders.com/ruby/fidCB5A463AB556F4FFD20E03139FF59563B118D108.aspx

class LinkedList

	# include and extend, http://railstips.org/blog/archives/2009/05/15/include-vs-extend-in-ruby/
	
	include Enumerable

	def initialize
		@first = Node.new nil
		@last = Node.new nil

		@first.next = @last
		@last.prev = @first
		@size = 0
	end

	def addLast(object)
		node = Node.new(object)
		node.next = @last
		node.prev = @last.prev
		
		@last.prev.next = node
		@last.prev = node
		@size += 1
	end

	def addFirst(object)
		node = Node.new(object)
		node.prev = @first
		node.next = @first.next
		
		@first.next.prev = node
		@first.next = node
		@size += 1
	end

	def last
		if @size <= 0
			raise "No objects in list"
		end

		return @last.prev.object
	end

	def first
		if @size <= 0
			raise "No objects in list"
		end

		return @first.next.object
	end

	def removeLast
		if @size <= 0
			raise "No objects in list"
		end

		node = @last.prev
		node.prev.next = @last
		@last.prev = node.prev
		@size -= 1

		return node.object
	end

	def removeFirst
		if @size <= 0
			raise "No objects in list"
		end

		node = @first.next
		node.next.prev = @first
		@first.next = node.next
		@size -= 1

		return node.object
	end

	def size
		return @size
	end

	def each
		node = @first.next
		while node != @last
			yield node.object
			node = node.next
		end
	end

	def reverse_each
		node = @last
		loop do
			yield node.object
			node = node.prev
			if ! node
				break
			end
		end
	end

	class Node
		
		attr_reader :object
		attr_reader :prev
		attr_reader :next
		
		attr_writer :next
		attr_writer :prev

		def initialize(object)
			@object = object
		end

		def dump(io)
			io.puts "===== #{self} ====="
			io.puts "Object: #{@object}"
			io.puts "Prev: #{@prev}"
			io.puts "Next: #{@next}"
		end
	end

end
