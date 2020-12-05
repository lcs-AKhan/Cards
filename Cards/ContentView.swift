//
//  ContentView.swift
//  Cards
//
//  Created by Abdul Ahad Khan on 2020-11-30.
//

import SwiftUI

struct ContentView: View {
        
    @State private var deck_id = ""
    @State private var cardImages = [UIImage]()
    @State var cardImage = UIImage()
    
    var body: some View {
        
        NavigationView() {
            
            ZStack {
                LinearGradient(gradient: Gradient(colors: [.green, .white, .green]), startPoint: .top, endPoint: .bottom)
                            .edgesIgnoringSafeArea(.all)
                
                
                    VStack {
                        Image(uiImage: cardImage)
                        Button(action: {
                            fetchDeck()
                        }) {
                            Text("Get a new deck")
                        }
                        Button(action: {
                            drawCard()
                        }) {
                            Text("Draw Card")
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
                    print("Id is: \(decodedDeckData.deck_id)")
                    
                    deck_id = decodedDeckData.deck_id
                    
                } else {

                    print("Invalid response from server.")
                }
                
            }.resume()
        
        }
    
    func drawCard() {
            
            // 1. Prepare a URLRequest to send our encoded data as JSON
        let url = URL(string: "https://deckofcardsapi.com/api/deck/\(deck_id)/draw/?count=1")!
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
                    
                    print("Decoded... contents are")
                    print(decodedCardData.cards.first!.image)

//                    print("Doggie data decoded from JSON successfully")
//                    print("Images are: \(decodedCardData.cards)")
//
//                    // Now fetch the image at the address we were given
//                    //fetchImage(from: cardData.message)
//
                     fetchImage(adress: decodedCardData.cards.first!.image)
                    
                } else {

                    print("Invalid response from server.")
                }
                
            }.resume()
            
        }
    func fetchImage(adress: String) {

            // 1. Prepare a URL that points to the image to be leaded
            let url = URL(string: adress)!
            
            // 2. Run the request and process the response
            URLSession.shared.dataTask(with: url) { data, response, error in
                
                // handle the result here – attempt to unwrap optional data provided by task
                guard let imageData = data else {
                    
                    // Show the error message
                    print("No data in response: \(error?.localizedDescription ?? "Unknown error")")
                    
                    return
                }
                
                // Update the UI on the main thread
                DispatchQueue.main.async {
                                        
                    // Attempt to create an instance of UIImage using the data from the server
                    guard let loadedCard = UIImage(data: imageData) else {
                        
                        // If we could not load the image from the server, show a default image
                        cardImage = UIImage(named: "Example")!
                        return
                    }
                    
                    // Set the image loaded from the server so that it shows in the user interface
                    cardImage = loadedCard
                }
                
            }.resume()
            
        }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
