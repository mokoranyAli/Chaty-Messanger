//
//  profilePartenerVC.swift
//  chat
//
//  Created by Mohamed Korany Ali on 7/25/19.
//  Copyright © 2019 ashraf. All rights reserved.
//

import UIKit

class profilePartenerVC: UIViewController {

    var user:User?
    let imageCache = NSCache<NSString, AnyObject>()
    
    lazy var profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        
        imageView.layer.borderColor = UIColor.black.cgColor
        imageView.layer.borderWidth = 2
        
        if let profileImageUrl = user?.profileImageUrl {
            imageView.loadImageUsingCacheWithUrlString(profileImageUrl)}
        imageView.isUserInteractionEnabled = true
        
        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(showProfilPic)))
        
        
        
        
        return imageView
    }()
    
    @objc func showProfilPic(){
        performZoomInForStartingImageView(profileImageView)
    }
  
    
    let username: UITextView = {
        let tv = UITextView()
        //tv.text = "Mohamed Korany Ali"
        tv.font = UIFont.boldSystemFont(ofSize: 21)
        tv.textAlignment = .center
        
        
        tv.translatesAutoresizingMaskIntoConstraints = false
        // tv.backgroundColor = UIColor.black
        tv.textColor = .black
        tv.isEditable = false
        return tv
    }()
    
    let status: UITextView = {
        let tv = UITextView()
        // tv.text = "hey icoifcjw;ifjwm;refmwefokjwe[pew[fpwepofkwefkew[okfw[eoifjweo[fiweo[ifnjeofjew"
        tv.font = UIFont.systemFont(ofSize: 20)
        //tv.textAlignment = .center
        
        
        tv.translatesAutoresizingMaskIntoConstraints = false
        // tv.backgroundColor = UIColor.black
        tv.textColor = .black
        tv.isEditable = false
        tv.isUserInteractionEnabled = true
        
        return tv
    }()
    
    
    let aboutYou: UITextView = {
        let tv = UITextView()
//        tv.text = "About You"
        tv.font = UIFont.boldSystemFont(ofSize: 15)
        
        
        
        tv.translatesAutoresizingMaskIntoConstraints = false
        // tv.backgroundColor = UIColor.black
        tv.textColor = .black
        tv.isEditable = false
        return tv
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(user?.name)
        view.backgroundColor = UIColor.white
        
        view.addSubview(profileImageView)
        view.addSubview(username)
        view.addSubview(aboutYou)
        view.addSubview(status)
        setupProfile()
        setupTextUserName()
        setupAboutYou()
        setupStatusView()
        
        username.text = user?.name
        status.text = user?.status
        
        let aboutFirstName = user?.name.map { String($0) }
        aboutYou.text = "About " + aboutFirstName! + "'s Status"
        
        // Do any additional setup after loading the view.
    }
    func setupProfile() {
        //need x, y, width, height constraints
        profileImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        profileImageView.topAnchor.constraint(equalTo: (view.topAnchor), constant: 100).isActive = true
        profileImageView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 2).isActive = true
        profileImageView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -2).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 300).isActive = true
        
    }
    
  
    
    
    
    func setupTextUserName(){
        username.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        username.topAnchor.constraint(equalTo: (profileImageView.bottomAnchor), constant: 8).isActive = true
        
        // profileImageView.centerYAnchor.constraint(equalTo: (equalTo: view.c).isActive = true
        //username.widthAnchor.constraint(equalToConstant: 300).isActive = true
        username.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 8).isActive = true
        username.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -8).isActive = true
        username.heightAnchor.constraint(equalToConstant: 50).isActive = true
    }
    
    func setupAboutYou(){
        
        aboutYou.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        aboutYou.topAnchor.constraint(equalTo: (username.bottomAnchor), constant: 8).isActive = true
        aboutYou.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 8).isActive = true
        aboutYou.widthAnchor.constraint(equalToConstant: 50).isActive = true
        aboutYou.heightAnchor.constraint(equalToConstant: 40).isActive = true
    }
    
    func setupStatusView(){
        
        status.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        status.topAnchor.constraint(equalTo: (aboutYou.bottomAnchor), constant: 2).isActive = true
        status.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 8).isActive = true
        status.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -8)
        status.heightAnchor.constraint(equalToConstant: 250).isActive = true
    }
    
    var startingFrame: CGRect?
    var blackBackgroundView: UIView?
    var startingImageView: UIImageView?
    
    //my custom zooming logic
    func performZoomInForStartingImageView(_ startingImageView: UIImageView) {
        
        self.startingImageView = startingImageView
        self.startingImageView?.isHidden = true
        
        startingFrame = startingImageView.superview?.convert(startingImageView.frame, to: nil)
        
        let zoomingImageView = UIImageView(frame: startingFrame!)
        zoomingImageView.backgroundColor = UIColor.red
        zoomingImageView.image = startingImageView.image
        zoomingImageView.isUserInteractionEnabled = true
        zoomingImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleZoomOut)))
        
        if let keyWindow = UIApplication.shared.keyWindow {
            blackBackgroundView = UIView(frame: keyWindow.frame)
            blackBackgroundView?.backgroundColor = UIColor.black
            blackBackgroundView?.alpha = 0
            keyWindow.addSubview(blackBackgroundView!)
            
            keyWindow.addSubview(zoomingImageView)
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                
                self.blackBackgroundView?.alpha = 1
                self.view.alpha = 0
                
                // math?
                // h2 / w1 = h1 / w1
                // h2 = h1 / w1 * w1
                let height = self.startingFrame!.height / self.startingFrame!.width * keyWindow.frame.width
                
                zoomingImageView.frame = CGRect(x: 0, y: 0, width: keyWindow.frame.width, height: height+50)
                
                zoomingImageView.center = keyWindow.center
                
            }, completion: { (completed) in
                //                    do nothing
            })
            
        }
    }
    
    @objc func handleZoomOut(_ tapGesture: UITapGestureRecognizer) {
        if let zoomOutImageView = tapGesture.view {
            //need to animate back out to controller
//            zoomOutImageView.layer.cornerRadius = 100
                zoomOutImageView.clipsToBounds = true
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                
                zoomOutImageView.frame = self.startingFrame!
                self.blackBackgroundView?.alpha = 0
                self.view.alpha = 1
                
            }, completion: { (completed) in
                zoomOutImageView.removeFromSuperview()
                self.startingImageView?.isHidden = false
            })
        }
    }
}

fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [String: Any]) -> [String: Any] {
    return Dictionary(uniqueKeysWithValues: input.map {result in (result.key, result.value)})
}
