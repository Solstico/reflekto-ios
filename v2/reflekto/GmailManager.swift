//
//  GmailManager.swift
//  reflekto
//
//  Created by Michał Kwiecień on 08.05.2017.
//  Copyright © 2017 Solstico. All rights reserved.
//

import Foundation
import GoogleAPIClientForREST
import GoogleSignIn

class GmailManager: NSObject, GIDSignInDelegate {
    
    fileprivate let service = GTLRGmailService()
    var unreadEmailsCountResponse: ((Int) -> (Void))?
    
    override init() {
        super.init()
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().scopes = [kGTLRAuthScopeGmailReadonly]
    }
    
    
    
    func getUnreadMails() {
        DispatchQueue.main.async {
            GIDSignIn.sharedInstance().signInSilently()
        }
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        guard error == nil else {
            unreadEmailsCountResponse?(0)
            return
        }
        self.service.authorizer = user.authentication.fetcherAuthorizer()
        let query = GTLRGmailQuery_UsersMessagesList.query(withUserId: "me")
        query.q = "is:unread"
        service.executeQuery(query) { [weak self] (ticket, response, error) in
            guard let messagesResponse = response as? GTLRGmail_ListMessagesResponse else { return }
            let unreadMailsCount = messagesResponse.messages?.count ?? 0
            self?.unreadEmailsCountResponse?(unreadMailsCount)
        }
    }
    
    
}
