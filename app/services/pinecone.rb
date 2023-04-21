class Pinecone

  def initialize(index_name: nil)
    @environment = ENV.fetch('PINECONE_ENVIRONMENT')
    @api_key = ENV.fetch('PINECONE_API_KEY')
    @url_base_index = nil
  end

  def whoami
    url = URI("https://controller.#{@environment}.pinecone.io/actions/whoami")

    https = Net::HTTP.new(url.host, url.port)
    https.use_ssl = true

    request = Net::HTTP::Get.new(url)
    request["Api-Key"] = @api_key

    response = https.request(request)
    puts response.read_body
  end

  def list_indexes
    url = URI("https://controller.#{@environment}.pinecone.io/databases")

    headers = {
      "Api-Key": @api_key,
      "Accept": "application/json; charset=utf-8"
    }

    response = HTTParty.get(url, headers: headers, verify: true)

    JSON.parse(response.body)
  end

  def describe_index_stats(index_name)
    url = URI("https://controller.#{@environment}.pinecone.io/databases/#{index_name}")

    headers = {
      "Api-Key": @api_key,
      "Accept": "application/json; charset=utf-8"
    }

    response = HTTParty.get(url, headers: headers, verify: true)
    response_body = JSON.parse(response.body)
    @url_base_index = response_body.dig('status', 'host')
    response_body
  end

end
