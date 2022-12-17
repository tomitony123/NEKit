import Foundation

public enum AdapterSocketEvent: EventType {
    public var description: String {
        switch self {
        case let .socketOpened(socket, withSession: session):
            return "[AdapterSocketEvent]0 Adatper socket \(socket) starts to connect to remote with session \(session)."
        case .disconnectCalled(let socket):
            return "[AdapterSocketEvent] Disconnect is just called on adapter socket \(socket)."
        case .forceDisconnectCalled(let socket):
            return "[AdapterSocketEvent] Force disconnect is just called on adapter socket \(socket)."
        case .disconnected(let socket):
            return "[AdapterSocketEvent] Adapter socket \(socket) disconnected."
        case let .readData(data, on: socket):
            return "[AdapterSocketEvent] Received \(data.count) bytes data on adatper socket \(socket)."
        case let .wroteData(data, on: socket):
            if let data = data {
                return "[AdapterSocketEvent] Sent \(data.count) bytes data on adapter socket \(socket)."
            } else {
                return "[AdapterSocketEvent] Sent data on adapter socket \(socket)."
            }
        case let .connected(socket):
            return "[AdapterSocketEvent] Adapter socket \(socket) connected to remote."
        case .readyForForward(let socket):
            return "[AdapterSocketEvent] Adatper socket \(socket) is ready to forward data."
        case let .errorOccured(error, on: socket):
            return "[AdapterSocketEvent] Adapter socket \(socket) encountered an error \(error)."
        }
    }

    case socketOpened(AdapterSocket, withSession: ConnectSession),
    disconnectCalled(AdapterSocket),
    forceDisconnectCalled(AdapterSocket),
    disconnected(AdapterSocket),
    readData(Data, on: AdapterSocket),
    wroteData(Data?, on: AdapterSocket),
    connected(AdapterSocket),
    readyForForward(AdapterSocket),
    errorOccured(Error, on: AdapterSocket)
}
