require './lib/base_sample.rb'

class NoConvergeSample < BaseSample

  def converge
    false
  end
end
