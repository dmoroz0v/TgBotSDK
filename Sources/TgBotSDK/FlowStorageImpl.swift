import Foundation
import ChatBotSDK
import SQLite

public final class FlowStorageImpl: FlowStorage {

    private let db: Connection

    let flows = Table("flows")
    let id = Expression<Int64>("id")
    let value = Expression<String>("value")

    public init() throws {
        db = try Connection("db.sqlite3")

        _ = try? db.run(flows.create { t in
            t.column(id, primaryKey: true)
            t.column(value)
        })
    }

    public func save(value: String?, userId: Int64) {
        if let value = value {
            let insert = flows.insert(self.value <- value, id <- userId)
            _ = try? db.run(insert)
        } else {
            let flow = flows.filter(id == userId)
            _ = try? db.run(flow.delete())
        }
    }

    public func fetch(userId: Int64) -> String? {
        let flow = flows.filter(id == userId)
        guard let result = try? db.prepare(flow) else {
            return nil
        }
        return Array(result).first?[value]
    }

}

