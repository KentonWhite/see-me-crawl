module Variance

  def sum(&blk)
    map(&blk).inject { |sum, element| sum + element }
  end

  def mean
    (sum.to_f / size.to_f)
  end

  def variance
    m = mean
    sum { |i| ( i - m )**2 } / size
  end

  def std_dev
    Math.sqrt(variance)
  end
end

Array.send :include, Variance