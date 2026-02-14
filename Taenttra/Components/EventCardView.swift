//
//  EventCardView.swift
//  Taenttra
//
//  Created by Tufan Cakir on 14.02.26.
//

import SwiftUI

struct EventCardView: View {
    
    let event: EventModel
    
    var body: some View {
        ZStack {
            Image(event.image)
                .resizable()
                .scaledToFill()
            
            Image("event_frame")
                .resizable(
                    capInsets: EdgeInsets(top: 60, leading: 60, bottom: 60, trailing: 60),
                    resizingMode: .stretch
                )
            
            VStack {
                Spacer()
                Text(event.title)
                    .foregroundColor(.white)
                    .bold()
            }
        }
        .frame(height: 150)
        .clipped()
    }
}
