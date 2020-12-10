//
//  ContentView.swift
//  Cards
//
//  Created by Abdul Ahad Khan on 2020-11-30.
//

import SwiftUI

struct ContentView: View {
    
    @State private var yourStatus = ""
    @State private var dealerStatus = ""
    
    @Binding var gotNewDeck: Bool
    @Binding var deck_id: String
    
    @State private var cardImages = [RetrievedCard]()
    @State var cardImage = UIImage()
    
    @State private var cardImagesBot = [RetrievedCardBot]()
    @State private var cardImageBot = UIImage()
    
    @State private var dealerHandValue: Int = 0
    @State private var playerHandValue: Int = 0
    
    @State private var yourTurn: Bool = true
    
    @State private var playerStands = false
    
    @State private var gameEnded = false
    
    var body: some View {
        
        NavigationView {
            
            ZStack {
                LinearGradient(gradient: Gradient(colors: [.green, .white, .green]), startPoint: .top, endPoint: .bottom)
                    .edgesIgnoringSafeArea(.all)
                
                VStack {
                    
                    // Display the cards info for both dealer and player
                    
                    Text("Dealer's hand value is \(dealerHandValue)")
                    
                    DealtCardsDealerView(cardImagesBot: cardImagesBot)
                    
                    if yourTurn {
                        
                        Text("\(yourStatus)")
                        
                    } else {
                        
                        Text("\(dealerStatus)")
                        
                    }
                        
                    DealtCardsView(cardImages: cardImages)
                            
                    // Buttons for standing and hitting
                    
                    if gameEnded == false {
                        HStack {
                            if playerStands {
                                Button(action: {
                                    Stand()
                                }) {
                                    Image("button_stand")
                                        .resizable()
                                        .scaledToFit()
                                }
                            } else {
                                Button(action: {
                                    drawCard()
                                }) {
                                    Image("button_hit")
                                        .resizable()
                                        .scaledToFit()
                                }
                                Button(action: {
                                    Stand()
                                }) {
                                    Image("button_stand")
                                        .resizable()
                                        .scaledToFit()
                                }
                            }
                        }
                    }
                    
                        Text("Your hand value is \(playerHandValue)")
                    
                        // Buttons for playing a game
                    
                        if gotNewDeck == false {
                            Button(action: {
                                fetchDeck()
                            }) {
                                Image("button_play-blackjack")
                                    .resizable()
                                    .scaledToFit()
                            }
                        }
                    
                        if gameEnded {
                            Button(action: {
                                GameRestart()
                            }) {
                                Image("button_play-again")
                                    .resizable()
                                    .scaledToFit()
                            }
                        }
                    }
                }
            }
        }
    
    // functions
    
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

