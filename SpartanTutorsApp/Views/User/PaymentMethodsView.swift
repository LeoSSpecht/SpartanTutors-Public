//
//  PaymentMethodsView.swift
//  SpartanTutors
//
//  Created by Leo on 7/31/22.
//

import SwiftUI

struct PaymentMethodsView: View {
    @Environment(\.openURL) var openURL
    var image_size: CGFloat = 25
    var links = [
        PaymentLink(id: 1, link: "https://venmo.com/code?user_id=3452041510782782609&created=1657753854.0826159&printed=1", image_name: "venmo", text: "Venmo (Preferred)"),
        PaymentLink(id: 2, link: "https://paypal.me/spartantutors", image_name: "paypal", text:"PayPal")
    ]
    var body: some View {
        ForEach(links){ link in
            Link(destination: URL(string: link.link)!){
                Label{
                    Text(link.text)
                }
                icon: {
                    Image(link.image_name)
                        .resizable()
                        .scaledToFit()
                        .frame(width: image_size, height: image_size)
                }
            }
        }
    }
}

struct PaymentMethodsView_Previews: PreviewProvider {
    static var previews: some View {
        VStack{
            PaymentMethodsView()
        }
    }
}

struct PaymentLink: Identifiable{
    let id: Int
    let link: String
    let image_name: String
    let text: String
}
