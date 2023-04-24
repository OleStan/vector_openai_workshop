class ChatGpt::AssistantService < ChatGptService
  def initialize(messages: [], main_message: MAIN_SYSTEM_MESSAGE)
    super
  end

  def send_message(message)
    contexts = EmbeddingService.new.query_vector(message)
    message = "#{contexts.join("\n----\n")}\n\n-----\n\n#{message}"
    super
  end

end
