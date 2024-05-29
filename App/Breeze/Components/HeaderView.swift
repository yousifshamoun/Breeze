//
//  HeaderView.swift
//  Breeze
//
//  Created by Yousif  Shamoun  on 5/14/23.
//

import SwiftUI

struct HeaderView: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 0)
                .foregroundColor(Color.purple)
                .opacity(0.75)
                .rotationEffect(Angle(degrees: -5))
            VStack {
                Text("Breeze")
                    .foregroundColor(Color.white)
                    .font(.system(size: 50))
                    .bold()
                Text("Home Solutions")
                    .foregroundColor(Color.white)
                    .font(.system(size: 30))
            }
        }
        .frame(width: UIScreen.main.bounds.width * 3,
               height: 300)
        .offset(y: -125)
    }
}

struct HeaderView_Previews: PreviewProvider {
    static var previews: some View {
        HeaderView()
    }
}
