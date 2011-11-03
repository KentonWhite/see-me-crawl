FactoryGirl.define do
  max_node = 1e9
  factory :base_sample do
    node    Kernel.rand(max_node)
    value   Kernel.rand(max_node).to_f   
    monitor Kernel.rand(max_node).to_f
  end
  
  factory :node do
    id          Kernel.rand(max_node)
    in_degree   Kernel.rand(max_node)
    out_degree  Kernel.rand(max_node)
    visited_at  DateTime.now
    private     false
  end
  
  factory :edge do
    n1  Kernel.rand(max_node)
    n2  Kernel.rand(max_node)
  end
end 