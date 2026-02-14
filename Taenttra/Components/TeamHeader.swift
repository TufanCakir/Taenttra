//
//  TeamHeader.swift
//  Taenttra
//
//  Created by Tufan Cakir on 14.02.26.
//

import SwiftUI

struct TeamHeader: View {

    var body: some View {
        ZStack {
            Image("frame_header")
                .resizable()
                .scaledToFit()
                .frame(height: 80)

            Text("Your Team")
                .font(.title2)
                .bold()
                .foregroundColor(.white)
        }
        .padding(.top)
    }
}
