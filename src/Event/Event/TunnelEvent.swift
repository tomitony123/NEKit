import Foundation

public enum TunnelEvent: EventType {
    public var description: String {
        switch self {
        case .opened(let tunnel):
            return "[TunnelEvent]0 Tunnel \(tunnel) starts processing data."
        case .closeCalled(let tunnel):
            return "[TunnelEvent] Close is called on tunnel \(tunnel)."
        case .forceCloseCalled(let tunnel):
            return "[TunnelEvent] Force close is called on tunnel \(tunnel)."
        case let .receivedRequest(request, from: socket, on: tunnel):
            return "[TunnelEvent] Tunnel(proxy socket) \(tunnel) received request \(request) from proxy socket \(socket)."
        case let .receivedReadySignal(socket, currentReady: signal, on: tunnel):
            if signal == 1 {
                return "[TunnelEvent] Tunnel(signal from socket) \(tunnel) received ready-for-forward signal from socket \(socket)."
            } else {
                return "[TunnelEvent] Tunnel(signal from socket) \(tunnel) received ready-for-forward signal from socket \(socket). Start forwarding data."
            }
        case let .proxySocketReadData(data, from: socket, on: tunnel):
            return "[TunnelEvent] Tunnel \(tunnel) received \(data.count) bytes from proxy socket \(socket)."
        case let .proxySocketWroteData(data, by: socket, on: tunnel):
            if let data = data {
                return "[TunnelEvent] Proxy socket \(socket) sent \(data.count) bytes data from Tunnel \(tunnel)."
            } else {
                return "[TunnelEvent] Proxy socket \(socket) sent data from Tunnel \(tunnel)."
            }
        case let .adapterSocketReadData(data, from: socket, on: tunnel):
            return "[TunnelEvent] Tunnel(adapter) \(tunnel) received \(data.count) bytes from adapter socket \(socket)."
        case let .adapterSocketWroteData(data, by: socket, on: tunnel):
            if let data = data {
                return "[TunnelEvent] Adatper socket \(socket) sent \(data.count) bytes data from Tunnel \(tunnel)."
            } else {
                return "[TunnelEvent] Adapter socket \(socket) sent data from Tunnel \(tunnel)."
            }
        case let .connectedToRemote(socket, on: tunnel):
            return "[TunnelEvent] Adapter socket \(socket) connected to remote successfully on tunnel \(tunnel)."
        case let .updatingAdapterSocket(from: old, to: new, on: tunnel):
            return "[TunnelEvent] Updating adapter socket of tunnel \(tunnel) from \(old) to \(new)."
        case .closed(let tunnel):
            return "[TunnelEvent] Tunnel \(tunnel) closed."
        }
    }

    case opened(Tunnel),
    closeCalled(Tunnel),
    forceCloseCalled(Tunnel),
    receivedRequest(ConnectSession, from: ProxySocket, on: Tunnel),
    receivedReadySignal(SocketProtocol, currentReady: Int, on: Tunnel),
    proxySocketReadData(Data, from: ProxySocket, on: Tunnel),
    proxySocketWroteData(Data?, by: ProxySocket, on: Tunnel),
    adapterSocketReadData(Data, from: AdapterSocket, on: Tunnel),
    adapterSocketWroteData(Data?, by: AdapterSocket, on: Tunnel),
    connectedToRemote(AdapterSocket, on: Tunnel),
    updatingAdapterSocket(from: AdapterSocket, to: AdapterSocket, on: Tunnel),
    closed(Tunnel)
}
