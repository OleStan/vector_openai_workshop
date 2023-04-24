class PagesController < ApplicationController
  def index; end

  def chat
    message = params[:message]

    respond_to do |format|
      format.json do
        # response = ChatGpt::AssistantService.new.send_message(message)
        response = "ChatGpt::AssistantService.new.send_message(message)"
        render json: { message: response }
      end
      format.turbo_stream do
        # response = ChatGpt::AssistantService.new.send_message(message)
        response = "ChatGpt::AssistantService.new.send_message(message)2"
        render turbo_stream: turbo_stream.replace(
        "dialog-window",
        partial: "chat_message",
        locals: { message: response }
        )
      end
    end
  end
end
