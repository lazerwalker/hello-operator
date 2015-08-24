/*
* SwiftWebSocket (websocket.swift)
*
* Copyright (C) 2015 ONcast, LLC. All Rights Reserved.
* Created by Josh Baker (joshbaker77@gmail.com)
*
* This software may be modified and distributed under the terms
* of the MIT license.  See the LICENSE file for details.
*
*/

import Foundation

private let windowBufferSize = 0x2000

private class Payload {
    var ptr : UnsafeMutablePointer<UInt8>
    var cap : Int
    var len : Int
    init(){
        len = 0
        cap = windowBufferSize
        ptr = UnsafeMutablePointer<UInt8>(malloc(cap))
    }
    deinit{
        free(ptr)
    }
    var count : Int {
        get {
            return len
        }
        set {
            if newValue > cap {
                while cap < newValue {
                    cap *= 2
                }
                ptr = UnsafeMutablePointer<UInt8>(realloc(ptr, cap))
            }
            len = newValue
        }
    }
    func append(bytes: UnsafePointer<UInt8>, length: Int){
        let prevLen = len
        count = len+length
        memcpy(ptr+prevLen, bytes, length)
    }
    var array : [UInt8] {
        get {
            var array = [UInt8](count: count, repeatedValue: 0)
            memcpy(&array, ptr, count)
            return array
        }
        set {
            count = 0
            append(newValue, length: newValue.count)
        }
    }
    var nsdata : NSData {
        get {
            return NSData(bytes: ptr, length: count)
        }
        set {
            count = 0
            append(UnsafePointer<UInt8>(newValue.bytes), length: newValue.length)
        }
    }
    var buffer : UnsafeBufferPointer<UInt8> {
        get {
            return UnsafeBufferPointer<UInt8>(start: ptr, count: count)
        }
        set {
            count = 0
            append(newValue.baseAddress, length: newValue.count)
        }
    }
}

private enum OpCode : UInt8, CustomStringConvertible {
    case Continue = 0x0, Text = 0x1, Binary = 0x2, Close = 0x8, Ping = 0x9, Pong = 0xA
    var isControl : Bool {
        switch self {
        case .Close, .Ping, .Pong:
            return true
        default:
            return false
        }
    }
    var description : String {
        switch self {
        case Continue: return "Continue"
        case Text: return "Text"
        case Binary: return "Binary"
        case Close: return "Close"
        case Ping: return "Ping"
        case Pong: return "Pong"
        }
    }
}

/// The WebSocketEvents struct is used by the events property and manages the events for the WebSocket connection.
public struct WebSocketEvents {
    /// An event to be called when the WebSocket connection's readyState changes to .Open; this indicates that the connection is ready to send and receive data.
    public var open : ()->() = {}
    /// An event to be called when the WebSocket connection's readyState changes to .Closed.
    public var close : (code : Int, reason : String, wasClean : Bool)->() = {(code, reason, wasClean) in}
    /// An event to be called when an error occurs.
    public var error : (error : ErrorType)->() = {(error) in}
    /// An event to be called when a message is received from the server.
    public var message : (data : Any)->() = {(data) in}
    /// An event to be called when a pong is received from the server.
    public var pong : (data : Any)->() = {(data) in}
    /// An event to be called when the WebSocket process has ended; this event is guarenteed to be called once and can be used as an alternative to the "close" or "error" events.
    public var end : (code : Int, reason : String, wasClean : Bool, error : ErrorType?)->() = {(code, reason, wasClean, error) in}
}

/// The WebSocketBinaryType enum is used by the binaryType property and indicates the type of binary data being transmitted by the WebSocket connection.
public enum WebSocketBinaryType : CustomStringConvertible {
    /// The WebSocket should transmit [UInt8] objects.
    case UInt8Array
    /// The WebSocket should transmit NSData objects.
    case NSData
    /// The WebSocket should transmit UnsafeBufferPointer<UInt8> objects. This buffer is only valid during the scope of the message event. Use at your own risk.
    case UInt8UnsafeBufferPointer
    public var description : String {
        switch self {
        case UInt8Array: return "UInt8Array"
        case NSData: return "NSData"
        case UInt8UnsafeBufferPointer: return "UInt8UnsafeBufferPointer"
        }
    }
}

/// The WebSocketReadyState enum is used by the readyState property to describe the status of the WebSocket connection.
public enum WebSocketReadyState : Int, CustomStringConvertible {
    /// The connection is not yet open.
    case Connecting = 0
    /// The connection is open and ready to communicate.
    case Open = 1
    /// The connection is in the process of closing.
    case Closing = 2
    /// The connection is closed or couldn't be opened.
    case Closed = 3
    private var isClosed : Bool {
        switch self {
        case .Closing, .Closed:
            return true
        default:
            return false
        }
    }
    /// Returns a string that represents the ReadyState value.
    public var description : String {
        switch self {
        case Connecting: return "Connecting"
        case Open: return "Open"
        case Closing: return "Closing"
        case Closed: return "Closed"
        }
    }
}

private let defaultMaxWindowBits = 15
/// The WebSocketCompression struct is used by the compression property and manages the compression options for the WebSocket connection.
public struct WebSocketCompression {
    /// Used to accept compressed messages from the server. Default is true.
    public var on = false
    /// request no context takeover.
    public var noContextTakeover = false
    /// request max window bits.
    public var maxWindowBits = defaultMaxWindowBits
}

/// The WebSocketService options are used by the services property and manages the underlying socket services.
public struct WebSocketService :  OptionSetType {
    public typealias RawValue = UInt
    var value: UInt = 0
    init(_ value: UInt) { self.value = value }
    public init(rawValue value: UInt) { self.value = value }
    public init(nilLiteral: ()) { self.value = 0 }
    public static var allZeros: WebSocketService { return self.init(0) }
    static func fromMask(raw: UInt) -> WebSocketService { return self.init(raw) }
    public var rawValue: UInt { return self.value }
    /// No services.
    static var None: WebSocketService { return self.init(0) }
    /// Allow socket to handle VoIP.
    static var VoIP: WebSocketService { return self.init(1 << 0) }
    /// Allow socket to handle video.
    static var Video: WebSocketService { return self.init(1 << 1) }
    /// Allow socket to run in background.
    static var Background: WebSocketService { return self.init(1 << 2) }
    /// Allow socket to handle voice.
    static var Voice: WebSocketService { return self.init(1 << 3) }
}

