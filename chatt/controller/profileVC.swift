//
//  profileVC.swift
//  chat
//
//  Created by Mohamed Korany Ali on 7/24/19.
//  Copyright © 2019 ashraf. All rights reserved.
//

import UIKit
import Firebase

class profileVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    var user:User?
    let imageCache = NSCache<NSString, AnyObject>()
    
    lazy var profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 100
        imageView.layer.borderColor = UIColor.black.cgColor
        imageView.layer.borderWidth = 2
        imageView.clipsToBounds = true
        if let profileImageUrl = user?.profileImageUrl {
            imageView.loadImageUsingCacheWithUrlString(profileImageUrl)}
        imageView.isUserInteractionEnabled = true
        
        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(showProfilPic)))

        
        
        
        return imageView
    }()
    
    @objc func showProfilPic(){
        performZoomInForStartingImageView(profileImageView)
    }
    
    @objc func handleStatusClick(){
        //1. Create the alert controller.
        let alert = UIAlertController(title: "Bio", message: "Enter Your new Bio .. this will be seen by your friend", preferredStyle: .alert)
        
        //2. Add the text field. You can configure it however you need.
        alert.addTextField { (textField) in
            textField.text = self.status.text
        }
        
        // 3. Grab the value from the text field, and print it when the user clicks OK.
        alert.addAction(UIAlertAction(title: "Done", style: .default, handler: { [weak alert] (_) in
            let textField = alert?.textFields![0] // Force unwrapping because we know it exists.
            self.status.text = textField?.text
            self.user?.status = textField?.text
            guard let uid = Auth.auth().currentUser?.uid else {
                //for some reason uid = nil
                return
            }
            let ref = Database.database().reference().root.child("users").child(uid).updateChildValues(["status": self.status.text])
        }))
        
        // 4. Present the alert.
        self.present(alert, animated: true, completion: nil)
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
        tv.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleStatusClick)))
        return tv
    }()
    
    
    let aboutYou: UITextView = {
        let tv = UITextView()
        tv.text = "About You"
        tv.font = UIFont.boldSystemFont(ofSize: 15)
        
        
        
        tv.translatesAutoresizingMaskIntoConstraints = false
        // tv.backgroundColor = UIColor.black
        tv.textColor = .black
        tv.isEditable = false
        return tv
    }()
    
    lazy var updatePhoto: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("update photo", for: UIControlState.normal)
   
        button.addTarget(self, action: #selector(handleUpdatePhoto), for: .touchUpInside)
        return button
    }()
    
    @objc func handleUpdatePhoto(){
        let picker = UIImagePickerController()
        
        picker.delegate = self
        picker.allowsEditing = true
        
        present(picker, animated: true, completion: nil)
    }
    
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        // Local variable inserted by Swift 4.2 migrator.
        let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)
        
        
        var selectedImageFromPicker: UIImage?
        
        if let editedImage = info["UIImagePickerControllerEditedImage"] as? UIImage {
            selectedImageFromPicker = editedImage
        } else if let originalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            
            selectedImageFromPicker = originalImage
        }
        
        if let selectedImage = selectedImageFromPicker {
            profileImageView.image = selectedImage
            deleteImageFromStorageFirebase()
            uploadNewImageToFirebase()
        }
        
        dismiss(animated: true, completion: nil)
        
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        print("canceled picker")
        dismiss(animated: true, completion: nil)
    }
    
    
    
    func uploadNewImageToFirebase() {
        let uid = Auth.auth().currentUser!.uid
        
        let imageName = NSUUID().uuidString
        let storageRef = Storage.storage().reference().child("profile_images").child("\(imageName).png")
        
        if let uploadData = UIImagePNGRepresentation(self.profileImageView.image!) {
            
            
            storageRef.putData(uploadData, metadata: nil, completion: { (_, err ) in
                if let error = err {
                    print(error)
                    return
                }
                storageRef.downloadURL(completion: { (url, error) in
                    if let err = err {
                        print(err)
                        return
                    }
                    let values = ["profileImageUrl": url?.absoluteString]
                    let ref = Database.database().reference()
                    self.user?.profileImageUrl = url?.absoluteString
                    self.imageCache.setObject(self.profileImageView.image! , forKey: self.user?.profileImageUrl as! NSString)
                    
                    let usersReference = ref.child("users").child(uid)
                    
                    usersReference.updateChildValues(values, withCompletionBlock: { (err, ref) in
                        
                        if let err = err {
                            print(err)
                            return
                        }
                        
                        
                    })
                })
                    
                
                    
               
                
                    })
    }
    }

    
    
    
    func deleteImageFromStorageFirebase()  {
        imageCache.removeObject(forKey: user?.profileImageUrl as! NSString)
        
        let storage = Storage.storage()
        
        let storageRef = storage.reference(forURL: self.user?.profileImageUrl ?? "t")
        storageRef.delete { error in
            if let error = error {
                print(error)
            } else {
                // File deleted successfully
                print("okokokokokok")
            }
    }
        
    }
    
        var updateStatus: UIButton = {
        
        
        
       
        

        let image = UIImage(named: "edit") as UIImage?
        let button = UIButton(type: .custom) as UIButton
        button.frame = CGRect(x:0, y: 0, width: 0.1, height: 0.1)
       
        button.setImage(image, for: UIControlState.normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        //button.setTitle("update status", for: UIControlState.normal)
        button.setImage(image, for: UIControlState.normal)
        
         button.addTarget(self, action: #selector(handleStatusClick), for: .touchUpInside)
        return button
    }()
    
   

    override func viewDidLoad() {
        super.viewDidLoad()
        print(user?.name)
        view.backgroundColor = UIColor.white

        view.addSubview(profileImageView)
        view.addSubview(updatePhoto)
        view.addSubview(username)
        view.addSubview(aboutYou)
        view.addSubview(status)
        view.addSubview(updateStatus)
        setupProfile()
        setupBtn()
        setupTextUserName()
        setupAboutYou()
        setupStatusView()
        setupUpdateStatus()
        
        username.text = user?.name
        status.text = user?.status
        // Do any additional setup after loading the view.
    }
    func setupProfile() {
        //need x, y, width, height constraints
        profileImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        profileImageView.topAnchor.constraint(equalTo: (view.topAnchor), constant: 80).isActive = true

       // profileImageView.centerYAnchor.constraint(equalTo: (equalTo: view.c).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 200).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 200).isActive = true
    }
    
    func setupBtn(){
        updatePhoto.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        updatePhoto.topAnchor.constraint(equalTo: (profileImageView.bottomAnchor), constant: 8).isActive = true
        updatePhoto.widthAnchor.constraint(equalToConstant: 100).isActive = true
        updatePhoto.heightAnchor.constraint(equalToConstant: 30).isActive = true
    }
    
    func setupUpdateStatus()
    {
        updateStatus.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        updateStatus.topAnchor.constraint(equalTo: (aboutYou.bottomAnchor), constant: 2).isActive = true
//        updateStatus.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 8).isActive = true
        //updateStatus.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -8)
        updateStatus.heightAnchor.constraint(equalToConstant: 25).isActive = true
        
        updateStatus.widthAnchor.constraint(equalToConstant: 25).isActive = true
    }
    
    func setupTextUserName(){
        username.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        username.topAnchor.constraint(equalTo: (updatePhoto.bottomAnchor), constant: 8).isActive = true
        
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
        status.topAnchor.constraint(equalTo: (updateStatus.bottomAnchor), constant: 2).isActive = true
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
                
                zoomingImageView.frame = CGRect(x: 0, y: 0, width: keyWindow.frame.width, height: height)
                
                zoomingImageView.center = keyWindow.center
                
            }, completion: { (completed) in
                //                    do nothing
            })
            
        }
    }
    
    @objc func handleZoomOut(_ tapGesture: UITapGestureRecognizer) {
        if let zoomOutImageView = tapGesture.view {
            //need to animate back out to controller
            zoomOutImageView.layer.cornerRadius = 100
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


