//
//  FirestoreService.swift
//  PulsePod
//
//  Created by Matthew Maloof on 10/11/23.
//

import Firebase

class FirestoreService {
    static let shared = FirestoreService()

    private init() {}

    private var db: Firestore {
        return Firestore.firestore()
    }

    func saveFeedback(for articleID: String, feedback: String, completion: @escaping (Error?) -> Void) {
        guard let userID = Auth.auth().currentUser?.uid else {
            completion(NSError(domain: "PulsePod", code: 401, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"]))
            return
        }

        db.collection("feedback").addDocument(data: [
            "userID": userID,
            "articleID": articleID,
            "feedback": feedback,
            "timestamp": Timestamp(date: Date())
        ]) { error in
            completion(error)
        }
    }
}
