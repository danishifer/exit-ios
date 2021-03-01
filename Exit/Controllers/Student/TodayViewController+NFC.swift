//
//  TodayViewController+NFC.swift
//  MyKey
//
//  Created by Dani Shifer on 12/25/19.
//  Copyright © 2019 Dani Shifer. All rights reserved.
//

import Foundation
import CoreNFC

extension TodayViewController: NFCNDEFReaderSessionDelegate {
    func readerSessionDidBecomeActive(_ session: NFCNDEFReaderSession) {
        print("Reader session active")
    }

    func readerSession(_ session: NFCNDEFReaderSession, didInvalidateWithError error: Error) {
        print(error)
    }

    func readerSession(_ session: NFCNDEFReaderSession, didDetectNDEFs messages: [NFCNDEFMessage]) {
        // Read NDEF data from card.
        
        // Get first message (containing uid and card number records)
        guard let message = messages.first else {
            if #available(iOS 13.0, *) {
                session.invalidate(errorMessage: "Invalid Card")
            } else {
                session.invalidate()
            }
            return
        }
        
        guard message.records.count >= 1 else {
            if #available(iOS 13.0, *) {
                session.invalidate(errorMessage: "Invalid Card")
            } else {
                session.invalidate()
            }
            return
        }
        
        guard let cardData = String(data: message.records[0].payload, encoding: .ascii) else {
            return
        }
        
        print(cardData)
        
        // uid;number;action
        let parts = cardData.split(separator: ";")
        
        let uid = parts[1]
        let number = parts[2]
        let actionType = parts[3]
        
        print(uid, number, actionType)
        DispatchQueue.main.async {
            self.performAction(of: String(actionType), cardSerial: String(uid))
        }
    }
}
