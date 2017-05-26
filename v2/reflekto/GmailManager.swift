/*
 Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
 1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
 3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */
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
