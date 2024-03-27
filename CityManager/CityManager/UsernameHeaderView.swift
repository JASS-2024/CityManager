//
//  UsernameHeaderView.swift
//  SwipeFresh
//
//  Created by Aleksandra Topalova on 27.03.24.
//

import SwiftUI

struct UsernameHeaderView: View {
    var username: String
    var body: some View {
        HStack {
            Spacer()
            Text(username)
            Image(systemName: "person.fill")
                .imageScale(.large)
            .padding(.trailing)
        }
        .foregroundColor(/*@START_MENU_TOKEN@*/.blue/*@END_MENU_TOKEN@*/)

    }
}

#Preview {
    UsernameHeaderView(username: "username")
}
