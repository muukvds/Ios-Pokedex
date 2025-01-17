//
//  Pokemon.swift
//  Ios-Pokedex
//
//  Created by Muuk Van der Sande on 02/04/2019.
//  Copyright © 2019 Muuk Van der Sande. All rights reserved.
//

import Foundation

//codable to cast directly from json data to pokemon ore pokemon array
class Pokemon: Codable {
    var localId: String?
    var id: Int
    var name: String?
    var nickname: String?
    var imageFront: Data?
    var imageBack: Data?
    var imageUrlFront: String?
    var imageUrlBack: String?
    var height: Double?
    var weight: Double?
    var types: [String]
    var genera: String?
    var flavorText: String?
    var evolvesTo: Pokemon?
    var evolvedFrom: Pokemon?
    
    let apiUrl: URL
   
    init(withId id: Int, withName name: String, withImageUrl imageUrl: String, withApiUrl apiUrl: URL) {
        self.id = id
        self.name = name
        self.apiUrl = apiUrl
        self.types = [String]()
        fetchImage(from: imageUrl)
        getPokemonDetails()
    }
    
    init(withLocalId localId:String, withId id:Int, withName name:String,withNickname nickname:String, withImageUrl imageUrl:String, withApiUrl apiUrl: URL ) {
        self.localId = localId
        self.id = id
        self.name = name
        self.nickname = nickname
        self.apiUrl = apiUrl
        self.types = [String]()
        fetchImage(from: imageUrl)
        getPokemonDetails()
    }
    
    private func getPokemonDetails()
    {
       fetchPokemonDetails()
    }
    
    private func fetchPokemonDetails() {

        URLSession.shared.dataTask(with: apiUrl, completionHandler: {(data, response, error) in
            
            guard let data = data, error == nil else {print(error!); return}
            
            let json = try? JSONSerialization.jsonObject(with: data, options: [])
            
            if let dictionary = json as? [String: Any] {

//                var evolvesTo: Pokemon?
//                var evolvedFrom: Pokemon?
                
                let numberOfPlaces = 2.0
                let multiplier = pow(10.0, numberOfPlaces)
             
                if let id = dictionary["id"] as? Int {
                     self.id = id
                }
                self.name = dictionary["name"] as? String
                self.height = round((((dictionary["height"] as? Double) ?? 0) / 10) * multiplier) / multiplier
                self.weight = round((((dictionary["weight"] as? Double) ?? 0) / 10) * multiplier) / multiplier
                
                if let sprites = dictionary["sprites"] as? [String:Any] {
                    if let jsonImageUrl = sprites["front_default"] as? String {
                        self.imageUrlFront = jsonImageUrl
                        self.fetchImage(from: jsonImageUrl)
                    }
                    
                    if let jsonImageUrl = sprites["back_default"] as? String {
                        self.imageUrlBack = jsonImageUrl
                    }
                }
                
                if let jsonTypes = dictionary["types"] as? [Any] {
                    for jsonType in jsonTypes {
                        if let typeEntry = jsonType as? [String:Any] {
                            if let type = typeEntry["type"] as? [String:Any] {
                                if let typeName = type["name"] as? String {
                                    self.types.append(typeName)
                                }
                            }
                        }
                    }
                }

                if let species = dictionary["species"] as? [String:Any] {
                    if let speciesUrl = species["url"] as? String {
                        if let apiUrl = URL(string: speciesUrl) {
                     
                            URLSession.shared.dataTask(with: apiUrl, completionHandler: {(data, response, error) in
                                
                                guard let data = data, error == nil else {print(error!); return}
                                
                                let json = try? JSONSerialization.jsonObject(with: data, options: [])
                                
                                if let dictionary = json as? [String: Any] {
                                    
                                    if let flavorTextEntries = dictionary["flavor_text_entries"] as? [Any] {
                                        if flavorTextEntries.count > 21 {
                                            if let flavorTextEntry = flavorTextEntries[1] as? [String: Any] {
                                                self.flavorText = String((flavorTextEntry["flavor_text"] as? String)?.filter { !"\n".contains($0) } ?? "")
                                            }
                                        }
                                    }
                                    
                                    if let generaEntries = dictionary["genera"] as? [Any] {
                                        if let generaEntry = generaEntries[2] as? [String: Any] {
                                            self.genera = generaEntry["genus"] as? String
                                        }
                                    }
                                }
                            }).resume()
                        }
                    }
                }
            }
        }).resume()
    }
        
    
    private func fetchImage(from imageURLString:String) {
      
        let imageUrl = URL(string: imageURLString)
        if let url = imageUrl{
            DispatchQueue.global(qos: .userInitiated).async {
                let urlContents = try? Data(contentsOf: url)
                if let imageDate = urlContents  {
                    self.imageFront = imageDate
                }
            }
        }
    }
  
}
