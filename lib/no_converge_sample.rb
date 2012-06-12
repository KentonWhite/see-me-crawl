require './lib/base_sample.rb'

class NoConvergeSample < BaseSample

  def converged?
    false
  end
end
