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
    var body: some View {
        VStack {
            Text("New Job")
                .font(.system(size: 32))
                .bold()
                .padding(.top)
            Form {
                Section {
                    if let data = data, let uiimage = UIImage(data: data) {
                        Image(uiImage: uiimage)
                            .resizable()
                            .frame(width: UIScreen.main.bounds.width,
                                   height: 200)
                    } else {
                        Image(uiImage: UIImage(named: "tankPlate")!)
                            .resizable()
                            .frame(width: UIScreen.main.bounds.width,
                                   height: 200)
                    }
                    PhotosPicker(
                        selection: $ratingPlateImage,
                        maxSelectionCount: 1,
                        matching: .images
                    ) {
                        HStack{
                            Spacer()
                            Text("Select picture")
                                .bold()
                                .font(.system(size: 16))
                            Image(systemName: "camera.fill")
                            Spacer()
                        }
                    }
                    .onChange(of: ratingPlateImage) { newValue in
                        guard let item = ratingPlateImage.first else {return}
                        item .loadTransferable(type: Data.self) { result in
                            switch result {
                            case .success(let data):
                                if let data = data {
                                    viewModel.recognizeText(data: data)
                                    self.data = data
                                } else {
                                    print("data is nil")
                                }
                            case .failure(let failure):
                                print(failure)
                                fatalError("failure")
                            }
                        }
                    }
                } header: {
                    Text("Take a picture of your rating plate: ")
                }
                TextField("Ask any question... ", text: $viewModel.diagnosticQuestion)
                .padding(.vertical)
                Section {
                    Button {
                        viewModel.sendQuestion()
                        newJobPresented = false
                    }
                label: {
                    HStack {
                        Spacer()
                        Image(systemName: "paperplane.circle.fill")
                            .resizable()
                            .frame(width: 50,
                                   height: 50)
                        Spacer()
                    }
                }
                }
                .listRowBackground(Color.clear)
            }
        }
    }
}
    

struct NewJobView_Previews: PreviewProvider {
    static var previews: some View {
        NewJobView(newJobPresented: Binding(get: {
            return true
        }, set: { _ in
        })
        )
    }
}


    


