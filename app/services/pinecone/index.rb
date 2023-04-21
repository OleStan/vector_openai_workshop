class Pinecone::Index < Pinecone
  def initialize(index_name:)
    super
    @index_name = index_name
    describe_index_stats
    # ToDo find or create index
  end

  def create_index(metric: "cosine", pods: 1, replicas: 1, pod_type: "p1.x1", name: @index_name, dimension: 128)
    url = URI("https://controller.#{@environment}.pinecone.io/databases")

    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true

    request = Net::HTTP::Post.new(url)
    request["accept"] = 'text/plain'
    request["content-type"] = 'application/json'
    request.body = JSON.dump({ metric:, pods:, replicas:, pod_type:, name:, dimension: })
    request["Api-Key"] = @api_key
    response = http.request(request)

    response.read_body
  end

  def delete_index(index_name = @index_name)
    url = URI("https://controller.#{@environment}.pinecone.io/databases/#{index_name}")

    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true

    request = Net::HTTP::Delete.new(url)
    request["accept"] = 'text/plain'
    request["Api-Key"] = @api_key

    response = http.request(request)
    puts response.read_body
  end

  def describe_index_stats(index_name = @index_name)
    super
  end

  def query(vector, includeValues: "false", includeMetadata: "false",  topK: 10, namespace: nil)
    url = URI("https://#{@url_base_index}/query")

    headers = {
      "Api-Key" => @api_key,
      "Content-Type" => "application/json",
      "Accept" => "application/json"
    }

    body = { includeValues:, includeMetadata:, vector:, topK:, namespace: }.to_json

      response = HTTParty.post(url, headers: headers, body: body)

    JSON.parse(response.body)
  end

  def update(values:, id:, namespace:, sparse_values:)
    url = URI("#{@url_base_index}/vectors/update")

    request_body = {
      values: values,
      sparseValues: {
        indices: sparse_values.keys,
        values: sparse_values.values,
      },
      id: id,
      namespace: namespace
    }

    response = send_request(url, Net::HTTP::Post, request_body)
    puts response.body
  end

  def delete(ids_array, deleteAll: "false", filter: nil, namespace:)
    url = URI("#{@url_base_index}/vectors/delete")

    request_body = {
      ids: ids_array,
      deleteAll: deleteAll,
      filter: filter,
      namespace: namespace,
    }

    response = send_request(url, Net::HTTP::Post, request_body)
    puts response.body
  end

  def upsert(vectors:, namespace: nil)
    url = URI("https://#{@url_base_index}/vectors/upsert")

    headers = {
      "Api-Key" => @api_key,
      "Content-Type" => "application/json",
      "Accept" => "application/json"
    }

    body = { vectors: vectors }.to_json

    response = HTTParty.post(url, headers: headers, body: body)

    puts response.body
  end

  def fetch(ids_array)
    ids_params = ids_array.map { |id| "ids=#{id}" }.join("&")
    url = URI("#{@url_base_index}/vectors/fetch?#{ids_params}")

    Net::HTTP.start(url.host, url.port, use_ssl: true) do |http|
      request = Net::HTTP::Get.new(url)
      request["accept"] = 'application/json'
      request["Api-Key"] = @api_key

      response = http.request(request)
      puts response.read_body
    end
  end



end