/// WebSocket objects are bidirectional network streams that communicate over HTTP. RFC 6455.
public class WebSocket: Hashable {
    private var id : Int
    private var mutex = pthread_mutex_t()
    private var cond = pthread_cond_t()
    private let request : NSURLRequest!
    private let subProtocols : [String]!
    private var frames : [Frame] = []
    private var delegate : Delegate
    private var inflater : Inflater!
    private var deflater : Deflater!
    private var outputBytes : UnsafeMutablePointer<UInt8>
    private var outputBytesSize : Int = 0
    private var outputBytesStart : Int = 0
    private var outputBytesLength : Int = 0
    private var inputBytes : UnsafeMutablePointer<UInt8>
    private var inputBytesSize : Int = 0
    private var inputBytesStart : Int = 0
    private var inputBytesLength : Int = 0
    private var _eventQueue : dispatch_queue_t? = dispatch_get_main_queue()
    private var _subProtocol = ""
    private var _compression = WebSocketCompression()
    private var _services = WebSocketService.None
    private var _event = WebSocketEvents()
    private var _binaryType = WebSocketBinaryType.UInt8Array
    private var _readyState = WebSocketReadyState.Connecting
    private var _networkTimeout = NSTimeInterval(-1)
    
    /// The URL as resolved by the constructor. This is always an absolute URL. Read only.
    public var url : String {
        return request.URL!.description
    }
    /// A string indicating the name of the sub-protocol the server selected; this will be one of the strings specified in the protocols parameter when creating the WebSocket object.
    public var subProtocol : String {
        get { return privateSubProtocol }
    }
    private var privateSubProtocol : String {
        get { lock(); defer { unlock() }; return _subProtocol }
        set { lock(); defer { unlock() }; _subProtocol = newValue }
    }
    /// The compression options of the WebSocket.
    public var compression : WebSocketCompression {
        get { lock(); defer { unlock() }; return _compression }
        set { lock(); defer { unlock() }; _compression = newValue }
    }
    /// The services of the WebSocket.
    public var services : WebSocketService {
        get { lock(); defer { unlock() }; return _services }
        set { lock(); defer { unlock() }; _services = newValue }
    }
    /// The events of the WebSocket.
    public var event : WebSocketEvents {
        get { lock(); defer { unlock() }; return _event }
        set { lock(); defer { unlock() }; _event = newValue }
    }
    /// The queue for firing off events. default is main_queue
    public var eventQueue : dispatch_queue_t? {
        get { lock(); defer { unlock() }; return _eventQueue; }
        set { lock(); defer { unlock() }; _eventQueue = newValue }
    }
    /// A WebSocketBinaryType value indicating the type of binary data being transmitted by the connection. Default is .UInt8Array.
    public var binaryType : WebSocketBinaryType {
        get { lock(); defer { unlock() }; return _binaryType }
        set { lock(); defer { unlock() }; _binaryType = newValue }
    }
    /// The current state of the connection; this is one of the WebSocketReadyState constants. Read only.
    public var readyState : WebSocketReadyState {
        get { return privateReadyState }
    }
    private var privateReadyState : WebSocketReadyState {
        get { lock(); defer { unlock() }; return _readyState }
        set { lock(); defer { unlock() }; _readyState = newValue }
    }
    
    public var hashValue: Int { return id }

