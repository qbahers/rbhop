require "yaml/store"

store = YAML::Store.new("data.yml")

store.transaction do
  requirements = %w(distance cash)
  params       = %w(travel me home park)

  store[:planning_domains] = 
    { travel: { 
        requirements: requirements, 
        state_name:   "StateTravel", 
        params:       [params] } }
end
