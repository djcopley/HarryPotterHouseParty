import Vapor

class SSEController {
    private var clientWriters: [BodyStreamWriter] = []

    init() {}

    func addClient(writer: BodyStreamWriter) {
        clientWriters.append(writer)
    }

    func sendEvent() async throws {
        for writer in clientWriters {
            try? await writer.write(event: "scores_updated")
        }
    }

    static let handler = SSEController()
}

extension BodyStreamWriter {
    public func write(event: String, data: Encodable? = nil) async throws {
        guard let encodableData = data,
              let encodedData = try? JSONEncoder().encode(encodableData),
              let strData = String(data: encodedData, encoding: .utf8)
        else {
            try await self.write(.buffer(.init(string: "event:\(event)\ndata:{}\n\n"))).get()
            return
        }
        try await self.write(.buffer(.init(string: "event:\(event)\ndata:\(strData)\n\n"))).get()
    }
}