    /// Create a WebSocket connection to a URL; this should be the URL to which the WebSocket server will respond.
    public convenience init(_ url: String){
        self.init(request: NSURLRequest(URL: NSURL(string: url)!), subProtocols: [])
    }
    /// Create a WebSocket connection to a URL; this should be the URL to which the WebSocket server will respond. Also include a list of protocols.
    public convenience init(_ url: String, subProtocols : [String]){
        self.init(request: NSURLRequest(URL: NSURL(string: url)!), subProtocols: subProtocols)
    }
    /// Create a WebSocket connection to a URL; this should be the URL to which the WebSocket server will respond. Also include a protocol.
    public convenience init(_ url: String, subProtocol : String){
        self.init(request: NSURLRequest(URL: NSURL(string: url)!), subProtocols: [subProtocol])
    }
    /// Create a WebSocket connection from an NSURLRequest; Also include a list of protocols.
    public init(request: NSURLRequest, subProtocols : [String] = []){
        pthread_mutex_init(&mutex, nil)
        pthread_cond_init(&cond, nil)
        self.id = manager.nextId()
        self.request = request
        self.subProtocols = subProtocols
        self.outputBytes = UnsafeMutablePointer<UInt8>.alloc(windowBufferSize)
        self.outputBytesSize = windowBufferSize
        self.inputBytes = UnsafeMutablePointer<UInt8>.alloc(windowBufferSize)
        self.inputBytesSize = windowBufferSize
        self.delegate = Delegate()
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0), dispatch_get_main_queue()){
            manager.add(self)
        }
    }
    deinit{
        if outputBytes != nil {
            free(outputBytes)
        }
        if inputBytes != nil {
            free(inputBytes)
        }
        pthread_cond_init(&cond, nil)
        pthread_mutex_init(&mutex, nil)
    }
    @inline(__always) private func lock(){
        pthread_mutex_lock(&mutex)
    }
    @inline(__always) private func unlock(){
        pthread_mutex_unlock(&mutex)
    }

    private var dirty : Bool {
        lock()
        defer { unlock() }
        if exit {
            return false
        }
        if stage != .ReadResponse && stage != .HandleFrames {
            return true
        }
        if rd.streamStatus != .Open || wr.streamStatus != .Open {
            return true
        }
        if rd.streamError != nil || wr.streamError != nil {
            return true
        }
        if rd.hasBytesAvailable || frames.count > 0 || inputBytesLength > 0 || outputBytesLength > 0 {
            return true
        }
        return false
    }
    private enum Stage : Int {
        case OpenConn
        case ReadResponse
        case HandleFrames
        case CloseConn
        case End
    }
    private var stage = Stage.OpenConn
    private var rd : NSInputStream!
    private var wr : NSOutputStream!
    private var closeCode = UInt16(0)
    private var closeReason = ""
    private var closeClean = false
    private var closeFinal = false
    private var finalError : ErrorType?
    private var exit = false
    private func step(){
        if exit {
            return
        }
        do {
            try stepBuffers()
            try stepStreamErrors()
            switch stage {
            case .OpenConn:
                try openConn()
                stage = .ReadResponse
            case .ReadResponse:
                try readResponse()
                privateReadyState = .Open
                fire {
                    self.event.open()
                }
                stage = .HandleFrames
            case .HandleFrames:
                try stepOutputFrames()
                if closeFinal {
                    privateReadyState  == .Closing
                    stage = .CloseConn
                    return
                }
                let frame = try readFrame()
                switch frame.code {
                case .Text:
                    fire {
                        self.event.message(data: frame.utf8.text)
                    }
                case .Binary:
                    fire {
                        switch self.binaryType {
                        case .UInt8Array: self.event.message(data: frame.payload.array)
                        case .NSData: self.event.message(data: frame.payload.nsdata)
                        case .UInt8UnsafeBufferPointer: self.event.message(data: frame.payload.buffer)
                        }
                    }
                case .Ping:
                    let nframe = frame.copy()
                    nframe.code = .Pong
                    lock()
                    frames += [nframe]
                    unlock()
                case .Pong:
                    fire {
                        switch self.binaryType {
                        case .UInt8Array: self.event.pong(data: frame.payload.array)
                        case .NSData: self.event.pong(data: frame.payload.nsdata)
                        case .UInt8UnsafeBufferPointer: self.event.pong(data: frame.payload.buffer)
                        }
                    }
                case .Close:
                    lock()
                    frames += [frame]
                    unlock()
                default:
                    break
                }
            case .CloseConn:
                if let error = finalError {
                    self.event.error(error: error)
                }
                privateReadyState  == .Closed
                if rd != nil {
                    closeConn()
                    fire {
                        self.event.close(code: Int(self.closeCode), reason: self.closeReason, wasClean: self.closeFinal)
                    }
                }
                stage = .End
            case .End:
                fire {
                    self.event.end(code: Int(self.closeCode), reason: self.closeReason, wasClean: self.closeClean, error: self.finalError)
                }
                exit = true
                manager.remove(self)
            }
        } catch WebSocketError.NeedMoreInput {
            
        } catch {
            if finalError != nil {
                return
            }
            finalError = error
            if stage == .OpenConn || stage == .ReadResponse {
                stage = .CloseConn

            } else {
                var frame : Frame?
                if let error = error as? WebSocketError{
                    switch error {
                    case .ProtocolError:
                        frame = Frame.makeClose(1002, reason: "Protocol error")
                    case .PayloadError:
                        frame = Frame.makeClose(1007, reason: "Payload error")
                    default:
                        break
                    }
                }
                if frame == nil {
                    frame = Frame.makeClose(1006, reason: "Abnormal Closure")
                }
                if let frame = frame {
                    if frame.statusCode == 1007 {
                        self.lock()
                        self.frames = [frame]
                        self.unlock()
                        manager.signal()
                    } else {
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0), dispatch_get_main_queue()){
                            self.lock()
                            self.frames += [frame]
                            self.unlock()
                            manager.signal()
                        }
                    }
                }
            }
        }
    }
    private func stepBuffers() throws {
        if rd != nil {
            while rd.hasBytesAvailable {
                var size = inputBytesSize
                while size-(inputBytesStart+inputBytesLength) < windowBufferSize {
                    size *= 2
                }
                if size > inputBytesSize {
                    let ptr = UnsafeMutablePointer<UInt8>(realloc(inputBytes, size))
                    if ptr == nil {
                        throw WebSocketError.Memory
                    }
                    inputBytes = ptr
                    inputBytesSize = size
                }
                let n = rd.read(inputBytes+inputBytesStart+inputBytesLength, maxLength: inputBytesSize-inputBytesStart-inputBytesLength)
                if n > 0 {
                    inputBytesLength += n
                }
            }
        }
        if wr != nil && wr.hasSpaceAvailable && outputBytesLength > 0 {
            let n = wr.write(outputBytes+outputBytesStart, maxLength: outputBytesLength)
            if n > 0 {
                outputBytesLength -= n
                if outputBytesLength == 0 {
                    outputBytesStart = 0
                } else {
                    outputBytesStart += n
                }
            }
        }
    }
    private func stepStreamErrors() throws {
        if finalError == nil {
            if let error = rd?.streamError {
                throw WebSocketError.Network(error.localizedDescription)
            }
            if let error = wr?.streamError {
                throw WebSocketError.Network(error.localizedDescription)
            }
        }
    }
    private func stepOutputFrames() throws {
        lock()
        defer {
            frames = []
            unlock()
        }
        if !closeFinal {
            for frame in frames {
                try writeFrame(frame)
                if frame.code == .Close {
                    closeCode = frame.statusCode
                    closeReason = frame.utf8.text
                    closeFinal = true
                    return
                }
            }
        }
    }
    @inline(__always) private func fire(block: ()->()){
        if let queue = eventQueue {
            dispatch_sync(queue) {
                block()
            }
        } else {
            block()
        }
    }
    
    private var readStateSaved = false
    private var readStateFrame : Frame?
    private var readStateFinished = false
    private var leaderFrame : Frame?
    private func readFrame() throws -> Frame {
        var frame : Frame
        var finished : Bool
        if !readStateSaved {
            if leaderFrame != nil {
                frame = leaderFrame!
                finished = false
                leaderFrame = nil
            } else {
                frame = try readFrameFragment(nil)
                finished = frame.finished
            }
            if frame.code == .Continue{
                throw WebSocketError.ProtocolError("leader frame cannot be a continue frame")
            }
            if !finished {
                readStateSaved = true
                readStateFrame = frame
                readStateFinished = finished
                throw WebSocketError.NeedMoreInput
            }
        } else {
            frame = readStateFrame!
            finished = readStateFinished
            if !finished {
                let cf = try readFrameFragment(frame)
                finished = cf.finished
                if cf.code != .Continue {
                    if !cf.code.isControl {
                        throw WebSocketError.ProtocolError("only ping frames can be interlaced with fragments")
                    }
                    leaderFrame = frame
                    return cf
                }
                if !finished {
                    readStateSaved = true
                    readStateFrame = frame
                    readStateFinished = finished
                    throw WebSocketError.NeedMoreInput
                }
            }
        }
        if !frame.utf8.completed {
            throw WebSocketError.PayloadError("incomplete utf8")
        }
        readStateSaved = false
        readStateFrame = nil
        readStateFinished = false
        return frame
    }

    private func closeConn() {
        rd.removeFromRunLoop(NSRunLoop.mainRunLoop(), forMode: NSDefaultRunLoopMode)
        wr.removeFromRunLoop(NSRunLoop.mainRunLoop(), forMode: NSDefaultRunLoopMode)
        rd.delegate = nil
        wr.delegate = nil
        rd.close()
        wr.close()
    }
    
    private func openConn() throws {
        let req = request.mutableCopy() as! NSMutableURLRequest
        req.setValue("websocket", forHTTPHeaderField: "Upgrade")
        req.setValue("Upgrade", forHTTPHeaderField: "Connection")
        req.setValue("SwiftWebSocket", forHTTPHeaderField: "User-Agent")
        req.setValue("13", forHTTPHeaderField: "Sec-WebSocket-Version")
        if req.URL!.port == nil || req.URL!.port!.integerValue == 80 || req.URL!.port!.integerValue == 443  {
            req.setValue(req.URL!.host!, forHTTPHeaderField: "Host")
        } else {
            req.setValue("\(req.URL!.host!):\(req.URL!.port!.integerValue)", forHTTPHeaderField: "Host")
        }
        req.setValue(req.URL!.absoluteString, forHTTPHeaderField: "Origin")
        if subProtocols.count > 0 {
            req.setValue(";".join(subProtocols), forHTTPHeaderField: "Sec-WebSocket-Protocol")
        }
        if req.URL!.scheme != "wss" && req.URL!.scheme != "ws" {
            throw WebSocketError.InvalidAddress
        }
        if compression.on {
            var val = "permessage-deflate"
            if compression.noContextTakeover {
                val += "; client_no_context_takeover; server_no_context_takeover"
            }
            val += "; client_max_window_bits"
            if compression.maxWindowBits != 0 {
                val += "; server_max_window_bits=\(compression.maxWindowBits)"
            }
            req.setValue(val, forHTTPHeaderField: "Sec-WebSocket-Extensions")
        }
        var security = TCPConnSecurity.None
        let port : Int
        if req.URL!.port != nil {
            port = req.URL!.port!.integerValue
        } else if req.URL!.scheme == "wss" {
            port = 443
            security = .NegoticatedSSL
        } else {
            port = 80
            security = .None
        }
        var path = CFURLCopyPath(req.URL!) as String
        if path == "" {
            path = "/"
        }
        if let q = req.URL!.query {
            if q != "" {
                path += "?" + q
            }
        }
        var reqs = "GET \(path) HTTP/1.1\r\n"
        for key in req.allHTTPHeaderFields!.keys.array {
            if let val = req.valueForHTTPHeaderField(key) {
                reqs += "\(key): \(val)\r\n"
            }
        }
        var keyb = [UInt32](count: 4, repeatedValue: 0)
        for var i = 0; i < 4; i++ {
            keyb[i] = arc4random()
        }
        let rkey = NSData(bytes: keyb, length: 16).base64EncodedStringWithOptions(NSDataBase64EncodingOptions(rawValue: 0))
        reqs += "Sec-WebSocket-Key: \(rkey)\r\n"
        reqs += "\r\n"
        var header = [UInt8]()
        for b in reqs.utf8 {
            header += [b]
        }
        let addr = ["\(req.URL!.host!)", "\(port)"]
        if addr.count != 2 || Int(addr[1]) == nil {
            throw WebSocketError.InvalidAddress
        }
        var (rdo, wro) : (NSInputStream?, NSOutputStream?)
        NSStream.getStreamsToHostWithName(addr[0], port: Int(addr[1])!, inputStream: &rdo, outputStream: &wro)
        (rd, wr) = (rdo!, wro!)
        let securityLevel : String
        switch security {
        case .None:
            securityLevel = NSStreamSocketSecurityLevelNone
        case .NegoticatedSSL:
            securityLevel = NSStreamSocketSecurityLevelNegotiatedSSL
        }
        rd.setProperty(securityLevel, forKey: NSStreamSocketSecurityLevelKey)
        wr.setProperty(securityLevel, forKey: NSStreamSocketSecurityLevelKey)
        if services.contains(.VoIP) {
            rd.setProperty(NSStreamNetworkServiceTypeVoIP, forKey: NSStreamNetworkServiceType)
            wr.setProperty(NSStreamNetworkServiceTypeVoIP, forKey: NSStreamNetworkServiceType)
        }
        if services.contains(.Video) {
            rd.setProperty(NSStreamNetworkServiceTypeVideo, forKey: NSStreamNetworkServiceType)
            wr.setProperty(NSStreamNetworkServiceTypeVideo, forKey: NSStreamNetworkServiceType)
        }
        if services.contains(.Background) {
            rd.setProperty(NSStreamNetworkServiceTypeBackground, forKey: NSStreamNetworkServiceType)
            wr.setProperty(NSStreamNetworkServiceTypeBackground, forKey: NSStreamNetworkServiceType)
        }
        if services.contains(.Voice) {
            rd.setProperty(NSStreamNetworkServiceTypeVoice, forKey: NSStreamNetworkServiceType)
            wr.setProperty(NSStreamNetworkServiceTypeVoice, forKey: NSStreamNetworkServiceType)
        }
        rd.delegate = delegate
        wr.delegate = delegate
        rd.scheduleInRunLoop(NSRunLoop.mainRunLoop(), forMode: NSDefaultRunLoopMode)
        wr.scheduleInRunLoop(NSRunLoop.mainRunLoop(), forMode: NSDefaultRunLoopMode)
        rd.open()
        wr.open()
        try write(header, length: header.count)
    }

    private func write(bytes: UnsafePointer<UInt8>, length: Int) throws {
        if outputBytesStart+outputBytesLength+length > outputBytesSize {
            var size = outputBytesSize
            while outputBytesStart+outputBytesLength+length > size {
                size *= 2
            }
            let ptr = UnsafeMutablePointer<UInt8>(realloc(outputBytes, size))
            if ptr == nil {
                throw WebSocketError.Memory
            }
            outputBytes = ptr
            outputBytesSize = size
        }
        memcpy(outputBytes+outputBytesStart+outputBytesLength, bytes, length)
        outputBytesLength += length
    }
    
    private func readResponse() throws {
        let end : [UInt8] = [ 0x0D, 0x0A, 0x0D, 0x0A ]
        let ptr = UnsafeMutablePointer<UInt8>(memmem(inputBytes+inputBytesStart, inputBytesLength, end, 4))
        if ptr == nil {
            throw WebSocketError.NeedMoreInput
        }
        let buffer = inputBytes+inputBytesStart
        let bufferCount = ptr-(inputBytes+inputBytesStart)
        let string = NSString(bytesNoCopy: buffer, length: bufferCount, encoding: NSUTF8StringEncoding, freeWhenDone: false) as? String
        if string == nil {
            throw WebSocketError.InvalidHeader
        }
        let header = string!
        var needsCompression = false
        var serverMaxWindowBits = 15
        let clientMaxWindowBits = 15
        var key = ""
        let trim : (String)->(String) = { (text) in return text.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())}
        let eqval : (String,String)->(String) = { (line, del) in return trim(line.componentsSeparatedByString(del)[1]) }
        let lines = header.componentsSeparatedByString("\r\n")
        for var i = 0; i < lines.count; i++ {
            let line = trim(lines[i])
            if i == 0  {
                if !line.hasPrefix("HTTP/1.1 101"){
                    throw WebSocketError.InvalidResponse(line)
                }
            } else if line != "" {
                var value = ""
                if line.hasPrefix("\t") || line.hasPrefix(" ") {
                    value = trim(line)
                } else {
                    key = ""
                    if let r = line.rangeOfString(":") {
                        key = trim(line.substringToIndex(r.startIndex))
                        value = trim(line.substringFromIndex(r.endIndex))
                    }
                }
                switch key {
                case "Sec-WebSocket-SubProtocol":
                    privateSubProtocol = value
                case "Sec-WebSocket-Extensions":
                    let parts = value.componentsSeparatedByString(";")
                    for p in parts {
                        let part = trim(p)
                        if part == "permessage-deflate" {
                            needsCompression = true
                        } else if part.hasPrefix("server_max_window_bits="){
                            if let i = Int(eqval(line, "=")) {
                                serverMaxWindowBits = i
                            }
                        }
                    }
                default:
                    break
                }
            }
        }
        if needsCompression {
            if serverMaxWindowBits < 8 || serverMaxWindowBits > 15 {
                throw WebSocketError.InvalidCompressionOptions("server_max_window_bits")
            }
            if serverMaxWindowBits < 8 || serverMaxWindowBits > 15 {
                throw WebSocketError.InvalidCompressionOptions("client_max_window_bits")
            }
            inflater = Inflater(windowBits: serverMaxWindowBits)
            if inflater == nil {
                throw WebSocketError.InvalidCompressionOptions("inflater init")
            }
            deflater = Deflater(windowBits: clientMaxWindowBits, memLevel: 8)
            if deflater == nil {
                throw WebSocketError.InvalidCompressionOptions("deflater init")
            }
        }
        inputBytesLength -= bufferCount+4
        if inputBytesLength == 0 {
            inputBytesStart = 0
        } else {
            inputBytesStart += bufferCount+4
        }
    }

    private class ByteReader {
        var start : UnsafePointer<UInt8>
        var end : UnsafePointer<UInt8>
        var bytes : UnsafePointer<UInt8>
        init(bytes: UnsafePointer<UInt8>, length: Int){
            self.bytes = bytes
            start = bytes
            end = bytes+length
        }
        func readByte() throws -> UInt8 {
            if bytes >= end {
                throw WebSocketError.NeedMoreInput
            }
            let b = bytes.memory
            bytes++
            return b
        }
        var length : Int {
            return end - bytes
        }
        var position : Int {
            get {
                return bytes - start
            }
            set {
                bytes = start + newValue
            }
        }
    }

    private var fragStateSaved = false
    private var fragStatePosition = 0
    private var fragStateInflate = false
    private var fragStateLen = 0
    private var fragStateFin = false
    private var fragStateCode = OpCode.Continue
    private var fragStateLeaderCode = OpCode.Continue
    private var fragStateUTF8 = UTF8()
    private var fragStatePayload = Payload()
    private var fragStateStatusCode = UInt16(0)
    private var fragStateHeaderLen = 0
    private var buffer = [UInt8](count: windowBufferSize, repeatedValue: 0)
    private var reusedPayload = Payload()
    private func readFrameFragment(var leader : Frame?) throws -> Frame {
        var inflate : Bool
        var len : Int
        var fin = false
        var code : OpCode
        var leaderCode : OpCode
        var utf8 : UTF8
        var payload : Payload
        var statusCode : UInt16
        var headerLen : Int
        
        let reader = ByteReader(bytes: inputBytes+inputBytesStart, length: inputBytesLength)
        if fragStateSaved {
            // load state
            reader.position += fragStatePosition
            inflate = fragStateInflate
            len = fragStateLen
            fin = fragStateFin
            code = fragStateCode
            leaderCode = fragStateLeaderCode
            utf8 = fragStateUTF8
            payload = fragStatePayload
            statusCode = fragStateStatusCode
            headerLen = fragStateHeaderLen
            fragStateSaved = false
        } else {
            var b = try reader.readByte()
            fin = b >> 7 & 0x1 == 0x1
            let rsv1 = b >> 6 & 0x1 == 0x1
            let rsv2 = b >> 5 & 0x1 == 0x1
            let rsv3 = b >> 4 & 0x1 == 0x1
            if inflater != nil && (rsv1 || (leader != nil && leader!.inflate)) {
                inflate = true
            } else if rsv1 || rsv2 || rsv3 {
                throw WebSocketError.ProtocolError("invalid extension")
            } else {
                inflate = false
            }
            code = OpCode.Binary
            if let c = OpCode(rawValue: (b & 0xF)){
                code = c
            } else {
                throw WebSocketError.ProtocolError("invalid opcode")
            }
            if !fin && code.isControl {
                throw WebSocketError.ProtocolError("unfinished control frame")
            }
            b = try reader.readByte()
            if b >> 7 & 0x1 == 0x1 {
                throw WebSocketError.ProtocolError("server sent masked frame")
            }
            var len64 = Int64(b & 0x7F)
            var bcount = 0
            if b & 0x7F == 126 {
                bcount = 2
            } else if len64 == 127 {
                bcount = 8
            }
            if bcount != 0 {
                if code.isControl {
                    throw WebSocketError.ProtocolError("invalid payload size for control frame")
                }
                len64 = 0
                for var i = bcount-1; i >= 0; i-- {
                    b = try reader.readByte()
                    len64 += Int64(b) << Int64(i*8)
                }
            }
            len = Int(len64)
            if code == .Continue {
                if code.isControl {
                    throw WebSocketError.ProtocolError("control frame cannot have the 'continue' opcode")
                }
                if leader == nil {
                    throw WebSocketError.ProtocolError("continue frame is missing it's leader")
                }
            }
            if code.isControl {
                if leader != nil {
                    leader = nil
                }
                if inflate {
                    throw WebSocketError.ProtocolError("control frame cannot be compressed")
                }
            }
            statusCode = 0
            if leader != nil {
                leaderCode = leader!.code
                utf8 = leader!.utf8
                payload = leader!.payload
            } else {
                leaderCode = code
                utf8 = UTF8()
                payload = reusedPayload
                payload.count = 0
            }
            if leaderCode == .Close {
                if len == 1 {
                    throw WebSocketError.ProtocolError("invalid payload size for close frame")
                }
                if len >= 2 {
                    let b1 = try reader.readByte()
                    let b2 = try reader.readByte()
                    statusCode = (UInt16(b1) << 8) + UInt16(b2)
                    len -= 2
                    if statusCode < 1000 || statusCode > 4999  || (statusCode >= 1004 && statusCode <= 1006) || (statusCode >= 1012 && statusCode <= 2999) {
                        throw WebSocketError.ProtocolError("invalid status code for close frame")
                    }
                }
            }
            headerLen = reader.position
        }

        let rlen : Int
        let rfin : Bool
        let chopped : Bool
        if reader.length+reader.position-headerLen < len {
            rlen = reader.length
            rfin = false
            chopped = true
        } else {
            rlen = len-reader.position+headerLen
            rfin = fin
            chopped = false
        }
        let bytes : UnsafeMutablePointer<UInt8>
        let bytesLen : Int
        if inflate {
            (bytes, bytesLen) = try inflater!.inflate(reader.bytes, length: rlen, final: rfin)
        } else {
            (bytes, bytesLen) = (UnsafeMutablePointer<UInt8>(reader.bytes), rlen)
        }
        reader.bytes += rlen

        if leaderCode == .Text || leaderCode == .Close {
            try utf8.append(bytes, length: bytesLen)
        } else {
            payload.append(bytes, length: bytesLen)
        }

        if chopped {
            // save state
            fragStateHeaderLen = headerLen
            fragStateStatusCode = statusCode
            fragStatePayload = payload
            fragStateUTF8 = utf8
            fragStateLeaderCode = leaderCode
            fragStateCode = code
            fragStateFin = fin
            fragStateLen = len
            fragStateInflate = inflate
            fragStatePosition = reader.position
            fragStateSaved = true
            throw WebSocketError.NeedMoreInput
        }

        inputBytesLength -= reader.position
        if inputBytesLength == 0 {
            inputBytesStart = 0
        } else {
            inputBytesStart += reader.position
        }

        let f = Frame()
        (f.code, f.payload, f.utf8, f.statusCode, f.inflate, f.finished) = (code, payload, utf8, statusCode, inflate, fin)
        return f
    }

    private var head = [UInt8](count: 0xFF, repeatedValue: 0)
    private func writeFrame(f : Frame) throws {
        if !f.finished{
            throw WebSocketError.LibraryError("cannot send unfinished frames")
        }
        var hlen = 0
        let b : UInt8 = 0x80
        var deflate = false
        if deflater != nil {
            if f.code == .Binary || f.code == .Text {
                deflate = true
                // b |= 0x40
            }
        }
        head[hlen++] = b | f.code.rawValue
        var payloadBytes : [UInt8]
        var payloadLen = 0
        if f.utf8.text != "" {
            payloadBytes = UTF8.bytes(f.utf8.text)
        } else {
            payloadBytes = f.payload.array
        }
        payloadLen += payloadBytes.count
        if deflate {
            
        }
        var usingStatusCode = false
        if f.statusCode != 0 && payloadLen != 0 {
            payloadLen += 2
            usingStatusCode = true
        }
        if payloadLen < 126 {
            head[hlen++] = 0x80 | UInt8(payloadLen)
        } else if payloadLen <= 0xFFFF {
            head[hlen++] = 0x80 | 126
            for var i = 1; i >= 0; i-- {
                head[hlen++] = UInt8((UInt16(payloadLen) >> UInt16(i*8)) & 0xFF)
            }
        } else {
            head[hlen++] = UInt8((0x1 << 7) + 127)
            for var i = 7; i >= 0; i-- {
                head[hlen++] = UInt8((UInt64(payloadLen) >> UInt64(i*8)) & 0xFF)
            }
        }
        let r = arc4random()
        var maskBytes : [UInt8] = [UInt8(r >> 0 & 0xFF), UInt8(r >> 8 & 0xFF), UInt8(r >> 16 & 0xFF), UInt8(r >> 24 & 0xFF)]
        for var i = 0; i < 4; i++ {
            head[hlen++] = maskBytes[i]
        }
        if payloadLen > 0 {
            if usingStatusCode {
                var sc = [UInt8(f.statusCode >> 8 & 0xFF), UInt8(f.statusCode >> 0 & 0xFF)]
                for var i = 0; i < 2; i++ {
                    sc[i] ^= maskBytes[i % 4]
                }
                head[hlen++] = sc[0]
                head[hlen++] = sc[1]
                for var i = 2; i < payloadLen; i++ {
                    payloadBytes[i-2] ^= maskBytes[i % 4]
                }
            } else {
                for var i = 0; i < payloadLen; i++ {
                    payloadBytes[i] ^= maskBytes[i % 4]
                }
            }
        }
        try write(head, length: hlen)
        try write(payloadBytes, length: payloadBytes.count)
    }

    /**
    Closes the WebSocket connection or connection attempt, if any. If the connection is already closed or in the state of closing, this method does nothing.
    
    :param: code An integer indicating the status code explaining why the connection is being closed. If this parameter is not specified, a default value of 1000 (indicating a normal closure) is assumed.
    :param: reason A human-readable string explaining why the connection is closing. This string must be no longer than 123 bytes of UTF-8 text (not characters).
    */
    public func close(code : Int = 1000, reason : String = "Normal Closure") {
        let f = Frame()
        f.code = .Close
        f.statusCode = UInt16(truncatingBitPattern: code)
        f.utf8.text = reason
        sendFrame(f)
    }
    private func sendFrame(f : Frame) {
        lock()
        frames += [f]
        unlock()
        manager.signal()
    }
    /**
    Transmits message to the server over the WebSocket connection.
    
    :param: message The data to be sent to the server.
    */
    public func send(message : Any) {
        let f = Frame()
        if let message = message as? String {
            f.code = .Text
            f.utf8.text = message
        } else if let message = message as? [UInt8] {
            f.code = .Binary
            f.payload.array = message
        } else if let message = message as? UnsafeBufferPointer<UInt8> {
            f.code = .Binary
            f.payload.append(message.baseAddress, length: message.count)
        } else if let message = message as? NSData {
            f.code = .Binary
            f.payload.nsdata = message
        } else {
            f.code = .Text
            f.utf8.text = "\(message)"
        }
        sendFrame(f)
    }
    /**
    Transmits a ping to the server over the WebSocket connection.
    */
    public func ping() {
        let f = Frame()
        f.code = .Ping
        sendFrame(f)
    }
    /**
    Transmits a ping to the server over the WebSocket connection.
    
    :param: optional message The data to be sent to the server.
    */
    public func ping(message : Any){
        let f = Frame()
        f.code = .Ping
        if let message = message as? String {
            f.payload.array = UTF8.bytes(message)
        } else if let message = message as? [UInt8] {
            f.payload.array = message
        } else if let message = message as? UnsafeBufferPointer<UInt8> {
            f.payload.append(message.baseAddress, length: message.count)
        } else if let message = message as? NSData {
            f.payload.nsdata = message
        } else {
            f.utf8.text = "\(message)"
        }
        sendFrame(f)
    }
}
public func ==(lhs: WebSocket, rhs: WebSocket) -> Bool {
    return lhs.id == rhs.id
}


