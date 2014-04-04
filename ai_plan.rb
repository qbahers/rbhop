require_relative "api_client"
require_relative "simple_travel/simple_travel"
require_relative "planning_domains"

def sanitize(word)
  word.gsub(/[^0-9A-Za-z]/, '')
      .downcase
end

def find_domain(plain_text)
  words = plain_text.split(" ")
  words.each do |word|
    s_word = sanitize(word)
    return $planning_domains[s_word] if $planning_domains.key?(s_word)
  end
  false
end

def ai_plan(plain_text)
  domain = find_domain(plain_text)
  if domain
    requirements = domain["requirements"]

    requirements.each do |requirement|
      value = get_last_value(requirement)
      eval("$#{requirement} = #{value}")
    end

    state_name = domain["state_name"]
    state = Kernel.const_get(state_name).new(*requirements)
    params = domain["params"]
    plan = rbhop(state, params)
  else
    "(._.?)"
  end
end

# Test
plan = ai_plan("travel")
p plan
plan = ai_plan("Tell me how to travel from home to the park")
p plan
plan = ai_plan("How to travel?")
p plan
plan = ai_plan("Travel")
p plan
plan = ai_plan("Hej")
p plan

