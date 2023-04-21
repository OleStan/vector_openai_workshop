class ChatGptService
  attr_accessor :chat_messages

  def initialize(messages: [], main_message: MAIN_SYSTEM_MESSAGE)
    @client = OpenAI::Client.new
    @chat_messages = []
    @model = model_available?('gpt-4') ? 'gpt-4' : 'gpt-3.5-turbo'
    @temperature = 0.7
    @chat_messages = messages.blank? ? [{ role: :system, content: main_message }] : messages
  end

  def send_message(message)
    @chat_messages << { role: 'user', content: message }
    response = chat_post
    @chat_messages << { role: 'assistant', content: response }
    response
  end

  def stream_send_message(message, model: @model, temperature: @temperature, &stream_reader)
    stream_response = []
    @chat_messages << { role: 'user', content: message }

    if Rails.env.development?
      test_string = 'from Async(default) enqueued at with arguments 1 2  3 4'
      test_string.split(' ').each_with_index do |text, index|
        resp = text + ' '
        stream_response << resp
        stream_reader.call({ 'choices' => [{ 'delta' =>  { 'content' =>  resp } }],
                             'finish_reason' => test_string.length > index + 1 ? nil : 'stop' }) if stream_reader
        sleep 0.1
      end
      resp = stream_response.join
      @chat_messages << { role: 'assistant', content: resp }
      return resp
    end

    url = URI('https://api.openai.com/v1/chat/completions')
    https = Net::HTTP.new(url.host, url.port)
    https.use_ssl = true
    request = Net::HTTP::Post.new(url)
    request["Content-Type"] = 'application/json'
    request["Authorization"] = "Bearer #{ENV['OPENAI_ACCESS_TOKEN']}"
    body = {
      model: model, # Required.
      messages: @chat_messages, # Required.
      temperature: temperature,
      stream: true
    }
    request.body = JSON.dump(body)
    # ToDo: add error handler
    Net::HTTP.start(url.host, url.port, use_ssl: true) do |http|
      http.request(request) do |response|
        response.read_body do |chunk|
          chunk_body = read_chunk(chunk)[0]
          stream_response << chunk_response(chunk_body)
          stream_reader.call(chunk_body) if stream_reader
        end
      end
    end
    stream_response_join = stream_response.join
    @chat_messages << { role: 'assistant', content: stream_response_join }
    stream_response_join
  end

  private

  def chat_post(model: @model, temperature: @temperature)
    response = @client.chat(
      parameters: {
        model: model, # Required.
        messages: @chat_messages, # Required.
        temperature: temperature,
      })
    # ToDo: handle error 429 - The engine is currently overloaded, please try again later
    case finish_reason(response)
    when 'stop'
      content(response)
    when 'length'
      'Sorry, the model output is incomplete due to the max_tokens parameter or token limit.'
    when 'content_filter'
      'Sorry, some content has been omitted due to our content filters.'
    when nil
      'Sorry, the API response is still in progress or incomplete.'
    else
      "Error: #{response}"
    end
  rescue StandardError => e
    puts "Error: #{e.message}"
    "I'm sorry, something went wrong."
  end

  def finish_reason(response)
    response.dig('choices', 0, 'finish_reason')
  end

  def content(response)
    response.dig('choices', 0, 'message', 'content')
  end

  def chunk_delta(response)
    response.dig('choices', 0, 'delta')
  end

  def chunk_response(response)
    response.dig('choices', 0, 'delta', 'content')
  end

  # check is model available
  def model_available?(model_name)
    @client.models.list['data'].map { |model| model['id'] }.include?(model_name)
  end

  def read_chunk(chunk)
    split_chunk = chunk.split('data: ')
    chunk_data = []
    split_chunk.each do |data|
      next if data.empty? || data == "[DONE]\n\n"
      parsed_data = JSON.parse(data.strip)
      chunk_data << parsed_data unless chunk_delta(parsed_data)['role'].present?
    end
    chunk_data.compact
  end

end

=begin
Response format

{
  'id': 'chatcmpl-6p9XYPYSTTRi0xEviKjjilqrWU2Ve',
  'object': 'chat.completion',
  'created': 1677649420,
  'model': 'gpt-3.5-turbo',
  'usage': {'prompt_tokens': 56, 'completion_tokens': 31, 'total_tokens': 87},
  'choices': [
    {
      'message': {
        'role': 'assistant',
        'content': 'The 2020 World Series was played in Arlington, stadium for the Texas Rangers.'},
      'finish_reason': 'stop',
      'index': 0
    }
  ]
}
=end