public enum WebSocketError : ErrorType, CustomStringConvertible {
    case Memory
    case NeedMoreInput
    case InvalidHeader
    case InvalidAddress
    case Network(String)
    case LibraryError(String)
    case PayloadError(String)
    case ProtocolError(String)
    case InvalidResponse(String)
    case InvalidCompressionOptions(String)
    public var description : String {
        switch self {
        case .Memory: return "Memory"
        case .NeedMoreInput: return "NeedMoreInput"
        case .InvalidAddress: return "InvalidAddress"
        case .InvalidHeader: return "InvalidHeader"
        case let .InvalidResponse(details): return "InvalidResponse(\(details))"
        case let .InvalidCompressionOptions(details): return "InvalidCompressionOptions(\(details))"
        case let .LibraryError(details): return "LibraryError(\(details))"
        case let .ProtocolError(details): return "ProtocolError(\(details))"
        case let .PayloadError(details): return "PayloadError(\(details))"
        case let .Network(details): return "Network(\(details))"
        }
    }
    public var details : String {
        switch self {
        case .InvalidResponse(let details): return details
        case .InvalidCompressionOptions(let details): return details
        case .LibraryError(let details): return details
        case .ProtocolError(let details): return details
        case .PayloadError(let details): return details
        case .Network(let details): return details
        default: return ""
        }
    }
}

