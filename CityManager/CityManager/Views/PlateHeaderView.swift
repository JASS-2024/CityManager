//
//  UsernameHeaderView.swift
//  SwipeFresh
//
//  Created by Aleksandra Topalova on 27.03.24.
//

import SwiftUI

struct PlateHeaderView: View {
    var plate: String
    var body: some View {
            HStack {
                Spacer()
                Text(plate)
                
                Image(systemName: "car.fill")
                    .font(.system(size: 30))
                    .padding(.trailing)
                    .opacity(plate.isEmpty ? 0 : 1)
            }
            .foregroundColor(.secondary)

    }
}

#Preview {
    PlateHeaderView(plate: "username")
}
