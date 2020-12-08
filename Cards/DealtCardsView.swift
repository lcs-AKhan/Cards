//
//  DealtCardsView.swift
//  Cards
//
//  Created by Abdul Ahad Khan on 2020-12-08.
//

import SwiftUI

struct DealtCardsView: View {
    
    var cardImages: [RetrievedCard]
    
    var body: some View {
        HStack {
            ForEach(cardImages) { card in
                Image(uiImage: card.image)
                    .resizable()
                    .frame(width: 90, height: 135)
            }
        }
    }
}

//struct DealtCardsView_Previews: PreviewProvider {
//    static var previews: some View {
//        DealtCardsView()
//    }
//}
