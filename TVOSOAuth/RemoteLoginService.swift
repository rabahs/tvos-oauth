//
//  LoginService.swift
//  cloudphotos
//
//  Created by Rabah Shihab on 2/1/16.
//  Copyright © 2016 Rabah Shihab. All rights reserved.

import Foundation
import Alamofire

public class RemoteLoginService {

    public static let shared = RemoteLoginService()

    public var activationUri: String?
    public var apiKey: String?
    public var apiSecret: String?

    
    public var maxRetry = 50
    public var retryInterval = 10

    
    private var activationCode: String?
    private var timer = Timer()
    private var retryCount: Int = 0
    private var scheduleCompletionBlock: (([String: Any]?, TOError?) -> Void)!


    public func activate(_ completion: @escaping (NSDictionary?, TOError?) -> Void) {
        let params = ["install_id": DeviceUUID.uuid]
        let requestHeaders = [
            "X-TVOAUTH-API-KEY": self.apiKey!,
            "X-TVOAUTH-API-SIG": Utils.signature(params, secret: self.apiSecret!),
        ]
        request("\(activationUri!)/activate_device", method: .get, parameters: params, headers: requestHeaders).validate(statusCode: 200 ..< 300).responseJSON { (response) -> Void in
            switch response.result {
            case .success:
                if let json = response.result.value as? [String: Any],
                    let activationCode = json["activation_code"] as? String,
                    let activationUrl = json["activation_url"] as? String {
                    completion(["activation_code": activationCode, "activation_url": activationUrl], nil)
                } else {

                    completion(nil, TOError.serialization(reason: "Server data error"))
                }
            case let .failure(error):
                completion(nil, TOError.network(error: error))
            }
        }
    }

    
    public func scheduleOAuthCredentialsRetreival(_ activationCode: String, completion: @escaping ([String: Any]?, TOError?) -> Void) {
        self.scheduleCompletionBlock = completion
        self.timer = Timer.scheduledTimer(timeInterval: TimeInterval(self.retryInterval),
                                          target: self,
                                          selector: #selector(RemoteLoginService.retreiveOAuthCredentials(_:)),
                                          userInfo: ["activation_code": activationCode],
                                          repeats: true)
    }

    public func cancelOAuthCredentialsRetreival() {
        self.timer.invalidate()
        self.retryCount = 0
    }

    @objc fileprivate func retreiveOAuthCredentials(_ timer: Timer) {
        self.retryCount += 1
        if retryCount > self.maxRetry {
            self.cancelOAuthCredentialsRetreival()
            self.scheduleCompletionBlock(nil, TOError.timeout(reason: "Too long waiting for activation code"))
            return
        }
        let userInfo = timer.userInfo as! Dictionary<String, AnyObject>

        let params = ["install_id": DeviceUUID.uuid, "activation_code": userInfo["activation_code"] as! String]
        let requestHeaders = [
            "X-TVOAUTH-API-KEY": self.apiKey!,
            "X-TVOAUTH-API-SIG": Utils.signature(params, secret: self.apiSecret!),
        ]

        request("\(activationUri!)/oauth", method: .get, parameters: params, headers: requestHeaders).validate(statusCode: 200 ..< 300).responseJSON { (response) -> Void in
            switch response.result {

            case .success:
                if response.response?.statusCode == 202 {
                    // DLog("New oAuth credentials is not ready yet")
                } else {

                    self.scheduleCompletionBlock(response.result.value as? [String: Any], nil)

                    self.cancelOAuthCredentialsRetreival()
                }
            case let .failure(error):
                self.cancelOAuthCredentialsRetreival()
                self.scheduleCompletionBlock(nil, TOError.network(error: error) )
            }
        }
    }
}