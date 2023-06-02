//
//  ChatView.swift
//  Breeze
//
//  Created by Yousif  Shamoun  on 5/14/23.
//

import SwiftUI
struct Estimate: Identifiable {
    let id = UUID()
    let name: String
    let cost: String
    var days: String?
    var items: [Estimate]?
}
struct EstimateView: View {
    let job: PostProcessedJob
    @Binding var path: [PostProcessedJob]
    @StateObject var viewModel = EstimateViewViewModel()
    var body: some View {
        ScrollView{
            VStack {
                    QuestionAndAnswerView(job: job)
                    // If no estimates are on screen, push show estimate button to bottom
                    if !viewModel.estimateIsShowing{
                        Spacer()
                    }
                    EstimatesListView(viewModel: viewModel, path: $path, job:job)
            }
            .navigationTitle("\(Date(timeIntervalSince1970: job.createdDate).formatted(date:.abbreviated, time:.omitted))")
            .padding(.horizontal)
        }
    }
}


struct QuestionAndAnswerView: View {
    let job: PostProcessedJob
    var body: some View {
        VStack {
            ScrollView {
                HStack{
                    Spacer()
                    HStack {
                        Text(job.diagnosticQuestion)
                            .foregroundColor(.white)
                            .font(.custom("Roboto-Regular", size: 18))
                        
                    }
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(8)
                }
                HStack{
                    HStack {
                        Text(job.diagnosticAnswer)
                            .foregroundColor(.black)
                            .font(.custom("Roboto-Regular", size: 18))
                    }
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(8)
                    
                    Spacer()
                }
            }
        }
    }
}

struct EstimatesListView: View {
    let estimates: [Estimate] = [.case1, .case2]
    let urgencies: [String] = ["Low", "Normal", "High"]
    @ObservedObject var viewModel: EstimateViewViewModel
    @Binding var path: [PostProcessedJob]
    let job: PostProcessedJob
    var body: some View {
        VStack {
            if !viewModel.estimateIsShowing {
                Button {
                    viewModel.estimateIsShowing = true
                } label : {
                    ZStack {
                        RoundedRectangle(cornerRadius: 8)
                            .foregroundColor(Color.orange.opacity(0.8))
                            .frame(width: 200, height: 50)
                        Text("Show Estimate")
                            .foregroundColor(.white)
                            .font(.custom("Roboto-Bold", size: 18))
                    }
                }
            }
            if viewModel.estimateIsShowing {
                VStack {
                    // Estimates list
                    List(estimates, children: \.items) { item in
                        VStack {
                            HStack {
                                Text(item.name)
                                    .font(.custom("Roboto-Regular", size: 20))
                                Spacer()
                                Text("$"+item.cost)
                                    .font(.custom("Roboto-Bold", size: 20))
                            }
                        }
                    }
                    .frame(height: 450)
                    if job.status != "ACTIVE" {
                    // Homeowner info form
                    VStack {
                        VStack(alignment: .leading) {
                            Text("Address")
                                .font(.headline)
                            TextField("Enter home address", text: $viewModel.address)
                                .padding(.all)
                                .clipShape(RoundedRectangle(cornerRadius: 5))
                                .background(Color.gray.opacity(0.2))
                        }
                        .padding(.horizontal, 15)
                        VStack(alignment: .leading) {
                            Text("Zipcode")
                                .font(.headline)
                            TextField("Enter Zipcode", text: $viewModel.zipCode)
                                .padding(.all)
                                .clipShape(RoundedRectangle(cornerRadius: 5))
                                .background(Color.gray.opacity(0.2))
                        }
                        .padding(.horizontal, 15)
                        VStack(alignment: .leading) {
                            Text("Issue(s)")
                                .font(.headline)
                            TextField("Enter issues with water heater", text: $viewModel.customerIssues)
                                .padding(.all)
                                .clipShape(RoundedRectangle(cornerRadius: 5))
                                .background(Color.gray.opacity(0.2))
                        }
                        .padding(.horizontal, 15)
                        VStack(alignment: .leading) {
                            Text("Job Urgency")
                                .font(.headline)
                            Picker("Water heater location", selection: $viewModel.jobUrgency) {
                                ForEach(urgencies, id: \.self) {
                                    Text($0)
                                }
                            }
                            .pickerStyle(.segmented)
                        }
                        .padding(.horizontal, 15)
                        VStack(alignment: .leading) {
                            Text("Additional Notes (Optional)")
                                .font(.headline)
                            TextField("", text: $viewModel.additionalNotes)
                                .padding(.all)
                                .clipShape(RoundedRectangle(cornerRadius: 5))
                                .background(Color.gray.opacity(0.2))
                        }
                        .padding(.horizontal, 15)
                    }
                    // Call to Action
                        Button {
                            viewModel.setJobActive(job: job)
                            if viewModel.validate() {
                                path = []
                            }
                        } label: {
                            ZStack {
                                RoundedRectangle(cornerRadius: 8)
                                    .foregroundColor(Color.orange.opacity(0.8))
                                    .frame(width: 200, height: 50)
                                Text("Get Quotes")
                                    .foregroundColor(.white)
                                    .font(.custom("Roboto-Bold", size: 18))
                            }
                        }
                    }
                }
            }
        }
    }
}


extension Estimate {
    static let thermopile = Estimate(name: "Thermopile", cost: "150")
    static let water_heater = Estimate(name: "Water Heater", cost: "900")
    static let repair_labor = Estimate(name: "Labor", cost: "190-250")
    static let replacment_labor = Estimate(name: "Labor", cost: "400-600")
    
    static let case1 = Estimate(name: "If the thermopile needs to be replaced:", cost: "370-430", days: "3-5 days", items: [Estimate.thermopile, Estimate.repair_labor])
    static let case2 = Estimate(name: "If the water heater needs to be replaced:", cost: "1300-1500",days: "7-10 days", items: [Estimate.water_heater, Estimate.replacment_labor])
}


struct ChatView_Previews: PreviewProvider {
    static var previews: some View {
        EstimateView(job: .init(id: "1234",
                                serialNumber: "1818110231301",
                                modelNumber: "G6-UT3030NV",
                                usedSpecificNamespace: "Yes",
                                diagnosticQuestion: "The status light is not flashing. Why?",
                                diagnosticAnswer: "There could be several reasons for not getting hot water in the bath tub. One possibility is that the faucet or shower control has a defective Thermostatic Mixing Valve, which can reduce the amount of hot water delivered even though there is plenty of hot water in the tank. Another possibility is that the water heater is undersized for your needs or is too far away from the bath tub, causing the cold water already in the pipes to flow out before the hot water reaches the faucet. It is also important to check if the water temperature is set too low or if there is an error code flashing on the display panel.",
                                status: "PENDING",
                                createdDate: 1685409262
                               ),path: Binding(get: {
            return []
        }, set: { _ in
        }))

    }
}
