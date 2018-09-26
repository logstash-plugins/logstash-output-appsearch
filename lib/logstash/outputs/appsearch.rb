# encoding: utf-8
require "logstash/outputs/base"
require 'logstash-output-appsearch_jars.rb'
java_import com.swiftype.appsearch.Client

# An appsearch output that does nothing.
class LogStash::Outputs::AppSearch < LogStash::Outputs::Base
  config_name "appsearch"

  config :engine, :validate => :string, :required => true
  config :host, :validate => :string, :required => true
  config :api_key, :validate => :password, :required => true

  public
  def register
    @client = Client.new(@host, @api_key.value)
  end

  public
  def multi_receive(events)
    documents = events.map do |e|
      doc = e.to_hash
      doc["timestamp"] = doc.delete("@timestamp")
      doc.delete("@version")
      doc
    end
    @logger.info("sending data", :data => documents.inspect)
    result = @client.index_documents(@engine, documents)
    @logger.info(result.inspect)
  end
end
