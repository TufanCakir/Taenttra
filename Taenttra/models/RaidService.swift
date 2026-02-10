//
//  RaidService.swift
//  Taenttra
//
//  Created by Tufan Cakir on 10.02.26.
//

import CloudKit
import Foundation

final class RaidService {

    static let shared = RaidService()
    private let container = CKContainer(
        identifier: "iCloud.com.tufancakir.taenttra"
    )
    private let db: CKDatabase

    init() {
        self.db = container.publicCloudDatabase
    }

    func bootstrapRaidIfNeeded(
        raidId: String,
        initialHP: Int64 = 100_000
    ) {
        let recordID = CKRecord.ID(recordName: raidId)

        db.fetch(withRecordID: recordID) { _, error in
            if error == nil {
                print("🟡 [Bootstrap] Raid already exists:", raidId)
                return
            }

            guard
                let ckError = error as? CKError,
                ckError.code == .unknownItem
            else {
                print("🔴 [Bootstrap] Unexpected error:", error!)
                return
            }

            let record = CKRecord(
                recordType: "RaidBoss",
                recordID: recordID
            )

            record["raidId"] = raidId as CKRecordValue
            record["currentHP"] = initialHP as CKRecordValue
            record["maxHP"] = initialHP as CKRecordValue
            record["phase"] = 1 as CKRecordValue

            self.db.save(record) { _, error in
                if let error = error {
                    print("🔴 [Bootstrap] SAVE ERROR:", error)
                } else {
                    print("🟢 [Bootstrap] Raid created:", raidId)
                }
            }
        }
    }

    // MARK: - Load Raid
    func loadRaid(
        raidId: String,
        completion: @escaping (Int64, Int64) -> Void
    ) {
        let recordID = CKRecord.ID(recordName: raidId)

        print("🟡 [RaidService] loadRaid =", raidId)

        db.fetch(withRecordID: recordID) { record, error in
            if let error = error {
                print("🔴 [RaidService] FETCH ERROR:", error)
                return
            }

            guard let record else {
                print("🔴 [RaidService] Record nil")
                return
            }

            let currentHP = record["currentHP"] as? Int64 ?? 0
            let maxHP = record["maxHP"] as? Int64 ?? 1

            print("🟢 [RaidService] HP =", currentHP, "/", maxHP)

            DispatchQueue.main.async {
                completion(currentHP, maxHP)
            }
        }
    }

    // MARK: - Submit Damage (safe)
    func submitDamage(
        raidId: String,
        damage: Int
    ) {
        let recordID = CKRecord.ID(recordName: raidId)

        db.fetch(withRecordID: recordID) { record, error in
            guard let record, error == nil else { return }

            let currentHP = record["currentHP"] as? Int64 ?? 0
            guard currentHP > 0 else { return }

            let newHP = max(0, currentHP - Int64(damage))
            record["currentHP"] = newHP as CKRecordValue

            let operation = CKModifyRecordsOperation(
                recordsToSave: [record]
            )

            operation.savePolicy = .changedKeys
            operation.qualityOfService = .userInitiated

            self.db.add(operation)
        }
    }
}
