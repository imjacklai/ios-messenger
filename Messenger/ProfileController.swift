//
//  ProfileController.swift
//  Messenger
//
//  Created by Jack Lai on 29/07/2017.
//  Copyright © 2017 Jack Lai. All rights reserved.
//

import UIKit
import Firebase
import SVProgressHUD

protocol ProfileControllerDelegate: class {
    func performSignOut()
}

class ProfileController: UIViewController {
    
    fileprivate let profileImageView = UIImageView()
    fileprivate let emailLabel = UILabel()
    fileprivate let indicator = UIActivityIndicatorView()
    
    weak var delegate: ProfileControllerDelegate?
    
    var user: User? {
        didSet { setupProfile() }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        profileImageView.contentMode = .scaleAspectFill
        profileImageView.layer.cornerRadius = 75
        profileImageView.layer.masksToBounds = true
        profileImageView.isUserInteractionEnabled = true
        profileImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(chooseImageSource)))
        
        indicator.color = .gray
        indicator.hidesWhenStopped = true
        
        view.backgroundColor = .white
        view.addSubview(profileImageView)
        view.addSubview(emailLabel)
        view.addSubview(indicator)
        
        profileImageView.snp.makeConstraints { (make) in
            make.width.height.equalTo(150)
            make.center.equalTo(view)
        }
        
        emailLabel.snp.makeConstraints { (make) in
            make.top.equalTo(profileImageView.snp.bottom).offset(30)
            make.centerX.equalTo(view)
        }
        
        indicator.snp.makeConstraints { (make) in
            make.center.equalTo(profileImageView)
        }
    }
    
    fileprivate func setupProfile() {
        guard let user = user else { return }
        navigationItem.title = user.name
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "登出", style: .plain, target: self, action: #selector(confirmSignOut))
        profileImageView.kf.indicatorType = .activity
        profileImageView.kf.setImage(with: user.profileImageUrl, placeholder: #imageLiteral(resourceName: "profile"))
        emailLabel.text = user.email
    }
    
    fileprivate func presentImagePicker(sourceType: UIImagePickerControllerSourceType) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        imagePicker.sourceType = sourceType
        present(imagePicker, animated: true, completion: nil)
    }
    
    fileprivate func uploadProfileImage(image: UIImage) {
        indicator.startAnimating()
        let mask = UIView(frame: profileImageView.bounds)
        mask.backgroundColor = UIColor.white.withAlphaComponent(0.5)
        profileImageView.mask = mask
        
        let imageName = UUID().uuidString
        guard let uploadData = UIImageJPEGRepresentation(image, 0.1) else {
            SVProgressHUD.showError(withStatus: "照片上傳失敗")
            return
        }
        
        Storage.storage().reference().child("profile_images").child("\(imageName).jpg").putData(uploadData, metadata: nil) { (metadata, error) in
            if let error = error {
                SVProgressHUD.showError(withStatus: "照片上傳失敗")
                print("Failed to upload image to storage: ", error)
                return
            }
            
            guard let profileImageUrl = metadata?.downloadURL()?.absoluteString,
                let uid = Auth.auth().currentUser?.uid else { return }
            
            let value = ["profileImageUrl": profileImageUrl]
            
            Database.database().reference().child("users").child(uid).updateChildValues(value, withCompletionBlock: { (error, ref) in
                if let error = error {
                    print("Failed to write image url to database: ", error)
                    return
                }
                
                self.profileImageView.image = image
                self.profileImageView.mask = nil
                self.indicator.stopAnimating()
                SVProgressHUD.showSuccess(withStatus: "上傳成功")
            })
        }
    }
    
    @objc fileprivate func chooseImageSource() {
        let alertController = UIAlertController(title: "選擇照片來源", message: nil, preferredStyle: .actionSheet)
        let cameraAction = UIAlertAction(title: "相機", style: .default) { (action) in
            self.presentImagePicker(sourceType: .camera)
        }
        let albumAction = UIAlertAction(title: "相簿", style: .default) { (action) in
            self.presentImagePicker(sourceType: .photoLibrary)
        }
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        alertController.addAction(cameraAction)
        alertController.addAction(albumAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }
    
    @objc fileprivate func confirmSignOut() {
        let alertController = UIAlertController(title: "確定要登出？", message: "", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        let confirmAction = UIAlertAction(title: "登出", style: .default) { (action) in
            self.delegate?.performSignOut()
        }
        alertController.addAction(cancelAction)
        alertController.addAction(confirmAction)
        present(alertController, animated: true, completion: nil)
    }
    
}

extension ProfileController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        var selectedImage: UIImage?
        
        if let editedImage = info["UIImagePickerControllerEditedImage"] as? UIImage {
            selectedImage = editedImage
        } else if let originalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            selectedImage = originalImage
        }
        
        if let selectedImage = selectedImage {
            uploadProfileImage(image: selectedImage)
        }
        
        dismiss(animated: true, completion: nil)
    }
    
}
