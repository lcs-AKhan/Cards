//
//  ContentView.swift
//  Cards
//
//  Created by Abdul Ahad Khan on 2020-11-30.
//

import SwiftUI

struct ContentView: View {
    
    
    
    var body: some View {
        
        NavigationView() {
            
            ZStack {
                LinearGradient(gradient: Gradient(colors: [.green, .white, .green]), startPoint: .top, endPoint: .bottom)
                            .edgesIgnoringSafeArea(.all)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
