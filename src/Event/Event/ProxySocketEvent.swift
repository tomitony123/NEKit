import Foundation

public enum ProxySocketEvent: EventType {
    public var description: String {
        switch self {
        case .socketOpened(let socket):
            return "[ProxySocketEvent]0 Start processing data from proxy socket \(socket)."
        case .disconnectCalled(let socket):
            return "[ProxySocketEvent] Disconnect is just called on proxy socket \(socket)."
        case .forceDisconnectCalled(let socket):
            return "[ProxySocketEvent] Force disconnect is just called on proxy socket \(socket)."
        case .disconnected(let socket):
            return "[ProxySocketEvent] Proxy socket \(socket) disconnected."
        case let .receivedRequest(session, on: socket):
            return "[ProxySocketEvent] Proxy socket \(socket) received request \(session)."
        case let .readData(data, on: socket):
            return "[ProxySocketEvent] Received \(data.count) bytes data on proxy socket \(socket)."
        case let .wroteData(data, on: socket):
            if let data = data {
                return "[ProxySocketEvent] Sent \(data.count) bytes data on proxy socket \(socket)."
            } else {
                return "[ProxySocketEvent] Sent data on proxy socket \(socket)."
            }
        case let .askedToResponseTo(adapter, on: socket):
            return "[ProxySocketEvent] Proxy socket \(socket) is asked to respond to adapter \(adapter)."
        case .readyForForward(let socket):
            return "[ProxySocketEvent] Proxy socket \(socket) is ready to forward data."
        case let .errorOccured(error, on: socket):
            return "[ProxySocketEvent] Proxy socket \(socket) encountered an error \(error)."
        }
    }

    case socketOpened(ProxySocket),
    disconnectCalled(ProxySocket),
    forceDisconnectCalled(ProxySocket),
    disconnected(ProxySocket),
    receivedRequest(ConnectSession, on: ProxySocket),
    readData(Data, on: from),
    wroteData(Data?, on: ProxySocket),
    askedToResponseTo(AdapterSocket, on: ProxySocket),
    readyForForward(ProxySocket),
    errorOccured(Error, on: ProxySocket)
}
