//
//  NewJobView.swift
//  Breeze
//
//  Created by Yousif  Shamoun  on 5/15/23.
//

import SwiftUI
import PhotosUI
struct NewJobView: View {
    @Binding var newJobPresented: Bool
    @StateObject var viewModel = NewJobViewViewModel()
    @State var ratingPlateImage: [PhotosPickerItem] = []
    @State var data: Data?
    var spinner = UIActivityIndicatorView(style: .large)
    @State var loading = false
    var body: some View {
        VStack {
            Text("New Job")
                .font(.system(size: 32))
                .bold()
                .padding(.top)
            Form {
                if let data = data, let uiimage = UIImage(data: data) {
                    Image(uiImage: uiimage)
                        .resizable()
                        .frame(width: UIScreen.main.bounds.width,
                               height: 300)
                }
                PhotosPicker(
                    selection: $ratingPlateImage,
                    maxSelectionCount: 1,
                    matching: .images
                ) {
                    Text("Pick Photo")
                }
                .onChange(of: ratingPlateImage) { newValue in
                    guard let item = ratingPlateImage.first else {return}
                    item .loadTransferable(type: Data.self) { result in
                        switch result {
                        case .success(let data):
                            if let data = data {
                                self.data = data
                            } else {
                                print("data is nil")
                            }
                        case .failure(let failure):
                            fatalError("failure")
                        }
                    }
                }
                Button {
                    viewModel.recognizeText(data: data)
                    newJobPresented = false
                    
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
//                if viewModel.completion.isEmpty && loading {
//                    HStack {
//                        Spacer()
//                        ProgressView()
//                            .scaleEffect(2)
//                        Spacer()
//                    }
//                }
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
        NewJobView(newJobPresented: Binding(get: {
            return true
        }, set: { _ in
        }))
    }
}
