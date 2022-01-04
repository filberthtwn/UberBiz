//
//  MessagingVM.swift
//  uberbiz
//
//  Created by Filbert Hartawan on 27/09/21.
//

import Foundation
import Firebase
import RxSwift
import RxCocoa
import SwiftyJSON

class MessagingVM{
    static var shared = MessagingVM()
    private let db = Firestore.firestore()
    
    let dialogs: PublishSubject<[Dialog]> = PublishSubject()
    let messages: PublishSubject<[Chat]> = PublishSubject()
    
    let success: PublishSubject<Bool> = PublishSubject()
    let errMsg: PublishSubject<String> = PublishSubject()
    
    let sendChatUrl = "user/message/send_chat"

    func getAllDialog(email: String?){
        var dialogs:[Dialog]  = []
        
        guard let email = email else {
            self.dialogs.onNext([])
            return
        }
        
        db.collection("messaging").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print(err)
                self.errMsg.onNext(err.localizedDescription)
            } else {
                for document in querySnapshot!.documents {
                    if let occupants = document.data()["occupants"] as? [[String: Any]],
                       (occupants.first(where: { ($0["email"] as? String) == email }) != nil){
                        
                        let json = JSON(document.data())
                        do {
                            var dialog = try JSONDecoder().decode(Dialog.self, from: json.rawData())
                            dialog.id = document.documentID
                            dialogs.append(dialog)
                        } catch(let err) {
                            print(err)
                            self.errMsg.onNext(err.localizedDescription)
                        }
                    }
                }
                self.dialogs.onNext(dialogs)
            }
        }
    }
    
    func getAllMessages(dialogId: String){
        db.collection("messaging").addSnapshotListener { (querySnapshot, err) in
            if let err = err {
                self.errMsg.onNext(err.localizedDescription)
            } else {
                
                for document in querySnapshot!.documents {
                    if(document.documentID == dialogId){
                        guard let messagesJson = document.data()["messages"] else { return self.messages.onNext([]) }
                        let json = JSON(messagesJson as! [[String: Any]])
                        do {
                            let messages = try JSONDecoder().decode([Chat].self, from: json.rawData())
                            print("(DEBUG) GET MESSAGES")
                            self.messages.onNext(messages)
                       } catch(let err) {
                            
                           self.errMsg.onNext(err.localizedDescription)
                       }
                            
                    }
//                    if let occupants = document.data()["occupants"] as? [[String: Any]],
//                       (occupants.first(where: { ($0["email"] as! String) == email }) != nil){
//
//                        let json = JSON(document.data())
//                        do {
//                            let dialog = try JSONDecoder().decode(Dialog.self, from: json.rawData())
//                            dialogs.append(dialog)
//                        } catch(let err) {
//                            self.errMsg.onNext(err.localizedDescription)
//                        }
//                    }
                }
//                self.dialogs.onNext(dialogs)
            }
        }
    }
    
    func sendTextChat(dialogId: String, text: String){
        let url = String(format: "/%@/%@", sendChatUrl, dialogId)
        let params:[String:Any] = [
            "type": "text",
            "text": text
        ]
        
        PrivateService.shared.post(url: url, params: params) { (status, data, error) -> (Void) in
            if status != Network.Status.SUCCESS{
                guard let error = error else {return}
                self.errMsg.onNext(error)
            }
        }
    }
    
    func sendImageChat(dialogId: String, image: UIImage){
        let url = String(format: "/%@/%@", sendChatUrl, dialogId)
        let params:[String:Any] = [
            "type": "image"
        ]

        PrivateService.shared.upload(url: url, images: [image], params: params, key: "file", completion: { (status, data, error) in
            if let error = error{
                self.errMsg.onNext(error)
                return
            }
            self.success.onNext(true)
        })
    }
    
    func sendQuotation(dialogId: String, quotation:String){
        let url = String(format: "/%@/%@", sendChatUrl, dialogId)
        let params:[String:Any] = [
            "quotation_id": quotation
        ]
        
        PrivateService.shared.post(url: url, params: params) { (status, data, error) -> (Void) in
            
        }
    }
}
