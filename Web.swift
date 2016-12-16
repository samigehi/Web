//
//  Web.swift
//  Web
//
//  Created by Sumeet Kumar on 16/12/2016.
//  Copyright © 2016 Sumeet.Kumar. All rights reserved.
//

import Foundation


public protocol complete {
    func success(result: Any?);
    func response(response: URLResponse);
    func fail(error: NSError);
}

public protocol Callback {
    func onComplete(result: Any?, response: URLResponse, error: NSError);
}

fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l < r
    case (nil, _?):
        return true
    default:
        return false
    }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l > r
    default:
        return rhs < lhs
    }
}

/**
 * Singleton class for networking task,
 * design-pattern syntax & architecture is same as in android and windows-phone app
 * created by sumeet.gehi
 */
public class Web{
    
    var web: WebManager!
    var json: Dictionary<String, String>? = [:]
    //var timeout: Int = 30
    var isParam: Bool = false
    var asJason: Bool = false
 
    static var GET = "GET"
    static var POST = "POST"
    internal static var base: String?
    
    static var BASE_URL: String? {
        get {
            if let url = base {
                return url
            }
            else {
                return "";
            }
        }
        set(value) {
            base = value
        }
    }

    
    // create a new web class object with defined method
    open static func create(method: String, serverUrl: String) -> Web {
        let web = Web()
        web.web = WebManager(url: serverUrl, method: method)
        //json = [:]
        return web
    }
    
    // create web task object with pre-defined base url, u need to pass only controller/action name
    open static func with(_ serverUrl: String) -> Web {
        var str: String = serverUrl;
        
        if(str.hasPrefix("/")){
            
            str = serverUrl.substring(from: serverUrl.startIndex)
        }
        return create(method: POST, serverUrl: BASE_URL!.appending(str))
    }
    
    open func add(_ key: String, _ value: String?) -> Web {
        if value != nil {
            self.json!.updateValue(value!, forKey: key)
        }
        return self
    }
    
    open func addParams(_ params: [String: Any]) -> Web {
        self.web.addParams(params)
        //        if Const.DEBUG {
        //            Util.log(params)
        //        }
        return self
    }
    
    open func addSSL(Certifucate data: Data, SSLCallBack: (()->Void)? = nil) -> Web
    {
        self.web.addSSL(Certificate: data, SSLValidateCallBack: SSLCallBack)
        return self
    }
    
    open func addSSL(_ certificateName: String, _ certType: String) -> Web{
        let certFile = Bundle.main.path(forResource: certificateName, ofType: certType)
        let certData = try! Data(contentsOf: URL(fileURLWithPath: certFile!))
        
        self.web.addSSL(Certificate: certData){ () -> Void in
            print("server is not trust worthy")
        }
        return self
    }
    
    open func addSSL() -> Web{
      return addSSL("sgehi", ".cer")
    }
    
    open func addMethod(method: String) -> Web{
        self.web.addMethod(method)
        return self
    }
    
    
    open func onError(_ errorCallback: @escaping ((_ error: NSError) -> Void)) -> Web {
        self.web.addErrorCallback(errorCallback)
        return self
    }
    
    open func request(_ callback: ((_ data: Data?, _ response: HTTPURLResponse?) -> Void)?) {
        if json?.count > 0{
            self.web.addParams(json!)
        }
        
        self.web?.execute(callback)
    }
    
    open func executeString(_ callback: ((_ string: String?, _ response: HTTPURLResponse?) -> Void)?) {
        
        self.request { (data, response) -> Void in
            var string = ""
            if let d = data,
                let s = NSString(data: d, encoding: String.Encoding.utf8.rawValue) as? String {
                string = s
            }
            callback?(string, response)
        }
    }
    
    /**
     async response the http body in JSONObject or JSONArray type use GSON Helper Class
     */
    
    open func execute(_ callback: ((_ json: GSON, _ response: HTTPURLResponse?) -> Void)?) {
        self.request { (string, response) in
            var json = GSON(nil)
            if let s = string {
                json = GSON.with(s)
            }
            json?.debug()
            callback?(json!, response)
        }
    }
    
}

class WebManager: NSObject, URLSessionDelegate {
    

    let DEBUG = true
    
    // var HTTPBodyRaw = ""
    //var HTTPBodyRawIsJSON = false
    
    var method: String!
    var params: [String: Any]?
    
    var errorCallback: ((_ error: NSError) -> Void)?
    var callback: ((_ data: Data?, _ response: HTTPURLResponse?) -> Void)?
    var sslCallBack: (() -> Void)?
    
    var session: URLSession!
    let url: String!
    var request: URLRequest!
    var task: URLSessionTask!
    
    var cert: Data!
    
