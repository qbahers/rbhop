$:.unshift File.dirname(__FILE__)

require "yaml/store"

require "rbhop/api"
require "rbhop/version"
require "rbhop/simple_travel/simple_travel"

module Rbhop
  def self.sanitize(word)
    word.gsub(/[^0-9A-Za-z]/, "")
        .downcase
  end

  def self.find_domain(plain_text)
    store = YAML::Store.new("../lib/rbhop/data.yml")

    planning_domains = store.transaction(true) do
      store["planning_domains"]
    end

    words = plain_text.split(" ")

    words.each do |word|
      s_word = sanitize(word)
      return planning_domains[s_word] if planning_domains.key?(s_word)
    end
    false
  end

  def self.rbhop(plain_text)
    domain = find_domain(plain_text)

    if domain
      requirements = domain["requirements"]

      requirements.map! do |requirement|
        value = Rbhop::API.get_last_value(requirement)
        puts "#{requirement}: #{value}"
        value
      end

      state_name = domain["state_name"]
      state = Kernel.const_get(state_name).new(*requirements)
      params = domain["params"]
      plan = ai_plan(state, params)
    else
      "(._.?)"
    end
  end
end

