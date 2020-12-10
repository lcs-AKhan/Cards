//
//  MainMenuView.swift
//  Cards
//
//  Created by Abdul Ahad Khan on 2020-12-10.
//

import SwiftUI

struct MainMenuView: View {
    
    @State var gotNewDeck: Bool = false
    
    @State var deck_id: String = ""
    
    @State var playAGame: Bool = false
    
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
                    

                    NavigationLink(destination: ContentView(gotNewDeck: $gotNewDeck, deck_id: $deck_id), isActive: $playAGame) {
                        Button(action: {
                            playAGame = true
                        }) {
                            Image("button_play-blackjack")
                                .resizable()
                                .scaledToFit()
                        }
                    }
                    
                }
            }
        }
        .onAppear() {
            fetchDeck()
        }
        
    }
    func fetchDeck() {
        
        // 1. Prepare a URLRequest to send our encoded data as JSON
        let url = URL(string: "https://deckofcardsapi.com/api/deck/new/shuffle/?deck_count=1")!
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "GET"
        
        // 2. Run the request and process the response
        URLSession.shared.dataTask(with: request) { data, response, error in
            
            // handle the result here – attempt to unwrap optional data provided by task
            guard let deckData = data else {
                
                // Show the error message
                print("No data in response: \(error?.localizedDescription ?? "Unknown error")")
                
                return
            }
            
            // It seems to have worked? Let's see what we have
            print(String(data: deckData, encoding: .utf8)!)
            
            // Now decode from JSON into an array of Swift native data types
            if let decodedDeckData = try? JSONDecoder().decode(Deck.self, from: deckData) {
                
                print("Deck data decoded from JSON successfully")
                print("Id is: \(decodedDeckData.deck_id)")
                
                deck_id = decodedDeckData.deck_id
                
            } else {
                
                print("Invalid response from server.")
            }
            gotNewDeck = true
        }.resume()
        
    }

}

struct MainMenuView_Previews: PreviewProvider {
    static var previews: some View {
        MainMenuView()
    }
}
