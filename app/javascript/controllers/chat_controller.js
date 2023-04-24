import {Controller} from "@hotwired/stimulus"
import consumer from "channels/consumer";
// import consumer from "channels/consumer";

export default class extends Controller {
    static targets = ["messageInput", "chatWindow"]

    connect() {
        this.messageInputTarget.focus()

        this.subscription = consumer.subscriptions.create(
            {
                channel: "ChatChannel",
                id: this.data.get("id"),
            },
            {
                connected: this._connected.bind(this),
                disconnected: this._disconnected.bind(this),
                received: this._received.bind(this),
            }
        );
        console.log("connect", this.subscription);
    }

    _connected() {
    }

    _disconnected() {
    }

    _received(data) {
        const parsed_data = JSON.parse(data);
        const assistantMessage = document.createElement("div")
        assistantMessage.classList.add("border", "px-10", "py-4", "max-w-md", "w-max", "border-gray", "bg-slate-400", "rounded-r-lg", "rounded-tl-lg", "self-start")
        assistantMessage.textContent = parsed_data.message
        this.chatWindowTarget.appendChild(assistantMessage)
        this.messageInputTarget.value = ""
    }


    sendMessage(event) {
        event.preventDefault()
        const message = this.messageInputTarget.value.trim()

        if (message !== "") {
            const userMessage = document.createElement("div")
            userMessage.classList.add("border", "px-10", "py-4", "max-w-md", "w-max", "border-blue", "bg-sky-400", "rounded-l-lg", "rounded-tr-lg", "self-end")
            userMessage.textContent = message
            this.chatWindowTarget.appendChild(userMessage)

            this.subscription.perform("send_message", {message: message});
        }
    }

    getMetaValue(name) {
        const element = document.head.querySelector(`meta[name="${name}"]`)
        return element.getAttribute("content")
    }
}
