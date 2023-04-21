class Pinecone::Collection < Pinecone
  def initialize
    super
  end

  def create_collection(name:, source:)
    url = URI("https://controller.#{@environment}.pinecone.io/collections")

    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true

    request = Net::HTTP::Post.new(url)
    request["accept"] = 'text/plain'
    request["content-type"] = 'application/json'
    request["Api-Key"] = @api_key
    request.body = JSON.dump({name:, source:})

    response = http.request(request)
    puts response.read_body
  end

  def delete_collection(collection_name)
    url = URI("https://controller.#{@environment}.pinecone.io/collections#{collection_name}")

    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true

    request = Net::HTTP::Delete.new(url)
    request["accept"] = 'text/plain'
    request["Api-Key"] = @api_key

    response = http.request(request)
    puts response.read_body
  end
end