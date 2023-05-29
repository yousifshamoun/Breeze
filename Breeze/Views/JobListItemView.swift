//
//  JobListItemView.swift
//  Breeze
//
//  Created by Yousif  Shamoun  on 5/23/23.
//

import SwiftUI

struct JobListItemView: View {
    let job: PostProcessedJob
    @StateObject var viewModel = JobListItemViewModel()
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                
                Text("Model: " + job.modelNumber)
        
                Text(job.diagnosticQuestion)
                //                    .font(.footnote)
                //                    .foregroundColor(Color(.secondaryLabel))
                if job.status == "COMPLETE" {
                    Text(job.diagnosticAnswer)
                        .font(.footnote)
                        .foregroundColor(Color(.secondaryLabel))
                    Text(job.usedSpecificNamespace)
                        .font(.footnote)
                        .foregroundColor(Color(.secondaryLabel))
                } else {
                    HStack {
                        Spacer()
                        ProgressView()
                            .scaleEffect(2)
                        Spacer()
                    }
                }
            }
            Spacer()
            Button {
                viewModel.deleteFromPost(dId: job.id)
            } label: {
                Text("View")
            }
        }
    }
}

struct JobListItemView_Previews: PreviewProvider {
    static var previews: some View {
        JobListItemView(job: .init(id: "1234",
                                   serialNumber: "1818110231301",
                                   modelNumber: "G6-UT3030NV",
                                   usedSpecificNamespace: "Yes",
                                   diagnosticQuestion: "The status light is not flashing. Why?",
                                   diagnosticAnswer: "There could be several reasons for not getting hot water in the bath tub. One possibility is that the faucet or shower control has a defective Thermostatic Mixing Valve, which can reduce the amount of hot water delivered even though there is plenty of hot water in the tank. Another possibility is that the water heater is undersized for your needs or is too far away from the bath tub, causing the cold water already in the pipes to flow out before the hot water reaches the faucet. It is also important to check if the water temperature is set too low or if there is an error code flashing on the display panel.",
                                   status: "PENDING"
                                  ))
    }
}
