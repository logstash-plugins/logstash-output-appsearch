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
  config :store_timestamp, :validate => :string
  config :document_id, :validate => :string

  public
  def register
    @client = Client.new(@host, @api_key.value)
  end

  public
  def multi_receive(events)
    return if events.empty?
    documents = events.map do |event|
      doc = event.to_hash
      # we need to remove default fields that start with "@"
      # since appsearch doesn't accept them
      if @store_timestamp
        doc[@store_timestamp] = doc.delete("@timestamp")
      else # delete it
        doc.delete("@timestamp")
      end
      if @document_id
        doc["id"] = event.sprintf(@document_id)
      end
      doc.delete("@version")
      doc
    end
    if @logger.trace?
      @logger.trace("Sending bulk to AppSearch", :size => documents.size, :data => documents.inspect)
    end
    index(documents)
  end

  private
  def index(documents)
    response = @client.index_documents(@engine, documents)
    report(documents, response)
  rescue => e
    @logger.error("Failed to execute index operation. Retrying..", :reason => e.message)
    sleep(1)
    retry
  end

  def report(documents, response)
    documents.each_with_index do |document, i|
      errors = response[i]["errors"]
      if errors.empty?
        @logger.trace? && @logger.trace("Document was indexed with no errors", :document => document)
      else
        @logger.warn("Document failed to index. Dropping..", :document => document, :errors => errors.to_a)
      end
    end
  end
end