private class Delegate : NSObject, NSStreamDelegate {
    @objc func stream(aStream: NSStream, handleEvent eventCode: NSStreamEvent){
        manager.signal()
    }
}

private enum TCPConnSecurity {
    case None
    case NegoticatedSSL
}

private class Frame {
    var inflate = false
    var code = OpCode.Continue
    var utf8 = UTF8()
    var payload = Payload()
    var statusCode = UInt16(0)
    var finished = true
    static func makeClose(statusCode: UInt16, reason: String) -> Frame {
        let f = Frame()
        f.code = .Close
        f.statusCode = statusCode
        f.utf8.text = reason
        return f
    }
    func copy() -> Frame {
        let f = Frame()
        f.code = code
        f.utf8.text = utf8.text
        f.payload.buffer = payload.buffer
        f.statusCode = statusCode
        f.finished = finished
        f.inflate = inflate
        return f
    }
}

private struct z_stream {
    var next_in : UnsafePointer<UInt8> = nil
    var avail_in : CUnsignedInt = 0
    var total_in : CUnsignedLong = 0
    
    var next_out : UnsafeMutablePointer<UInt8> = nil
    var avail_out : CUnsignedInt = 0
    var total_out : CUnsignedLong = 0
    
    var msg : UnsafePointer<CChar> = nil
    var state : COpaquePointer = nil
    
