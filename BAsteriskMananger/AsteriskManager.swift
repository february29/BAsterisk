//
//  AsteriskManager.swift
//  linphone_Fch
//
//  Created by bai on 2018/7/16.
//

import UIKit
import CocoaAsyncSocket
import HandyJSON


protocol AsteriskManagerDelegate {
    
    func asteriskSocketDidConnect(_ asterisk: AsteriskManager, toHost host: String, port: UInt16);

    func asteriskSocketDidDisconnect(_ asterisk: AsteriskManager, withError err: Error?)
    
    func asterisk(_ asterisk: AsteriskManager, didRecivedEvent event: AsteriskEvent?)->Void
    
    
    func asterisk(_ asterisk: AsteriskManager, didRecivedResponse response: AsteriskResponse?)->Void
    
    func asterisk(_ asterisk: AsteriskManager, didRecivedMessage message: AsteriskMessage?)->Void
    
    
    func asterisk(_ asterisk: AsteriskManager, didRecivedUnknown  data:Data)->Void
}



class AsteriskManager: NSObject,GCDAsyncSocketDelegate {
    
//    static let instance = AsteriskManager();
    
    
    
    var clientSocket:GCDAsyncSocket?
    
    
    
    var dataAnalyser:AsterDataAnalyser?
    
    
    public var delegate:AsteriskManagerDelegate?
    
    
    
    //重连机制,连接成功后启动，调用self.socketDisConnect断开链接后关闭。
    
    private var timer : Timer?

    /// 检查时间间隔，每隔reConnectTimeInterval秒检查一次
    public var reConnectTimeInterval:TimeInterval  = 5;
    /// 重连次数， 调用socketConnect()后 重制该次数
    private var reConnectCount  = 0;
    
    /// 最大重连次数，超过该次数后不再重连
    public var maxReconnectCount = 15;
    
   
    
   
    private var host:String?;
    private var port:Int?
   
    override init() {
        super.init();
        
        clientSocket = GCDAsyncSocket(delegate: self, delegateQueue: DispatchQueue.main)
        dataAnalyser = AsterDataAnalyser();
        timer = Timer.scheduledTimer(timeInterval: reConnectTimeInterval, target: self, selector: #selector(checkConnectStatue), userInfo: nil, repeats: true);
        timer?.fireDate = Date.distantFuture;
    };
    
    
    
    
    
    
    //MARK: FUN
    
    func socketConnect(toHost: String, onPort: Int)  {
        
//        try? clientSocket?.connect(toHost: "223.100.11.88", onPort: 6038, viaInterface: nil, withTimeout: 20)
        self.host = toHost;
        self.port = onPort;
    
//        reConnectCount = 0;
        
        try? clientSocket?.connect(toHost: toHost, onPort: UInt16(onPort), viaInterface: nil, withTimeout: 20)
       
       
        
    }
    
    func socketReConnect() {
        
        
        if ((clientSocket?.isConnected)!){
            return;
        }
    
        
        if self.host != nil && self.port != nil{
            self.socketConnect(toHost: self.host!, onPort: self.port!);
        }else{
            print("self.host == nil or self.port == nil");
        }
    }
    
   
    private func autoSocketReConnect()  {
        if reConnectCount > self.maxReconnectCount {
            return;
        }
//        self.reConnectCount++
        reConnectCount +=  1;
        print("reConnectCount \(reConnectCount)")
        self.socketReConnect();
    }
    
    func socketDisConnect(){
        clientSocket?.disconnect();
        timer?.fireDate = Date.distantFuture;
    }
    
    func login(userName:String,password:String) {
        
        if !(clientSocket?.isConnected)! {
            self.socketReConnect();
        }
        
        
        self.sendPacket(type: .action, typeValue: "Login", valeus: ["Username":userName,"Secret":password])
//        "aciont:Login\r\nSecret:psw.fchmanager\r\nUsername:fchmanager001\r\n\r\n"
    }
    
    func sendPacket( type:AsteriskPacketType ,typeValue:String,valeus:Dictionary<String, String>)  {
        var str = "\(type.packetTypeStr()):\(typeValue)\r\n";
    
        for key in valeus.keys {
            str.append("\(key):");
            str.append("\(valeus[key] ?? "")\r\n");
        }
        str.append("\r\n");
        let data = str.data(using: .utf8);
        self.sendData(data: data!);
    }
    
    
   
    func sendData(data:Data) {

        self.clientSocket?.write(data, withTimeout: -1, tag: 0);
    }
    
    @objc func checkConnectStatue()  {
        
        print("checkConnectStatue")
        if self.clientSocket!.isConnected{
            return;
        }
        
        self.autoSocketReConnect();
        self.timer?.fireDate = Date.distantFuture;
        
    }
    
    //MARK: GCDAsyncSocketDelegate
    
    
    func socket(_ sock: GCDAsyncSocket, didConnectToHost host: String, port: UInt16) {
        self.clientSocket?.readData(withTimeout: -1, tag: 0)
        reConnectCount = 0;
        timer?.fireDate = Date.distantFuture;
        if let del = self.delegate {
            del.asteriskSocketDidConnect(self, toHost: host, port: port);
        }
    }
    
    func socket(_ sock: GCDAsyncSocket, didRead data: Data, withTag tag: Int) {
        
        
//        let tempStr = String(data: data, encoding: .utf8);
//        print(tempStr);
        let type = dataAnalyser!.asteriskPacketType(data: data)
        
        switch type {
        case .event:
            
            if let del = self.delegate {
                let event = dataAnalyser?.asteriskEvent(data: data);
                del.asterisk(self, didRecivedEvent: event);
            }
            break
        case .response:
            
            if let del = self.delegate {
                let response = dataAnalyser?.asteriskResponse(data: data);
                del.asterisk(self, didRecivedResponse: response)
            }
            break
        case .message:
           
            if let del = self.delegate {
                let message = dataAnalyser?.asteriskMessage(data: data)
                del.asterisk(self, didRecivedMessage:message);
            }
            break
        case .action:
            //正常情况下不会收到aciton
//             let response =   dataAnalyser?.asteriskEvent(data: data);
            if let del = self.delegate {
                del.asterisk(self, didRecivedUnknown: data);
            }
            break
        default:
            if let del = self.delegate {
                del.asterisk(self, didRecivedUnknown: data);
            }
            break;
        }
        
        
//        if  dataAnalyser?.asteriskPacketType(data: data) == .event {
//
//        }else if dataAnalyser?.asteriskPacketType(data: data) == .event {
//
//        } else if  dataAnalyser?.asteriskPacketType(data: data) == .event {
//
//        }
//
       
        
        //继续读取数据
        self.clientSocket?.readData(withTimeout: -1, tag: 0)
        
    }
    
    func socket(_ sock: GCDAsyncSocket, didWriteDataWithTag tag: Int) {
        print("didWriteDataWithTag)")
        self.clientSocket?.readData(withTimeout: -1, tag: 0)
    }
    
    func socketDidDisconnect(_ sock: GCDAsyncSocket, withError err: Error?) {
        print("socketDidDisconnect)")
        
        if err != nil {
            print("-------err\(String(describing: err))");
            timer?.fireDate = Date().addingTimeInterval(reConnectTimeInterval);
//            self.autoSocketReConnect();
        }
        if let del = self.delegate {
            del.asteriskSocketDidDisconnect(self, withError: err);
        }
    }

    
}
