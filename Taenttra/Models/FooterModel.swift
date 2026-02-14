//
//  FooterModel.swift
//  Taenttra
//
//  Created by Tufan Cakir on 14.02.26.
//

import Foundation

struct FooterData: Codable {
    let tabs: [FooterTab]
}

struct FooterTab: Codable, Identifiable, Hashable {
    let id: String
    let title: String
    let icon: String
}