    var zalloc : COpaquePointer = nil
    var zfree : COpaquePointer = nil
    var opaque : COpaquePointer = nil
    
    var data_type : CInt = 0
    var adler : CUnsignedLong = 0
    var reserved : CUnsignedLong = 0
}

@asmname("zlibVersion") private func zlibVersion() -> COpaquePointer
@asmname("deflateInit2_") private func deflateInit2(strm : UnsafeMutablePointer<Void>, level : CInt, method : CInt, windowBits : CInt, memLevel : CInt, strategy : CInt, version : COpaquePointer, stream_size : CInt) -> CInt
@asmname("deflateInit_") private func deflateInit(strm : UnsafeMutablePointer<Void>, level : CInt, version : COpaquePointer, stream_size : CInt) -> CInt
@asmname("deflateEnd") private func deflateEnd(strm : UnsafeMutablePointer<Void>) -> CInt
@asmname("deflate") private func deflate(strm : UnsafeMutablePointer<Void>, flush : CInt) -> CInt
@asmname("inflateInit2_") private func inflateInit2(strm : UnsafeMutablePointer<Void>, windowBits : CInt, version : COpaquePointer, stream_size : CInt) -> CInt
@asmname("inflateInit_") private func inflateInit(strm : UnsafeMutablePointer<Void>, version : COpaquePointer, stream_size : CInt) -> CInt
@asmname("inflate") private func inflateG(strm : UnsafeMutablePointer<Void>, flush : CInt) -> CInt
@asmname("inflateEnd") private func inflateEndG(strm : UnsafeMutablePointer<Void>) -> CInt

