//
//  MessageBubble.swift
//  Breeze
//
//  Created by Yousif  Shamoun  on 6/2/23.
//

import SwiftUI

struct MessageBubble: View {
    let message: Message
    @State private var showingTimeStamp = false
    var body: some View {
        VStack(alignment: !message.received ? .trailing : .leading) {
            HStack {
                Text(message.text)
                    .padding()
                    .background(!message.received ? Color("Peach") : Color("Gray"))
                    .cornerRadius(30)
            }
            .frame(maxWidth: 300, alignment: !message.received ? .trailing : .leading)
            .onTapGesture {
                showingTimeStamp.toggle()
            }
            
            if showingTimeStamp {
                Text("\(Date(timeIntervalSince1970:  message.timeSent).formatted(.dateTime.hour().minute()))")
                    .font(.caption2)
                    .foregroundColor(.gray)
                    .padding(!message.received ? .trailing : .leading, 25)
            }
        }
        .frame(maxWidth: .infinity, alignment: !message.received ? .trailing : .leading)
        .padding(!message.received ? .trailing : .leading)
        .padding(.horizontal, 10)
    }
}

struct MessageBubble_Previews: PreviewProvider {
    static var previews: some View {
        MessageBubble(message: Message(id: "940AEC2F-71A7-49C1-BB6A-ED34DB503531", text: "Hi Yousif Shamoun, this is Saad Shamoun from High Tech Plumbing. I'd be happy to service the water heater issues you reported on Thu, June 1. Would you be available Fri, June 2 at 1:50 PM for an initial appointment?", received: true, timeSent: 1685739057.8471298))
    }
}