    var timeout: Double = 40.0
    
    
    init(url: String, method: String) {
        self.url = url
        self.request = URLRequest(url: URL(string: url)!)
        self.method = method
        
        super.init()
        let config = Foundation.URLSession.shared.configuration
        config.timeoutIntervalForRequest = timeout
        config.timeoutIntervalForResource = timeout
        self.session = Foundation.URLSession(configuration: config, delegate: self, delegateQueue: Foundation.URLSession.shared.delegateQueue)
    }
    
    func addSSL(Certificate cert: Data, SSLValidateCallBack: (()->Void)? = nil) {
        self.cert = cert
        self.sslCallBack = SSLValidateCallBack
    }
    
    func addParams(_ params: [String: Any]?) {
        self.params = params
    }
    
    func addMethod(_ m: String) {
        self.method = m
    }
    
    func addErrorCallback(_ errorCallback: ((_ error: NSError) -> Void)?) {
        self.errorCallback = errorCallback
    }
    
    func execute(_ callback: ((_ data: Data?, _ response: HTTPURLResponse?) -> Void)? = nil) {
        self.callback = callback
        
        self.buildRequest()
        self.buildHeader()
        self.buildBody()
        self.execute()
    }
    
    fileprivate func buildRequest() {
        self.request.cachePolicy = NSURLRequest.CachePolicy.reloadIgnoringLocalCacheData
        self.request.httpMethod = self.method
    }
    
    fileprivate func buildHeader() {
        
        if self.params?.count > 0 {
            self.request!.addValue("application/json", forHTTPHeaderField: "Content-Type")
            self.request!.addValue("application/json", forHTTPHeaderField: "Accept")
            //self.request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        }
    }
    
    fileprivate func buildBody() {
        // let data = NSMutableData()
        
        if self.params?.count > 0 {
            let postData = try! JSONSerialization.data(withJSONObject: params!, options: [])
            let jsonString = NSString(data: postData, encoding: String.Encoding.utf8.rawValue) as! String
            self.request!.httpBody = jsonString.data(using: String.Encoding.utf8)!
            self.request!.setValue(String(jsonString.characters.count), forHTTPHeaderField: "Content-Length")
            //Util.LOG("post parameters == "+jsonString)
            
            if DEBUG {
                print("===Post Parameters===",jsonString)
            }
            // data.append(Helper.buildParams(self.params!).data(using: String.Encoding.utf8)!)
        }
        
        
        // self.request.httpBody = data as Data
    }
    
    fileprivate func execute() {
        if DEBUG
        {
            if let a = self.request.allHTTPHeaderFields
            {
                print("Web Request HEADERS: ", a.description)
            }
        }
        self.task = self.session.dataTask(with: self.request) { [weak self] (data, response, error) -> Void in
            if (self?.DEBUG)! { if let a = response { print("Web Response: ", a.description); }}
            if let error = error as? NSError {

                let e = NSError(domain: "WebManager-Error", code: error.code, userInfo: error.userInfo)
                print("Web Error: ", e.localizedDescription)
                
                DispatchQueue.main.async {
                    self?.errorCallback?(e)
                    self?.session.finishTasksAndInvalidate()
                }
                
            } else {
                DispatchQueue.main.async {
                    if (self?.DEBUG)!
                    {
                       print("Web Response: \(data)")
                    }
                    
                    self?.callback?(data, response as? HTTPURLResponse)
                    self?.session.finishTasksAndInvalidate()
                }
            }
        }
        self.task.resume()
    }
}

extension WebManager {
    /**
     a delegate method to check whether the remote cartification is the same with given certification.
     */
    @objc(URLSession:didReceiveChallenge:completionHandler:) func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        if let localCertificateData = self.cert {
            if let trust = challenge.protectionSpace.serverTrust,
                let certificate = SecTrustGetCertificateAtIndex(trust, 0) {
                let remoteCertificateData: Data = SecCertificateCopyData(certificate) as Data
                if localCertificateData as Data == remoteCertificateData {
                    let credential = URLCredential(trust: trust)
                    challenge.sender?.use(credential, for: challenge)
                    completionHandler(Foundation.URLSession.AuthChallengeDisposition.useCredential, credential)
                } else {
                    challenge.sender?.cancel(challenge)
                    completionHandler(Foundation.URLSession.AuthChallengeDisposition.cancelAuthenticationChallenge, nil)
                    self.sslCallBack?()
                    //self.errorCallback?()
                }
            } else {
                // invalid certificate
            }
        } else {
            completionHandler(Foundation.URLSession.AuthChallengeDisposition.useCredential, nil)
        }
    }
    
}

extension NSURLRequest {
    static func allowsAnyHTTPSCertificateForHost(host: String) -> Bool {
        return true
    }
}

