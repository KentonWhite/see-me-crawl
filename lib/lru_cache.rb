# refer to https://gist.github.com/150201#file_lru_cache.rb
class LRUCache
  
  def initialize(size = 10)
    @size = size
    @store = {}
    @lru = []
  end
  
  def set(key, value = nil)
    value = yield if block_given?
    @store[key] = value
    set_lru(key)
    @store.delete(@lru.pop) if @lru.size > @size
    value
  end
  
  def get(key)
    set_lru(key)
    if !@store.key?(key) && block_given?
      set(key, yield)
    else
      @store[key]
    end
  end
  
  def delete(key)
    @store.delete(key)
    @lru.delete(key)
  end
  
  private
    def set_lru(key)
      @lru.unshift(@lru.delete(key) || key)
    end
end


if __FILE__ == $0
  require 'test/unit'

  class TestLRUCache < Test::Unit::TestCase

    def setup
      @cache = LRUCache.new(2)
    end

    def test_last_droped
      @cache.set(:a, 'a')
      @cache.set(:b, 'b')
      @cache.set(:c, 'c')
    
      assert_nil @cache.get(:a)
      assert_equal 'b', @cache.get(:b)
      assert_equal 'c', @cache.get(:c)
    end
  
    def test_get_keeps_key
      @cache.set(:a, 'a')
      @cache.set(:b, 'b')
      @cache.get(:a)
      @cache.set(:c, 'c')
    
      assert_equal 'a', @cache.get(:a)
      assert_nil @cache.get(:b)
      assert_equal 'c', @cache.get(:c)
    end
    
    def test_set_keeps_key
      @cache.set(:a, 'a')
      @cache.set(:b, 'b')
      @cache.set(:a, 'a')
      @cache.set(:c, 'c')
    
      assert_equal 'a', @cache.get(:a)
      assert_nil @cache.get(:b)
      assert_equal 'c', @cache.get(:c)
    end
    
    def test_get_with_block
      assert_equal 'a', @cache.get(:a) { 'a' }
      assert_equal 'a', @cache.get(:a)
    end
    
    def test_set_with_block
      @cache.set(:a, 'b') { 'a' }
      assert_equal 'a', @cache.get(:a)
    end
    
    def test_delete
      @cache.set(:a, 'a')
      @cache.set(:b, 'b')
      @cache.delete(:b)
      @cache.set(:c, 'c')
    
      assert_equal 'a', @cache.get(:a)
      assert_nil @cache.get(:b)
      assert_equal 'c', @cache.get(:c)
    end
  end
end