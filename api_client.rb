require "net/http"
require "json"

IOT_FRAMEWORK_URI = "http://localhost:8000"

def get_streams(tag)
  uri = URI("#{IOT_FRAMEWORK_URI}/streams/_search")
  parsed_body = { "query" => { "term" => { "tags" => tag } } }

  req = Net::HTTP::Post.new(uri.path)
  req.body = parsed_body.to_json
  req.content_type = "application/json"

  res = Net::HTTP.start(uri.host, uri.port) do |http|
    http.request(req)
  end

  case res
  when Net::HTTPSuccess, Net::HTTPRedirection
    # OK
    body = res.body
    parsed_body = JSON.parse(body)
    streams = parsed_body["hits"]["hits"]
  else
    res.value
  end
end

def get_last_datapoint(stream_id)
  uri = URI("#{IOT_FRAMEWORK_URI}/streams/#{stream_id}/data")

  req = Net::HTTP::Get.new(uri.path)

  res = Net::HTTP.start(uri.host, uri.port) do |http|
    http.request(req)
  end

  case res
  when Net::HTTPSuccess, Net::HTTPRedirection
    # OK
    body = res.body
    parsed_body = JSON.parse(body)
    last_data_point = parsed_body["data"][0]["value"]
  else
    res.value
  end
end

def get_last_value(tag)
  streams = get_streams(tag)
  first_stream_id = streams[0]["_id"]
  data_point = get_last_datapoint(first_stream_id)
end

