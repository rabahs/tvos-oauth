//
//  ViewController.swift
//  Example
//
//  Created by Rabah Shihab on 3/20/17.
//  Copyright © 2017 BitHunch LLC. All rights reserved.
//

import UIKit
import TVOSOAuth
import ReachabilitySwift

class LoginViewController: UIViewController {

    @IBOutlet weak var activationLinkLabel: UILabel!
    @IBOutlet weak var activationCodeLabel: UILabel!
    
    @IBOutlet weak var activationLink: UILabel!
    @IBOutlet weak var activationCode: UILabel!
    
    var credentials: [String:Any]?

    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(LoginViewController.tapped))
        tapRecognizer.allowedPressTypes = [NSNumber(value: UIPressType.menu.rawValue as Int)]
        self.view.addGestureRecognizer(tapRecognizer)
        
        // The url for your deployed tvos-oauth service https://github.com/rabahs/tvos-oauth-server
        RemoteLoginService.shared.activationUri = "https://auth.indiekit.com"
        
        // API key and secret
        RemoteLoginService.shared.apiKey = ""
        RemoteLoginService.shared.apiSecret = ""
  
        // Optional params
//        RemoteLoginService.shared.maxRetry = 50  // how many times to retry to fetch credentials (default to 50)
//        RemoteLoginService.shared.retryInterval = 10 // how long to wait between each retry (default 10 seconds)

    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        authorize()
    }
    
    func tapped() {
        RemoteLoginService.shared.cancelOAuthCredentialsRetreival()
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        RemoteLoginService.shared.cancelOAuthCredentialsRetreival()
    }
    
    func authorize() {
        RemoteLoginService.shared.authorize(provider: "amazon", authParams: ["scope": "profile"], { (results, error) -> Void in
        
//        RemoteLoginService.shared.authorize(provider: "dropbox", authParams: ["require_role": "personal"], { (results, error) -> Void in
            if error == nil {
                self.activationLinkLabel.text = results!["activation_url"] as? String
                
                self.activationCodeLabel.text = results!["activation_code"] as? String
                
                RemoteLoginService.shared.scheduleOAuthCredentialsRetreival(self.activationCodeLabel.text!, completion: { (credentials, error) -> Void in
                    if error == nil {
                        self.credentials = credentials
                        print("successfully authenticated \(credentials!)")
                        self.refreshToken()
                        
                        self.dismiss(animated: true, completion: nil)
                    } else {
                        print("could not authorize \(error!.message)")
                    }
                })
            } else {
                print("could not authenticate \(error!.message)")
                self.retryActivate("check your internet and try again?")
            }
        })
    }
    
    func retryActivate(_ message: String) {
        let alertController = UIAlertController(title: "Something went wrong", message: message, preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: "Retry", style: .default, handler: { (_: UIAlertAction!) in
            if Reachability()!.currentReachabilityStatus != .notReachable {
                self.authorize()
            }
        })
        alertController.addAction(defaultAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func refreshToken() {
        guard let refreshToken = credentials!["refresh_token"] as? String else { return }
        RemoteLoginService.shared.refreshAccessToken(provider: "amazon", refreshToken: refreshToken) { (credentials, error) in
            if error == nil {
                print("refreshed token \(credentials!)")
            } else {
                print(error!.message)
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}

