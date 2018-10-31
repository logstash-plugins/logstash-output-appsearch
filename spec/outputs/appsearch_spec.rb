# encoding: utf-8
require "logstash/devutils/rspec/spec_helper"
require "logstash/outputs/elastic_app_search"
require "logstash/codecs/plain"
require "logstash/event"

describe LogStash::Outputs::ElasticAppSearch do
  let(:sample_event) { LogStash::Event.new }
  let(:host) { "test-host" }
  let(:api_key) { "my_key" }
  let(:engine) { "test-engine" }
  let(:output) { described_class.new("host" => host, "api_key" => api_key, "engine" => engine) }
end