private func zerror(res : CInt) -> ErrorType? {
    var err = ""
    switch res {
    case 0: return nil
    case 1: err = "stream end"
    case 2: err = "need dict"
    case -1: err = "errno"
    case -2: err = "stream error"
    case -3: err = "data error"
    case -4: err = "mem error"
    case -5: err = "buf error"
    case -6: err = "version error"
    default: err = "undefined error"
    }
    return WebSocketError.PayloadError("zlib: \(err): \(res)")
}

private class Inflater {
    var windowBits = 0
    var strm = z_stream()
    var tInput = [[UInt8]]()
    var inflateEnd : [UInt8] = [0x00, 0x00, 0xFF, 0xFF]
    var bufferSize = windowBufferSize
    var buffer = UnsafeMutablePointer<UInt8>(malloc(windowBufferSize))
    init?(windowBits : Int){
        if buffer == nil {
            return nil
        }
        self.windowBits = windowBits
        let ret = inflateInit2(&strm, windowBits: -CInt(windowBits), version: zlibVersion(), stream_size: CInt(sizeof(z_stream)))
        if ret != 0 {
            return nil
        }
    }
    deinit{
        inflateEndG(&strm)
        free(buffer)
    }
    func inflate(bufin : UnsafePointer<UInt8>, length : Int, final : Bool) throws -> (p : UnsafeMutablePointer<UInt8>, n : Int){
        var buf = buffer
        var bufsiz = bufferSize
        var buflen = 0
        for var i = 0; i < 2; i++ {
            if i == 0 {
                strm.avail_in = CUnsignedInt(length)
                strm.next_in = UnsafePointer<UInt8>(bufin)
            } else {
                if !final {
                    break
                }
                strm.avail_in = CUnsignedInt(inflateEnd.count)
                strm.next_in = UnsafePointer<UInt8>(inflateEnd)
            }
            for ;; {
                strm.avail_out = CUnsignedInt(bufsiz)
                strm.next_out = buf
                inflateG(&strm, flush: 0)
                let have = bufsiz - Int(strm.avail_out)
                bufsiz -= have
                buflen += have
                if strm.avail_out != 0{
                    break
                }
                if bufsiz == 0 {
                    bufferSize *= 2
                    let nbuf = UnsafeMutablePointer<UInt8>(realloc(buffer, bufferSize))
                    if nbuf == nil {
                        throw WebSocketError.PayloadError("memory")
                    }
                    buffer = nbuf
                    buf = buffer+Int(buflen)
                    bufsiz = bufferSize - buflen
                }
            }
        }
        return (buffer, buflen)
    }
}

