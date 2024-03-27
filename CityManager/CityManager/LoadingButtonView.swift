//
//  LoadingButtonView.swift
//  SwipeFresh
//
//  Created by Aleksandra Topalova on 27.03.24.
//

import SwiftUI

struct LoadingButtonView: View {
    @State var degreesRotating = 0.0
    
    var body: some View {
        Image(systemName: "circle.dashed")
                  .foregroundColor(.white)
                  .rotationEffect(.degrees(degreesRotating))
                
                  .onAppear {
                      withAnimation(.linear(duration: 1)
                          .speed(0.1).repeatForever(autoreverses: false)) {
                              degreesRotating = 360.0
                          }
                  }
    }
}

#Preview {
    LoadingButtonView()
}
