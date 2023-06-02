//
//  MessagesListItemView.swift
//  Breeze
//
//  Created by Yousif  Shamoun  on 6/1/23.
//

import SwiftUI

struct MessagesListItemView: View {
    let mutualJob: MutualJob
    let imageUrl = URL(string:"https://plus.unsplash.com/premium_photo-1666299357356-db1ed4a6d50b?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=3087&q=80")
    
    var body: some View {
        HStack(spacing: 20) {
            
            AsyncImage(url: imageUrl) { image in
                    image.resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 50, height: 50)
                    .cornerRadius(50)
            } placeholder: {
                ProgressView()
            }
            VStack(alignment: .leading) {
                Text(mutualJob.technicianName)
                    .font(.title)
                    .bold()
                Text("Online")
                    .font(.caption)
                    .foregroundColor(.green)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

//struct MessagesListItemView_Previews: PreviewProvider {
//    static var previews: some View {
//        MessagesListItemView(mutualJob: .init(id: "", uId: "", tId: "", serialNumber: "1", modelNumber: "String", createdDate: 0, customerName: "Jane", technicianName: "Saad", companyName: "High Tech Plumbing", address: "", zipCode: "", customerIssues: "", jobUrgency: "", additionalNotes: "", initialAppointment: 0, status: "")
//        )
//    }
//}
//
