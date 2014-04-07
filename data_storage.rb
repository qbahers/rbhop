require "yaml/store"

store = YAML::Store.new("data.yml")

store.transaction do
  store["planning_domains"] = { "travel" => { "requirements" => ["distance", "cash"],
                                              "state_name"   => "StateTravel",
                                              "params" => [["travel", "me", "home", "park"]] } }
end
