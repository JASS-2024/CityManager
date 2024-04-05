//
//  MessageView.swift
//  SwipeFresh
//
//  Created by Aleksandra Topalova on 26.03.24.
//

import Foundation

import SwiftUI

struct MessageView : View {
    var currentMessage: Message
    
    var body: some View {
        HStack(alignment: .bottom, spacing: 10) {
            if currentMessage.isCurrentUser {
                Spacer()
            }
            VStack (alignment: .leading, spacing: 10) {
                if !currentMessage.isCurrentUser {
                    Text("City Manager")
                        .textCase(.uppercase)
                        .font(.caption)
                        .foregroundStyle(.gray)
                }
                MessageCell(contentMessage: currentMessage.content,
                            isCurrentUser: currentMessage.isCurrentUser)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
    }
}


#Preview {
    MessageView(currentMessage: Message(content: "This is a single message cell with avatar. If user is current user, we won't display the avatar.", isCurrentUser: false))
}
