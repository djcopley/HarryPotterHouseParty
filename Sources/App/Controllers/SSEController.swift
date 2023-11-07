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
    public func write(event: String) async throws {
        try await self.write(.buffer(.init(string: "event:\(event)\ndata:{}\n\n"))).get()
    }
}
