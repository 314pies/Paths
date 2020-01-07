//
//  ViewController.swift
//  CustomLoginDemo
//
//  Created by Christopher Ching on 2019-07-22.
//  Copyright © 2019 Christopher Ching. All rights reserved.
//

import UIKit
import AVKit
import GoogleSignIn
import FirebaseAuth
import FBSDKLoginKit

class ViewController: UIViewController,GIDSignInDelegate,LoginButtonDelegate {
    
    //Facebook Login
    func loginButtonDidLogOut(_ loginButton: FBLoginButton) {
        print("Facebook Logout")
    }
    
    
    //Facebook Login
    func loginButton(_ loginButton: FBLoginButton, didCompleteWith result: LoginManagerLoginResult?, error: Error?) {
        if let error = error {
          print("Facebook login failed: ", error.localizedDescription)
          return
        }
        print("Facebook login success")
        
        let credential = FacebookAuthProvider.credential(withAccessToken: AccessToken.current!.tokenString)
        Auth.auth().signInAndRetrieveData(with: credential) { (authResult, error) in
            if let error = error {
               print("Failed to creare a Facebook user with Facebook account.", error)
               return
             }
            
            print("Successfully login to Firebase with Facebook!")
            self.enterHime()
       }
    }
    
    //Google login
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
       
        if let error = error {
          print("Failed to login to Google: ", error)
          return
        }
        print("Successfully login to Google!")
        
        guard let authentication = user.authentication else { return }
        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken,
                                                          accessToken: authentication.accessToken)
        
        Auth.auth().signInAndRetrieveData(with: credential) { (authResult, error) in
          if let error = error {
            print("Failed to creare a Firebase user with Google account.", error)
            return
          }
            guard let uid = user?.userID else {return}
            print("Successfully login to Firebase with Google! userID: ", uid)
          // User is signed in
            self.enterHime()
        }
    }
    
    func enterHime() {
        let homeViewController = self.storyboard?.instantiateViewController(identifier: Constants.Storyboard.homeViewController) as? HomeViewController
                       
                       self.view.window?.rootViewController = homeViewController
                       self.view.window?.makeKeyAndVisible()
    }

    var videoPlayer:AVPlayer?
    
    var videoPlayerLayer:AVPlayerLayer?
    
    @IBOutlet weak var signUpButton: UIButton!
    
    @IBOutlet weak var loginButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        setUpElements()
        
        
        //Google sign-in
        let googleButton = GIDSignInButton()
        googleButton.frame = CGRect(x:16, y :320 + 66, width: view.frame.width - 32, height: 50)
        
        view.addSubview(googleButton)
       
        GIDSignIn.sharedInstance()?.presentingViewController = self
        GIDSignIn.sharedInstance()?.delegate = self
        
        //Facebook sign-in
        let FacebookButton = FBLoginButton()
        
        FacebookButton.frame = CGRect(x:16, y :320 + 66 + 66, width: view.frame.width - 32, height: 50)
        let buttonText = NSAttributedString(string: "      Sign in")
        FacebookButton.setAttributedTitle(buttonText, for: .normal)
        FacebookButton.contentHorizontalAlignment = .center
        
        view.addSubview(FacebookButton)
        FacebookButton.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        // Set up video in the background
        setUpVideo()
    }
    
    func setUpElements() {
        
        Utilities.styleFilledButton(signUpButton)
        Utilities.styleHollowButton(loginButton)
        
    }
    
    func setUpVideo() {
        
        // Get the path to the resource in the bundle
        let bundlePath = Bundle.main.path(forResource: "loginbg", ofType: "mp4")
        
        guard bundlePath != nil else {
            return
        }
        
        // Create a URL from it
        let url = URL(fileURLWithPath: bundlePath!)
        
        // Create the video player item
        let item = AVPlayerItem(url: url)
        
        // Create the player
        videoPlayer = AVPlayer(playerItem: item)
        
        // Create the layer
        videoPlayerLayer = AVPlayerLayer(player: videoPlayer!)
        
        // Adjust the size and frame
        videoPlayerLayer?.frame = CGRect(x: -self.view.frame.size.width*1.5, y: 0, width: self.view.frame.size.width*4, height: self.view.frame.size.height)
        
        view.layer.insertSublayer(videoPlayerLayer!, at: 0)
        
        // Add it to the view and play it
        videoPlayer?.playImmediately(atRate: 0.3)
    }


}

