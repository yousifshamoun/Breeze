//
//  CustomTextField.swift
//  Breeze
//
//  Created by Yousif  Shamoun  on 6/2/23.
//

import SwiftUI

struct CustomTextField: View {
    let placeholder: Text
    var editingChanged: (Bool) -> () = {_ in}
    var commit = {}
    @Binding var text: String
    var body: some View {
    
            ZStack(alignment: .leading) {
                if text.isEmpty {
                    placeholder
                        .opacity(0.5)
                }
                TextField("", text: $text, onEditingChanged: editingChanged,onCommit: commit)
            }
    }
}

struct CustomTextField_Previews: PreviewProvider {
    static var previews: some View {
        CustomTextField(placeholder: Text("Type something..."), text: Binding(get: {
            return ""
        }, set: { _ in
        }))
    }
}
