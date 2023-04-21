class Pinecone::Vector < Pinecone::Index
  def initialize
    super
    @url_base_index = "https://index_name-project_id.svc.#{@environment}.pinecone.io"
  end

  def describe_index_stats(filter_object = nil)
    url = URI("#{@url_base_index}/describe_index_stats")

    response = send_request(url, Net::HTTP::Post, { filter: filter_object })
    puts response.body
  end

  def query(includeValues: "false", includeMetadata: "false", vector:, topK:, namespace:)
    url = URI("#{@url_base_index}/query")

    response = send_request(url, Net::HTTP::Post, { includeValues:, includeMetadata:, vector:, topK:, namespace: })
    puts response.body
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
    url = URI("#{@url_base_index}/vectors/upsert")

    headers = {
      "Api-Key" => @api_key,
      "Content-Type" => "application/json",
      "Accept" => "application/json"
    }

    body = { vectors: vectors, namespace: namespace }.to_json

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
