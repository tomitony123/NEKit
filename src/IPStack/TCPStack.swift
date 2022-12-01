import Foundation
import tun2socks
import CocoaLumberjackSwift

/// This class wraps around tun2socks to build a TCP only IP stack.
open class TCPStack: TSIPStackDelegate, IPStackProtocol {
    /// The `TCPStack` singleton instance.
    public static var stack: TCPStack {
        TSIPStack.stack.delegate = _stack
        TSIPStack.stack.processQueue = QueueFactory.getQueue()
        return _stack
    }
    fileprivate static let _stack: TCPStack = TCPStack()
    
    /// The proxy server that handles connections accepted from this stack.
    ///
    /// - warning: This must be set before `TCPStack` is registered to `TUNInterface`.
    open weak var proxyServer: ProxyServer?
    
    /// This is set automatically when the stack is registered to some interface.
    open var outputFunc: (([Data], [NSNumber]) -> Void)! {
        get {
            return TSIPStack.stack.outputBlock
        }
        set {
            TSIPStack.stack.outputBlock = newValue
        }
    }
    
    /**
     Inistailize a new TCP stack.
     */
    fileprivate init() {
    }
    
    /**
     Input a packet into the stack.
     
     - note: Only process IPv4 TCP packet as of now, since stable lwip does not support ipv6 yet.
     
     - parameter packet:  The IP packet.
     - parameter version: The version of the IP packet, i.e., AF_INET, AF_INET6.
     
     - returns: If the stack takes in this packet. If the packet is taken in, then it won't be processed by other IP stacks.
     */
    open func input(packet: Data, version: NSNumber?) -> Bool {
        if let version = version {
            // we do not process IPv6 packets now
            if version.int32Value == AF_INET6 {
                DDLogDebug("(debugz)TCPStack.input, not process IPv6 packets, return")
                return false
            }
        }
        if IPPacket.peekProtocol(packet) == .tcp {
            TSIPStack.stack.received(packet: packet)
            return true
        }
        
        DDLogDebug("(debugz)TCPStack.input, packet not tcp, return")
        return false
    }
    
    public func start() {
        TSIPStack.stack.resumeTimer()
    }
    
    /**
     Stop the TCP stack.
     
     After calling this, this stack should never be referenced. Use `TCPStack.stack` to get a new reference of the singleton.
     */
    open func stop() {
        TSIPStack.stack.delegate = nil
        TSIPStack.stack.suspendTimer()
        proxyServer = nil
    }
    
    // MARK: TSIPStackDelegate Implementation
    open func didAcceptTCPSocket(_ sock: TSTCPSocket) {
//        DDLogDebug("(debugz)didAcceptTCPSocket, Accepted a new socket from IP stack.")
        let tunSocket = TUNTCPSocket(socket: sock)
    
        DDLogDebug("(debugz)TCPStack.didAcceptTCPSocket, Accepted a new IP stack. sourceIPAddress:\(tunSocket.sourceIPAddress), destinationIPAddress:\(tunSocket.destinationIPAddress)")
        
        let proxySocket = DirectProxySocket(socket: tunSocket)
        self.proxyServer!.didAcceptNewSocket(proxySocket)
    }
}
