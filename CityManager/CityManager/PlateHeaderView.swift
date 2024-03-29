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
                if !plate.isEmpty {
                Image(systemName: "car.fill")
                    .font(.system(size: 30))
                    .padding(.trailing)
                }
            }
            .foregroundColor(.secondary)

    }
}

#Preview {
    PlateHeaderView(plate: "username")
}
