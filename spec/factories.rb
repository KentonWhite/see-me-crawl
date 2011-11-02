FactoryGirl.define do
  max_node = 1e9
  factory :base_sample do
    node    Kernel.rand(max_node)
    value   Kernel.rand(max_node).to_f   
    monitor Kernel.rand(max_node).to_f
  end
end 