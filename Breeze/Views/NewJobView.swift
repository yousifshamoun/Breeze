//
//  NewJobView.swift
//  Breeze
//
//  Created by Yousif  Shamoun  on 5/15/23.
//

import SwiftUI

struct NewJobView: View {
    @StateObject var viewModel = NewJobViewViewModel()
    let brands = ["Rheem", "Rinnai", "Bosch", "Stiebel"]
    var spinner = UIActivityIndicatorView(style: .large)
    @State var loading = false
    var body: some View {
        VStack {
            Text("New Job")
                .font(.system(size: 32))
                .bold()
                .padding(.top)
            Form {
                Picker(selection: $viewModel.selectedBrand, label: Text("Select Brand")) {
                    ForEach(brands, id: \.self) {
                        Text($0)
                    }
                }
                .pickerStyle(.segmented)
                .padding(5)
                Picker("Error Code: ", selection: $viewModel.errorCode) {
                    ForEach(1...100, id: \.self) { number in
                        Text("\(number)")
                    }
                }
                .pickerStyle(MenuPickerStyle())
                Toggle("Low Water Pressure", isOn: $viewModel.lowPressure)
                Toggle("No Hot Water", isOn: $viewModel.hotWater)
                Toggle("Leak Present", isOn: $viewModel.leakPresent)
                TextField("Other Issues: ", text: $viewModel.otherIssues)
                    .textFieldStyle(DefaultTextFieldStyle())
                    .padding(5)
                Button {
                    loading = true
                    viewModel.send()
                }
            label: {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .foregroundColor(Color.blue)
                    Text("Submit")
                        .bold()
                        .foregroundColor(Color.white)
                        .padding(1)
                }
            }
            .padding()
                if viewModel.completion.isEmpty && loading {
                    HStack {
                        Spacer()
                        ProgressView()
                            .scaleEffect(2)
                        Spacer()
                    }
                }
                Text(viewModel.completion)
                    .font(.system(size: 18))
                    .foregroundColor(Color.black)
                    .padding()
            }
        }
    }
}

struct NewJobView_Previews: PreviewProvider {
    static var previews: some View {
        NewJobView()
    }
}
