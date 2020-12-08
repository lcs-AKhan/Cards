//
//  DealtCardsDealerView.swift
//  Cards
//
//  Created by Abdul Ahad Khan on 2020-12-08.
//

import SwiftUI

struct DealtCardsDealerView: View {
    
    var cardImagesBot: [RetrievedCardBot]
    
    var body: some View {
        HStack {
            ForEach(cardImagesBot) { card in
                Image(uiImage: card.image)
                    .resizable()
                    .frame(width: 90, height: 135)
            }
        }
    }
}

//struct DealtCardsDealerView_Previews: PreviewProvider {
//    static var previews: some View {
//        DealtCardsDealerView()
//    }
//}
