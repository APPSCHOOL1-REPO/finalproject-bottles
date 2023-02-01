//
//  ShopStore.swift
//  Bottles_V2
//
//  Created by Ethan Choi on 2023/01/19.
//

import Foundation
import Amplify
import AWSDataStorePlugin
import SwiftUI
import Combine

class ShopDataStore : ObservableObject {
    @Published var shops: [Shop] = []
    
    func getData() async {
        do {
            let shops = try await Amplify.DataStore.query(Shop.self)
            self.shops = shops
        } catch let error as DataStoreError {
            print("Error retrieving bottles \(error)")
        } catch {
            print("Unexpected error \(error)")
        }
    }
    
    func queryData() async {
        do {
            let result = try await Amplify.DataStore.query(Shop.self)
            // result will be of type [Post]
            print("Posts: \(result)")
        } catch let error as DataStoreError {
            print("Error on query() for type Post - \(error)")
        } catch {
            print("Unexpected error \(error)")
        }
    }
}