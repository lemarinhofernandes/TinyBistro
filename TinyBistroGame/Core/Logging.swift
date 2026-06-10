import Foundation

protocol BistroLogging {
    func log(_ message: String)
}

struct SilentBistroLogger: BistroLogging {
    func log(_ message: String) {}
}

struct ConsoleBistroLogger: BistroLogging {
    func log(_ message: String) {
        print(message)
    }
}
