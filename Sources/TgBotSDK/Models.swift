import Foundation

public struct Updates: Decodable {
    public var result: [Update]
}

public struct Update: Decodable {
    public var updateId: Int
    public var message: Message?

    public init(updateId: Int,
                message: Message?) {
        self.updateId = updateId
        self.message = message
    }
}

public struct User: Decodable {
    public var id: Int64

    public init(id: Int64) {
        self.id = id
    }
}

public struct Message: Decodable {
    public var chat: Chat
    public var text: String?
    public var from: User?

    public init(
        chat: Chat,
        text: String?,
        from: User?
    ) {
        self.chat = chat
        self.text = text
        self.from = from
    }
}

public struct Chat: Decodable {
    public var id: Int64

    public init(id: Int64) {
        self.id = id
    }
}

public struct ReplyKeyboardMarkup: Encodable {
    public var keyboard: [[KeyboardButton]]
    public var resizeKeyboard: Bool
    public var oneTimeKeyboard: Bool

    public init(
        keyboard: [[KeyboardButton]],
        resizeKeyboard: Bool,
        oneTimeKeyboard: Bool
    ) {
        self.keyboard = keyboard
        self.resizeKeyboard = resizeKeyboard
        self.oneTimeKeyboard = oneTimeKeyboard
    }
}

public struct KeyboardButton: Encodable {
    public var text: String

    public init(text: String) {
        self.text = text
    }
}

public struct ReplyKeyboardHide: Encodable {
    public var hide: Bool

    public init(hide: Bool) {
        self.hide = hide
    }
}

public enum ReplyMarkup: Encodable {
    case hide(ReplyKeyboardHide)
    case markup(ReplyKeyboardMarkup)

    public func encode(to encoder: Encoder) throws {
        switch self {
        case .hide(let value):
            try value.encode(to: encoder)
        case .markup(let value):
            try value.encode(to: encoder)
        }
    }
}

public struct SendMessage: Encodable {
    public var chatId: Int64
    public var text: String
    public var replyMarkup: ReplyMarkup?

    public init(
        chatId: Int64,
        text: String,
        replyMarkup: ReplyMarkup?
    ) {
        self.chatId = chatId
        self.text = text
        self.replyMarkup = replyMarkup
    }
}
