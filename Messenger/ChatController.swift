//
//  ChatController.swift
//  Messenger
//
//  Created by Jack Lai on 31/07/2017.
//  Copyright © 2017 Jack Lai. All rights reserved.
//

import UIKit
import Firebase
import SVProgressHUD

class ChatController: UICollectionViewController {
    
    var user: User? {
        didSet {
            navigationItem.title = user?.name
            fetchMessages()
        }
    }
    
    var messages = [Message]()
    
    fileprivate let messageInputView = MessageInputView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
    
    override var inputAccessoryView: UIView? {
        return messageInputView
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: Notification.Name.UIKeyboardWillShow, object: nil)
        
        collectionView?.backgroundColor = .white
        collectionView?.contentInset = UIEdgeInsetsMake(10, 0, 10, 0)
        collectionView?.alwaysBounceVertical = true
        collectionView?.keyboardDismissMode = .interactive
        collectionView?.register(MessageCell.self, forCellWithReuseIdentifier: "MessageCell")
        
        messageInputView.delegate = self
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        collectionView?.collectionViewLayout.invalidateLayout()
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MessageCell", for: indexPath) as! MessageCell
        guard let partner = user else { return cell }
        cell.setupMessage(partner: partner, message: messages[indexPath.row])
        return cell
    }
    
    fileprivate func fetchMessages() {
        guard let fromId = Auth.auth().currentUser?.uid, let toId = user?.uid else { return }
        
        Database.database().reference().child("user-message").child(fromId).child(toId).observe(.childAdded, with: { (snapshot) in
            let messageId = snapshot.key
            Database.database().reference().child("messages").child(messageId).observeSingleEvent(of: .value, with: { (snapshot) in
                guard let dictionary = snapshot.value as? [String: Any] else { return }
                self.messages.append(Message(dictionary: dictionary))
                DispatchQueue.main.async {
                    self.collectionView?.reloadData()
                    let indexPath = IndexPath(row: self.messages.count - 1, section: 0)
                    self.collectionView?.scrollToItem(at: indexPath, at: .bottom, animated: true)
                }
            })
        })
    }
    
    fileprivate func sendMessage(properties: [String: Any]) {
        let toId = user!.uid
        let fromId = Auth.auth().currentUser!.uid
        let timestamp = (Date().timeIntervalSince1970 * 1000).rounded()
        var values = ["toId": toId, "fromId": fromId, "timestamp": timestamp] as [String: Any]
        properties.forEach { values[$0] = $1 }
        
        Database.database().reference().child("messages").childByAutoId().updateChildValues(values) { (error, ref) in
            if let error = error {
                SVProgressHUD.showError(withStatus: "發送訊息失敗")
                print("Failed to send message: ", error)
                return
            }
            
            let messageId = ref.key
            
            Database.database().reference().child("user-message").child(fromId).child(toId).updateChildValues([messageId: 1])
            Database.database().reference().child("user-message").child(toId).child(fromId).updateChildValues([messageId: 1])
            Database.database().reference().child("user-list").child(fromId).child(toId).setValue([messageId: 1])
            Database.database().reference().child("user-list").child(toId).child(fromId).setValue([messageId: 1])
            
            self.messageInputView.clearTextField()
        }
    }
    
    fileprivate func uploadImage(image: UIImage) {
        guard let data = UIImageJPEGRepresentation(image, 0.5) else { return }
        
        let imageName = UUID().uuidString
        
        Storage.storage().reference().child("message_images").child(imageName).putData(data, metadata: nil, completion: { (metadata, error) in
            if let error = error {
                print("Failed to upload image: ", error)
                return
            }
            
            guard let imageUrl = metadata?.downloadURL()?.absoluteString else { return }
            
            self.sendMessage(properties: ["imageUrl": imageUrl, "imageWidth": image.size.width, "imageHeight": image.size.height])
        })
    }
    
    @objc fileprivate func keyboardWillShow() {
        guard messages.count > 0 else { return }
        let indexPath = IndexPath(row: messages.count - 1, section: 0)
        DispatchQueue.main.async {
            self.collectionView?.scrollToItem(at: indexPath, at: .bottom, animated: true)
        }
    }
    
}

extension ChatController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var height: CGFloat = 80
        let message = messages[indexPath.row]
        
        if let text = message.text {
            height = text.estimateFrame(withConstrainedWidth: 200, fontSize: 16).height + 20
        } else if let imageWidth = message.imageWidth, let imageHeight = message.imageHeight {
            height = CGFloat(imageHeight / imageWidth * 232)
        }
        
        return CGSize(width: UIScreen.main.bounds.width, height: height)
    }
    
}

extension ChatController: MessageInputViewDelegate {
    
    func pickImage() {
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        pickerController.allowsEditing = true
        present(pickerController, animated: true, completion: nil)
    }
    
    func sendText(text: String) {
        sendMessage(properties: ["text": text])
    }
    
}

extension ChatController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        var selectedImage: UIImage?
        
        if let editedImage = info["UIImagePickerControllerEditedImage"] as? UIImage {
            selectedImage = editedImage
        } else if let originalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            selectedImage = originalImage
        }
        
        if let selectedImage = selectedImage {
            uploadImage(image: selectedImage)
        }
        
        dismiss(animated: true, completion: nil)
    }
    
}
