//
//  DeckOfCardsView.swift
//  Cards
//
//  Created by Abdul Ahad Khan on 2020-12-03.
//

import Foundation

struct Deck: Decodable {
    var success: Bool
    var deck_id: String
    var shuffled: Bool
    var remaining: Int
}
