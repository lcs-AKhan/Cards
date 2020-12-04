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
                
                Section {
                    
                    }
                    VStack {
                        Button(action: {
                            fetchDeck()
                        }) {
                            Text("Get a new deck")
                        }
                        
                }
            }
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
                    print("URL is: \(decodedDeckData.deck_id)")
                    
                    drawCard(deck_id: decodedDeckData.deck_id)
                    
                } else {

                    print("Invalid response from server.")
                }
                
            }.resume()
            
        }
    
    func drawCard(deck_id: String) {
            
            // 1. Prepare a URLRequest to send our encoded data as JSON
        let url = URL(string: "https://deckofcardsapi.com/api/deck/\(deck_id)/draw/?count=2")!
            var request = URLRequest(url: url)
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpMethod = "GET"
            
            // 2. Run the request and process the response
            URLSession.shared.dataTask(with: request) { data, response, error in
                
                // handle the result here – attempt to unwrap optional data provided by task
                guard let cardData = data else {
                    
                    // Show the error message
                    print("No data in response: \(error?.localizedDescription ?? "Unknown error")")
                    
                    return
                }
                
                // It seems to have worked? Let's see what we have
                print(String(data: cardData, encoding: .utf8)!)
                
                // Now decode from JSON into an array of Swift native data types
                if let decodedCardData = try? JSONDecoder().decode(DrawnCardResponse.self, from: cardData) {

                    print("Card data decoded from JSON successfully")
                    print("URL is: \(decodedCardData.cards)")
                    
                    
                } else {

                    print("Invalid response from server.")
                }
                
            }.resume()
            
        }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