    func drawCard() {
        checkForBust()
        checkForWinner()
        if gameEnded == false {
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
                    
                    fetchImage(adress: decodedCardData.cards.first!.image, value:     decodedCardData.cards.first!.value)
                    
                } else {
                    
                    print("Invalid response from server.")
                }
                yourTurn = false
                if playerHandValue <= 21 {
                    if dealerHandValue <= 17 {
                        drawCardBot()
                    } else {
                        DealerStand()
                    }
                } else {
                    checkForBust()
                }
                checkForBust()
            }.resume()
            checkForWinner()
        }
    }
    
    func fetchImage(adress: String, value: String) {
        
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
                cardImages.append(RetrievedCard(image: cardImage, value: value))
                findValuePlayer(value: value)
                playerHandValue += Int(value) ?? 0
            }
            
        }.resume()
        
    }
    
    func drawCardBot() {
        checkForBust()
        checkForWinner()
        
        if gameEnded == false {
            // 1. Prepare a URLRequest to send our encoded data as JSON
            let url = URL(string: "https://deckofcardsapi.com/api/deck/\(deck_id)/draw/?count=1")!
            var request = URLRequest(url: url)
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpMethod = "GET"
            
            // 2. Run the request and process the response
            URLSession.shared.dataTask(with: request) { data, response, error in
                
                // handle the result here – attempt to unwrap optional data provided by task
                guard let cardDataDealer = data else {
                    
                    // Show the error message
                    print("No data in response: \(error?.localizedDescription ?? "Unknown error")")
                    
                    return
                }
                
                // It seems to have worked? Let's see what we have
                print(String(data: cardDataDealer, encoding: .utf8)!)
                
                // Now decode from JSON into an array of Swift native data types
                if let decodedCardData2 = try? JSONDecoder().decode(DrawnCardResponse.self, from: cardDataDealer) {
                    
                    print("Decoded... contents are")
                    print(decodedCardData2.cards.first!.image)
                    
                    fetchImageBot(adress2: decodedCardData2.cards.first!.image, value2: decodedCardData2.cards.first!.value)
                    
                } else {
                    
                    print("Invalid response from server.")
                }
                checkForBust()
                checkForWinner()
            }.resume()
        }
    }
    
    func fetchImageBot(adress2: String, value2: String) {
        
        // 1. Prepare a URL that points to the image to be leaded
        let url = URL(string: adress2)!
        
        // 2. Run the request and process the response
        URLSession.shared.dataTask(with: url) { data, response, error in
            
            // handle the result here – attempt to unwrap optional data provided by task
            guard let imageData2 = data else {
                
                // Show the error message
                print("No data in response: \(error?.localizedDescription ?? "Unknown error")")
                
                return
            }
            
            // Update the UI on the main thread
            DispatchQueue.main.async {
                
                // Attempt to create an instance of UIImage using the data from the server
                guard let loadedCard2 = UIImage(data: imageData2) else {
                    
                    // If we could not load the image from the server, show a default image
                    cardImageBot = UIImage(named: "Example2")!
                    return
                }
                
                // Set the image loaded from the server so that it shows in the user interface
                cardImageBot = loadedCard2
                cardImagesBot.append(RetrievedCardBot(image: cardImageBot, value: value2))
                findValueDealer(value2: value2)
                dealerHandValue += Int(value2) ?? 0
            }
            yourTurn = true
        }.resume()
        
    }
    
    func findValuePlayer(value: String) {
        if value == "KING" {
            playerHandValue += 10
        } else if value == "QUEEN" {
            playerHandValue += 10
        } else if value == "JACK" {
            playerHandValue += 10
        } else if value == "ACE" {
            playerHandValue += 11
        }
     }
    
    func findValueDealer(value2: String) {
        if value2 == "KING" {
            dealerHandValue += 10
        } else if value2 == "QUEEN" {
            dealerHandValue += 10
        } else if value2 == "JACK" {
            dealerHandValue += 10
        } else if value2 == "ACE" {
            dealerHandValue += 11
        }
    }
    
    func checkForBust() {
        if dealerHandValue > 21 {
            dealerStatus = "Dealer Busted!"
            yourStatus = "Dealer Busted!"
            gameEnded = true
        } else if playerHandValue > 21 {
            yourStatus = "You Busted!"
            dealerStatus = "You Busted!"
            gameEnded = true
        } else if playerHandValue <= 17 {
            yourStatus = "Your Turn"
        } else {
            dealerStatus = "Dealer's Turn"
        }
    }
    
    func checkForWinner() {
        if dealerHandValue > 14 {
            if playerStands {
                if (21 - dealerHandValue) < ( 21 - playerHandValue) {
                    dealerStatus = "Dealer Wins!"
                    yourStatus = "Dealer Wins!"
                    gameEnded = true
                } else if (21 - dealerHandValue) > (21 - playerHandValue) {
                    yourStatus = "You Win!"
                    dealerStatus = "You Win!"
                    gameEnded = true
                } else {
                    yourStatus = "Tie"
                    dealerStatus = "Tie"
                }
            }
        }
    }
    
    func GameRestart() {
        cardImages = [RetrievedCard]()
        cardImagesBot = [RetrievedCardBot]()
        dealerHandValue = 0
        playerHandValue = 0
        deck_id = ""
        fetchDeck()
        gameEnded = false
        yourStatus = ""
        dealerStatus = ""
        playerStands = false
    }
    
    func Stand() {
        yourTurn = false
        playerStands = true
        if dealerHandValue < 18 {
            drawCardBot()
        } else {
            checkForWinner()
        }
        checkForBust()
        checkForWinner()
    }
    
    func DealerStand() {
        yourTurn = true
    }
    
}


//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView(gotNewDeck: .constant(true), deck_id: .constant())
//    }
//}