private class Deflater {
    var windowBits = 0
    var memLevel = 0
    var strm = z_stream()
    var bufferSize = windowBufferSize
    var buffer = UnsafeMutablePointer<UInt8>(malloc(windowBufferSize))
    init?(windowBits : Int, memLevel : Int){
        if buffer == nil {
            return nil
        }
        self.windowBits = windowBits
        self.memLevel = memLevel
        let ret = deflateInit2(&strm, level: 6, method: 8, windowBits: -CInt(windowBits), memLevel: CInt(memLevel), strategy: 0, version: zlibVersion(), stream_size: CInt(sizeof(z_stream)))
        if ret != 0 {
            return nil
        }
    }
    deinit{
        deflateEnd(&strm)
        free(buffer)
    }
    func deflate(bufin : UnsafePointer<UInt8>, length : Int, final : Bool) -> (p : UnsafeMutablePointer<UInt8>, n : Int, err : NSError?){
        return (nil, 0, nil)
    }
}

private class UTF8 {
    var text : String = ""
    var count : UInt32 = 0          // number of bytes
    var procd : UInt32 = 0          // number of bytes processed
    var codepoint : UInt32 = 0      // the actual codepoint
    var bcount = 0
    init() { text = "" }
    func append(byte : UInt8) throws {
        if count == 0 {
            if byte <= 0x7F {
                text.append(UnicodeScalar(byte))
                return
            }
            if byte == 0xC0 || byte == 0xC1 {
                throw WebSocketError.PayloadError("invalid codepoint: invalid byte")
            }
            if byte >> 5 & 0x7 == 0x6 {
                count = 2
            } else if byte >> 4 & 0xF == 0xE {
                count = 3
            } else if byte >> 3 & 0x1F == 0x1E {
                count = 4
            } else {
                throw WebSocketError.PayloadError("invalid codepoint: frames")
            }
            procd = 1
            codepoint = (UInt32(byte) & (0xFF >> count)) << ((count-1) * 6)
            return
        }
        if byte >> 6 & 0x3 != 0x2 {
            throw WebSocketError.PayloadError("invalid codepoint: signature")
        }
        codepoint += UInt32(byte & 0x3F) << ((count-procd-1) * 6)
        if codepoint > 0x10FFFF || (codepoint >= 0xD800 && codepoint <= 0xDFFF) {
            throw WebSocketError.PayloadError("invalid codepoint: out of bounds")
        }
        procd++
        if procd == count {
            if codepoint <= 0x7FF && count > 2 {
                throw WebSocketError.PayloadError("invalid codepoint: overlong")
            }
            if codepoint <= 0xFFFF && count > 3 {
                throw WebSocketError.PayloadError("invalid codepoint: overlong")
            }
            procd = 0
            count = 0
            text.append(UnicodeScalar(codepoint))
        }
        return
    }
    func append(bytes : UnsafePointer<UInt8>, length : Int) throws {
        if length == 0 {
            return
        }
        if count == 0 {
            var ascii = true
            for var i = 0; i < length; i++ {
                if bytes[i] > 0x7F {
                    ascii = false
                    break
                }
            }
            if ascii {
                text += NSString(bytes: bytes, length: length, encoding: NSASCIIStringEncoding) as! String
                bcount += length
                return
            }
        }
        for var i = 0; i < length; i++ {
            try append(bytes[i])
        }
        bcount += length
    }
    var completed : Bool {
        return count == 0
    }
    static func bytes(string : String) -> [UInt8]{
        let data = string.dataUsingEncoding(NSUTF8StringEncoding)!
        return [UInt8](UnsafeBufferPointer<UInt8>(start: UnsafePointer<UInt8>(data.bytes), count: data.length))
    }
    static func string(bytes : [UInt8]) -> String{
        if let str = NSString(bytes: bytes, length: bytes.count, encoding: NSUTF8StringEncoding) {
            return str as String
        }
        return ""
    }
}

private class Manager {
    var once = dispatch_once_t()
    var mutex = pthread_mutex_t()
    var cond = pthread_cond_t()
    var websockets = Set<WebSocket>()
    var _nextId = 0
    init(){
        pthread_mutex_init(&mutex, nil)
        pthread_cond_init(&cond, nil)
        dispatch_async(dispatch_queue_create("SwiftWebSocket", nil)) {
            var wss : [WebSocket] = []
            for ;; {
                var wait = true
                wss.removeAll()
                pthread_mutex_lock(&self.mutex)
                for ws in self.websockets {
                    wss.append(ws)
                }
                for ws in wss {
                    if ws.dirty {
                        pthread_mutex_unlock(&self.mutex)
                        ws.step()
                        pthread_mutex_lock(&self.mutex)
                        wait = false
                    }
                }
                if wait {
                    pthread_cond_wait(&self.cond, &self.mutex)
                }
                pthread_mutex_unlock(&self.mutex)
            }
        }
    }
    func signal(){
        pthread_mutex_lock(&mutex)
        pthread_cond_signal(&cond)
        pthread_mutex_unlock(&mutex)
    }
    func add(websocket: WebSocket) {
        pthread_mutex_lock(&mutex)
        websockets.insert(websocket)
        pthread_cond_signal(&cond)
        pthread_mutex_unlock(&mutex)
    }
    func remove(websocket: WebSocket) {
        pthread_mutex_lock(&mutex)
        websockets.remove(websocket)
        pthread_cond_signal(&cond)
        pthread_mutex_unlock(&mutex)
    }
    func nextId() -> Int {
        pthread_mutex_lock(&mutex)
        defer { pthread_mutex_unlock(&mutex) }
        return ++_nextId
    }
}

private let manager = Manager()
