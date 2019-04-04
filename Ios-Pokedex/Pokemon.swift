//
//  Pokemon.swift
//  Ios-Pokedex
//
//  Created by Muuk Van der Sande on 02/04/2019.
//  Copyright © 2019 Muuk Van der Sande. All rights reserved.
//

import Foundation

class Pokemon {
    let localId: Int?
    let id: Int
    let name: String
    var nickname: String?
    var image: Data?
    var apiUrl: URL?
    
    init(withId id:Int, withName name:String,withImageUrl imageUrl:String, withApiUrl apiUrl: URL? ) {
        self.localId = nil
        self.id = id
        self.name = name
        self.nickname = nil
        self.apiUrl = apiUrl
        fetchImage(from: imageUrl)
        
    }
    
    init(withLocalId localId:Int, withId id:Int, withName name:String,withNickname nickname:String, withImageUrl imageUrl:String, withApiUrl apiUrl: URL? ) {
        self.localId = localId
        self.id = id
        self.name = name
        self.nickname = nickname
        self.apiUrl = apiUrl
        fetchImage(from: imageUrl)
    }
    
    private func fetchImage(from imageURLString:String) {
      
        let imageUrl = URL(string: imageURLString)
        if let url = imageUrl{
            DispatchQueue.global(qos: .userInitiated).async {
                let urlContents = try? Data(contentsOf: url)
                if let imageDate = urlContents  {
                    self.image = imageDate
                }
            }
        }
    }
  
}
