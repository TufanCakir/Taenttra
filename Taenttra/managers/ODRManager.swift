//
//  ODRManager.swift
//  Taenttra
//
//  Created by Tufan Cakir on 28.01.26.
//

import Foundation

final class ODRManager {

    static let shared = ODRManager()
    private init() {}

    private var activeRequests: [String: NSBundleResourceRequest] = [:]

    // MARK: - Load Assets

    func load(
        tags: Set<String>,
        priority: Double = NSBundleResourceRequestLoadingPriorityUrgent,
        completion: @escaping (Bool) -> Void
    ) {
        let key = tags.sorted().joined(separator: "_")

        // Schon geladen?
        if activeRequests[key] != nil {
            completion(true)
            return
        }

        let request = NSBundleResourceRequest(tags: tags)
        request.loadingPriority = priority

        activeRequests[key] = request

        request.beginAccessingResources { error in
            DispatchQueue.main.async {
                if let error = error {
                    print("❌ ODR load failed:", error)
                    self.activeRequests.removeValue(forKey: key)
                    completion(false)
                } else {
                    print("✅ ODR loaded:", tags)
                    completion(true)
                }
            }
        }
    }

    // MARK: - Release Assets

    func release(tags: Set<String>) {
        let key = tags.sorted().joined(separator: "_")

        guard let request = activeRequests[key] else { return }

        request.endAccessingResources()
        activeRequests.removeValue(forKey: key)

        print("🧹 ODR released:", tags)
    }
}
