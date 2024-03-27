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
                .font(.system(size: 30))
            .padding(.trailing)
        }
        .foregroundColor(.secondary)

    }
}

#Preview {
    UsernameHeaderView(username: "username")
}
