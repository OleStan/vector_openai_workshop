class ChatChannel < ApplicationCable::Channel
  def subscribed
    @chat = ChatGpt::AssistantService.new
    stream_from "ChatChannel"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end

  def send_message(data)
    message = data['message']
    response = @chat.send_message(message)

    ActionCable.server.broadcast 'ChatChannel', { message: response }.to_json
  end
end
