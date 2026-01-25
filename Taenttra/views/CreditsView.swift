//
//  CreditsView.swift
//  Taenttra
//
//  Created by Tufan Cakir on 25.01.26.
//

import SwiftUI

struct CreditsView: View {

    var body: some View {
        List {
            Section {
                Text("TAENTTRA is an independent fighting game project.")
                Text("Design, Code & Art by Tufan Cakir.")
            }
        }
        .navigationTitle("Credits")
    }
}

