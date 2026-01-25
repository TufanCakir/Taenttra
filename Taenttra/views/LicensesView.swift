//
//  LicensesView.swift
//  Taenttra
//
//  Created by Tufan Cakir on 25.01.26.
//

import SwiftUI

struct LicensesView: View {

    var body: some View {
        ScrollView {
            Text("Open source licenses will be listed here.")
                .padding()
                .foregroundStyle(.secondary)
        }
        .navigationTitle("Licenses")
    }
}
