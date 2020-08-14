import Foundation
import ChatBotSDK
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

public final class Bot {

    private let token: String
    private let apiEndpoint: String

    private lazy var operationQueue = OperationQueue()
    private lazy var session = URLSession(
        configuration: .default,
        delegate: nil,
        delegateQueue: operationQueue)

    private let bot: ChatBotSDK.Bot

    private var offset: Int?

    public init(
        flowStorage: FlowStorage,
        botAssembly: BotAssembly,
        token: String,
        apiEndpoint: String
    ) {
        bot = ChatBotSDK.Bot(
            flowStorage: flowStorage,
            commandsHandlers: botAssembly.commandsHandlers
        )
        self.token = token
        self.apiEndpoint = apiEndpoint
    }

    public func handleUpdates() {
        let updates = _getUpdates(timeout: 10, offset: offset)
        let updatesResult = (updates?.result ?? []).sorted(by: { left, right in
            left.updateId > right.updateId
        })
        if let update = updatesResult.first {
            offset = update.updateId + 1
            handleUpdate(update: update)
        }
    }

    public func handleUpdate(json: String) {
        let update = _parseUpdate(json: json)
        if let update = update {
            handleUpdate(update: update)
        }
    }

    public func handleUpdate(update: Update) {
        if let chatId = update.message?.chat.id,
           let userId = update.message?.from?.id,
           let text = update.message?.text {

            let result = bot.update(chatId: chatId, userId: userId, text: text)

            let replyMarkup: ReplyMarkup
            if let keyboard = result.keyboard {
                let markup = replyKeyboardMarkup(keyboard: keyboard)
                replyMarkup = .markup(markup)
            } else {
                replyMarkup = .hide(ReplyKeyboardHide(hide: true))
            }

            for text in result.texts {
                let sendMessage = SendMessage(
                    chatId: chatId,
                    text: text,
                    replyMarkup: replyMarkup)

                _sendMessage(messege: sendMessage)
            }
        }
    }

    private func replyKeyboardMarkup(
        keyboard: ChatBotSDK.ReplyKeyboardMarkup
    ) -> TgBotSDK.ReplyKeyboardMarkup {
        return .init(
            keyboard: keyboard.keyboard.map({ row in
                return row.map {
                    return TgBotSDK.KeyboardButton(text: $0.text)
                }
            }),
            resizeKeyboard: keyboard.resizeKeyboard,
            oneTimeKeyboard: keyboard.oneTimeKeyboard
        )
    }

    private func _parseUpdate(json: String) -> Update? {
        guard let data = json.data(using: .utf8) else {
            return nil
        }
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return try? decoder.decode(Update.self, from: data)
    }

    private func _getUpdates(timeout: Int = 0, offset: Int? = nil) -> Updates? {
        var url = URL(string: apiEndpoint + token + "/getUpdates")!
        var components = URLComponents(url: url, resolvingAgainstBaseURL: false)!
        var queryItems = components.queryItems ?? []
        if let offset = offset {
            queryItems.append(.init(name: "offset", value: "\(offset)"))
        }
        if timeout != 0 {
            queryItems.append(.init(name: "timeout", value: "\(timeout)"))
        }
        components.queryItems = queryItems
        url = components.url!
        let urlRequest = URLRequest(url: url)

        var updates: Updates?

        let semaphore = DispatchSemaphore(value: 0)

        let task = session.dataTask(with: urlRequest) { data, response, error in
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase

            if let data = data {
                updates = try? decoder.decode(Updates.self, from: data)
            }

            semaphore.signal()
        }
        task.resume()

        semaphore.wait()

        return updates
    }

    private func _sendMessage(messege: SendMessage) {
        let url = URL(string: apiEndpoint + token + "/sendMessage")!
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        let body = try? encoder.encode(messege)
//        if let body = body {
//            print(String(data: body, encoding: .utf8))
//        }
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.httpBody = body
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let task = session.dataTask(with: urlRequest) { data, response, error in
//            print(String(data: data!, encoding: .utf8))
//            print(response)
//            print(error)
        }
        task.resume()
    }

}
