import Foundation
import CocoaLumberjackSwift

/// Representing all the information in one connect session.
public final class ConnectSession {
    public enum EventSourceEnum {
        case proxy, adapter, tunnel
    }
    
    /// The requested host.
    ///
    /// This is the host received in the request. May be a domain, a real IP or a fake IP.
    public let requestedHost: String
    
    /// The real host for this session.
    ///
    /// If the session is initailized with a host domain, then `host == requestedHost`.
    /// Otherwise, the requested IP address is looked up in the DNS server to see if it corresponds to a domain if `fakeIPEnabled` is `true`.
    /// Unless there is a good reason not to, any socket shoule connect based on this directly.
    public var host: String
    
    /// The requested port.
    public let port: Int
    
    /// The rule to use to connect to remote.
    public var matchedRule: Rule?
    
    /// Whether If the `requestedHost` is an IP address.
    public let fakeIPEnabled: Bool
    
    public var error: Error?
    public var errorSource: EventSourceEnum?
    
    public var disconnectedBy: EventSourceEnum?
    
    /// The resolved IP address.
    ///
    /// - note: This will always be real IP address.
    public lazy var ipAddress: String = {
        [unowned self] in
        if self.isIP() {
            return self.host
        } else {
            let ip = Utils.DNS.resolve(self.host)
            
            guard self.fakeIPEnabled else {
                return ip
            }
            
            guard let dnsServer = DNSServer.currentServer else {
                return ip
            }
            
            guard let address = IPAddress(fromString: ip) else {
                return ip
            }
            
            guard dnsServer.isFakeIP(address) else {
                return ip
            }
            
            guard let session = dnsServer.lookupFakeIP(address) else {
                return ip
            }
            
            return session.realIP?.presentation ?? ""
        }
        }()
    
    /// The location of the host.
    public lazy var country: String = {
        [unowned self] in
        guard let c = Utils.GeoIPLookup.Lookup(self.ipAddress) else {
            return ""
        }
        return c
        }()
    
    public init?(host: String, port: Int, fakeIPEnabled: Bool = true) {
        self.requestedHost = host
        self.port = port
        
        self.fakeIPEnabled = fakeIPEnabled
        
        self.host = host
        if fakeIPEnabled {
            guard lookupRealIP() else {
                return nil
            }
        }
    }
    
    public convenience init?(ipAddress: IPAddress, port: Port, fakeIPEnabled: Bool = true) {
        self.init(host: ipAddress.presentation, port: Int(port.value), fakeIPEnabled: fakeIPEnabled)
    }
    
    func disconnected(becauseOf error: Error? = nil, by source: EventSourceEnum) {
        if disconnectedBy == nil {
            self.error = error
            if error != nil {
                errorSource = source
            }
            disconnectedBy = source
        }
    }
    
    fileprivate func lookupRealIP() -> Bool {
        /// If custom DNS server is set up.
        guard let dnsServer = DNSServer.currentServer else {
            DDLogDebug("[ConnectSession] lookupRealIP, dnsServer not exist")
            return true
        }
        
        // Only IPv4 is supported as of now.
        guard isIPv4() else {
            DDLogDebug("[ConnectSession] lookupRealIP, not IPv4")
            return true
        }
        
        let address = IPAddress(fromString: requestedHost)!
        DDLogDebug("[ConnectSession] lookupRealIP, address:\(address)")
        guard dnsServer.isFakeIP(address) else {
            DDLogDebug("[ConnectSession] lookupRealIP, isFakeIP")
            return true
        }
        
        // Look up fake IP reversely should never fail.
        guard let session = dnsServer.lookupFakeIP(address) else {
            DDLogDebug("[ConnectSession] lookupFakeIP failed")
            return false
        }
        
        host = session.requestMessage.queries[0].name
        ipAddress = session.realIP?.presentation ?? ""
        matchedRule = session.matchedRule
        
        DDLogDebug("[ConnectSession] host:\(host), ipAddress:\(ipAddress), matchedRule:\(matchedRule)")
        
        if session.countryCode != nil {
            country = session.countryCode!
            DDLogDebug("[ConnectSession] country:\(country)")
        }
        return true
    }
    
    public func isIPv4() -> Bool {
        return Utils.IP.isIPv4(host)
    }
    
    public func isIPv6() -> Bool {
        return Utils.IP.isIPv6(host)
    }
    
    public func isIP() -> Bool {
        return isIPv4() || isIPv6()
    }
}

extension ConnectSession: CustomStringConvertible {
    public var description: String {
        if requestedHost != host {
            return "<\(type(of: self)) host:\(host) port:\(port) requestedHost:\(requestedHost)>"
        } else {
            return "<\(type(of: self)) host:\(host) port:\(port)>"
        }
    }
}
