//
//  UsernamePopupVew.swift
//  SwipeFresh
//
//  Created by Aleksandra Topalova on 27.03.24.
//

import SwiftUI

struct UsernamePopupVew: View {
    @State private var presentAlert = false
    @State private var username: String = ""
        
        var body: some View {
            Button("Show Alert") {
                presentAlert = true
            }
            .alert("Login", isPresented: $presentAlert, actions: {
                TextField("Username", text: $username)
                
                Button("Login", action: {})
                Button("Cancel", role: .cancel, action: {})
            }, message: {
                Text("Please enter your username and password.")
            })
        }
}

#Preview {
    UsernamePopupVew()
}
