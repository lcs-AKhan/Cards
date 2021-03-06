//
//  ContentView.swift
//  Cards
//
//  Created by Abdul Ahad Khan on 2020-11-30.
//

import SwiftUI

struct ContentView: View {
    
    // Status
    @State private var yourStatus = ""
    @State private var dealerStatus = ""
    
    // Deck
    @Binding var gotNewDeck: Bool
    @Binding var deck_id: String
    
    // Cards
    @State private var cardImages = [RetrievedCard]()
    @State var cardImage = UIImage()
    
    // Hands
    @State private var cardImagesBot = [RetrievedCardBot]()
    @State private var cardImageBot = UIImage()
    
    // Hand Values
    @State private var dealerHandValue: Int = 0
    @State private var playerHandValue: Int = 0
    
    // Turns
    @State private var yourTurn: Bool = true
    
    @State private var playerStands = false
    
    // Game status
    @State private var gameEnded = false
    @State private var gameStarted = false
    
    var body: some View {
        
        NavigationView {
            
            ZStack {
                Image("blackjack_background")
                    .resizable()
                    .frame(width: 425, height: 900, alignment: .center)
                    .edgesIgnoringSafeArea(.all)
                
                VStack {
                    
                    // Display the cards info for both dealer and player
                    
                    Text("Dealer's hand value is \(dealerHandValue)")
                        .font(.subheadline)
                        .fontWeight(.heavy)
                    
                    if gameStarted == false {
                        Image("CardBack")
                            .resizable()
                            .frame(width: 90, height: 135)
                    }
                    
                    DealtCardsDealerView(cardImagesBot: cardImagesBot)
                    
                    if yourTurn {
                        
                        Text("\(yourStatus)")
                            .font(.headline)
                            .fontWeight(.heavy)
                        
                    } else {
                        
                        Text("\(dealerStatus)")
                            .font(.headline)
                            .fontWeight(.heavy)
                        
                    }
                        
                    DealtCardsView(cardImages: cardImages)

                    if gameStarted == false {
                        Image("CardBack")
                            .resizable()
                            .frame(width: 90, height: 135)
                    }
                                    
                    Text("Your hand value is \(playerHandValue)")
                        .font(.subheadline)
                        .fontWeight(.heavy)
                    
                    // Buttons for standing and hitting
                    
                    if gameEnded == false {
                        HStack {
                            if playerStands {
                                Button(action: {
                                    Stand()
                                }) {
                                    Image("button_stand")
                                        .resizable()
                                        .padding(.horizontal)
                                        .scaledToFit()
                                }
                            } else {
                                Button(action: {
                                    drawCard()
                                }) {
                                    Image("button_hit")
                                        .resizable()
                                        .padding(.horizontal)
                                        .scaledToFit()
                                }
                                Button(action: {
                                    Stand()
                                }) {
                                    Image("button_stand")
                                        .resizable()
                                        .padding(.horizontal)
                                        .scaledToFit()
                                }
                            }
                        }
                    }
                    
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
                                    .padding(.horizontal)
                                    .scaledToFit()
                            }
                        }
                    }
                }
            }
        }
    
    // Functions
    
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
        gameStarted = true
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
                        checkForBust()
                    }
                } else {
                    checkForBust()
                }
                checkForWinner()
            }.resume()
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
        
        if dealerHandValue < 22 {
            checkForWinner()
        }
        
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
                if dealerHandValue < 22 {
                    checkForWinner()
                }
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
    
    // For finding the value of a card which doesn't have a number on it
    func findValuePlayer(value: String) {
        switch value {
        case "KING":
            playerHandValue += 10
        case "QUEEN":
            playerHandValue += 10
        case "JACK":
            playerHandValue += 10
        case "ACE":
            playerHandValue += 10
        default:
            playerHandValue += 0
        }
     }
    
    func findValueDealer(value2: String) {
        switch value2 {
        case "KING":
            dealerHandValue += 10
        case "QUEEN":
            dealerHandValue += 10
        case "JACK":
            dealerHandValue += 10
        case "ACE":
            dealerHandValue += 10
        default:
            dealerHandValue += 0
        }
    }
    
    // Checking for events causing the game to end
    func checkForBust() {
        if dealerHandValue > 21 {
            dealerStatus = "Dealer Busted First!"
            yourStatus = "Dealer Busted!"
            gameEnded = true
        } else if playerHandValue > 21 {
            yourStatus = "You Busted First!"
            dealerStatus = "You Busted First!"
            gameEnded = true
        } else if yourTurn {
            yourStatus = "Your Turn"
        } else if yourTurn == false {
            dealerStatus = "Dealer's Turn"
        }
    }
    
    func checkForWinner() {
        if dealerHandValue >= 17 {
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
                    gameEnded = true
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
        gameStarted = false
    }
    
    func Stand() {
        gameStarted = true
        checkForBust()
        checkForWinner()
        if dealerHandValue < 17 {
            drawCardBot()
            checkForBust()
            if dealerHandValue >= 17, dealerHandValue < 22 {
                checkForWinner()
            }
        }
        if playerHandValue > 21 {
            gameEnded = true
            yourStatus = "You Busted First!"
        }
        checkForBust()
        yourTurn = false
        playerStands = true
    }
    
    func DealerStand() {
        yourTurn = true
        checkForBust()
    }
    
}

//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView(gotNewDeck: .constant(true), deck_id: .constant())
//    }
//}
