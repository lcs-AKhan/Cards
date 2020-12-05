//
//  DrawnCardResponse.swift
//  Cards
//
//  Created by Abdul Ahad Khan on 2020-12-03.
//

import Foundation

struct CardImage: Codable {
    var svg: String
    var png: String
}

struct Card: Codable {
    var code: String
    var image: String
    var images: CardImage
    var value: String
    var suit: String
    
}

struct DrawnCardResponse: Codable {
    var success: Bool
    var deck_id: String
    var cards: [Card]
    var remaining: Int
}
//
//struct DrawnCardResponse: Codable {
//    var success: Bool
//    var deck_id: String
//    var cards: [Card]
//    var remaining: Int
//}
