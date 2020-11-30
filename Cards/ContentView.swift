//
//  ContentView.swift
//  Cards
//
//  Created by Abdul Ahad Khan on 2020-11-30.
//

import SwiftUI

struct ContentView: View {
    
    @State private var cardShowing: Float = 0
    
    var body: some View {
        
        NavigationView() {
            
            ZStack {
                LinearGradient(gradient: Gradient(colors: [.green, .white, .green]), startPoint: .top, endPoint: .bottom)
                            .edgesIgnoringSafeArea(.all)
                Section {
                    
                    VStack {
                        Text("Card \(cardShowing, specifier: "%.0f")")
                                    .padding(.bottom)
                        Slider(value: $cardShowing, in: 1...13, step: 1)
                            .padding([.leading, .trailing])
                    }
                    
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
