//
//  MainMenuView.swift
//  Cards
//
//  Created by Abdul Ahad Khan on 2020-12-10.
//

import SwiftUI

struct MainMenuView: View {
    
    
    
    var body: some View {
        
        NavigationView() {
            
            ZStack {
                LinearGradient(gradient: Gradient(colors: [.green, .white, .green]), startPoint: .top, endPoint: .bottom)
                    .edgesIgnoringSafeArea(.all)
                
                VStack {
                    
                    Text("Black Jack!")
                        .font(.largeTitle)
                        .fontWeight(.regular)
                        .multilineTextAlignment(.center)
                    
//                    NavigationLink(<#LocalizedStringKey#>, destination: ContentView())
                    
                }
            }
        }
    }
}

struct MainMenuView_Previews: PreviewProvider {
    static var previews: some View {
        MainMenuView()
    }
}
