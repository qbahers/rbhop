require "yaml/store"

module Rbhop
  module StoreData

    def self.store
      store = YAML::Store.new("../lib/rbhop/data.yml")

      store.transaction do
        requirements = %w(distance cash)
        params       = %w(travel me home park)

        store["planning_domains"] = 
          { "travel" => { 
              "requirements" => requirements, 
              "state_name"   => "StateTravel", 
              "params"       => [params] } }
      end
    end
  end
end
