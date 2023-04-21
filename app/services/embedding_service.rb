class EmbeddingService
  def initialize
    @client = OpenAI::Client.new
    @new_data = []
    @embed_mode = "text-embedding-ada-002"
  end

  def embed(index_name:, embed_mode: @embed_mode)
    res = @client.embeddings(
      parameters: {
        model: embed_mode,
        input: "The food was delicious and the waiter..."
      }
    )
    dimensions = res['data'][0]['embedding'].length

    index = Pinecone::Index.new(index_name: index_name)
    # check if index already exists (it shouldn't if this is first time)
    index.create_index(dimension: dimensions) if index.list_indexes.exclude?(index_name)
    # view index stats
    index.describe_index_stats

    data_prepare_preloaded

    batch_size = 100 # how many embeddings we create and insert at once

    (0..@new_data.length).step(batch_size) do |i|
      # find end of batch
      i_end = [@new_data.length, i + batch_size].min
      meta_batch = @new_data[i...i_end]
      # get ids
      ids_batch = meta_batch.map { |x| x['id'] }
      # get texts to encode
      texts = meta_batch.map { |x| x['text'] }
      # create embeddings (begin-rescue added to avoid RateLimitError)
      begin
        res = @client.embeddings(parameters: { model: embed_mode, input: texts })
      rescue
        done = false
        while !done do
          sleep(5)
          begin
            res = @client.embeddings(parameters: { model: embed_mode, input: texts })
            done = true
          rescue
            # do nothing and retry
          end
        end
      end
      embeds = res['data'].map { |record| record['embedding'] }
      # cleanup metadata
      meta_batch = meta_batch.map do |x|
        {
          'start': x['start'],
          'end': x['end'],
          'title': x['title'],
          'text': x['text'],
          'url': x['url'],
          'published': x['published'],
          'channel_id': x['channel_id']
        }
      end


      to_upsert = ids_batch.map.with_index { |id, index| { id: id, values: embeds[index], metadata: meta_batch[index] } }
      index.upsert(vectors: to_upsert)
    end
  end

  def data_prepare_preloaded(file_name = "youtube-transcriptions.jsonl")
    file_path = File.join(Rails.root, 'vendor', 'datasets', file_name)
    data = []
    File.foreach(file_path) do |line|
      data << JSON.parse(line)
    end

    window = 20 # number of sentences to combine
    stride = 4 # number of sentences to 'stride' over, used to create overlap

    (0...data.length).with_progress.step(stride).each do |i|
      i_end = [data.length - 1, i + window].min
      next if data[i]['title'] != data[i_end]['title'] # skip if start/end of two videos
      text = data[i..i_end].map { |d| d['text'] }.join(' ')
      @new_data << {
        'start' => data[i]['start'],
        'end' => data[i_end]['end'],
        'title' => data[i]['title'],
        'text' => text,
        'id' => data[i]['id'],
        'url' => data[i]['url'],
        'published' => data[i]['published'],
        'channel_id' => data[i]['channel_id']
      }
    end
    @new_data
  end

  def query_vector(query:, embed_mode: @embed_mode)
    # create query vector
    res = @client.embeddings(
      parameters: {
        model: embed_mode,
        input: query
      }
    )
    xq = res['data'][0]['embedding']
    # connect to vector db
    @index = Pinecone::Index.new(index_name: "youtube-transcriptions")

    # search in vector db
    res = @index.query(xq, topK: 2, includeMetadata: true)
    res['matches'].map { |match| match['metadata']['text'] }
  end

  def question_example_completion(query:, contexts:, max_tokens: 400, model: "text-davinci-001")
    question_prompt = "You are a helpful AI assistant. Use the following pieces of context to answer the question at the end.
If you don't know the answer, just say you don't know. DO NOT try to make up an answer.
If the question is not related to the context, politely respond that you are tuned to only answer questions that are related to the context.
#{contexts.join("\n----\n")}
Question: #{query}
Helpful answer in markdown:"

    @client.completions(
      parameters: {
        model:,
        prompt: question_prompt,
        max_tokens:
      })
  end

  def question_example_chat(query:, contexts:)
    augmented_query = "#{contexts.join("\n----\n")}\n\n-----\n\n#{query}"

    @client.chat(
      parameters: {
        model: "gpt-3.5-turbo", # Required.
        messages: [{ role: "system", content: MAIN_SYSTEM_MESSAGE },
                   { role: "user", content: augmented_query }], # Required.
        temperature: 0.7,
      })

  end

  def data_prepare(text) end
end
