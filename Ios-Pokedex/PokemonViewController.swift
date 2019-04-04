//
//  PokemonViewController.swift
//  Ios-Pokedex
//
//  Created by Muuk Van der Sande on 04/04/2019.
//  Copyright © 2019 Muuk Van der Sande. All rights reserved.
//

import UIKit

class PokemonViewController: UIViewController {

    var pokemon: Pokemon?
    
    
    @IBOutlet weak var nameLabel: UILabel!
    
    
    
    
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let p = pokemon {
            nameLabel.text = p.name
        }
        if pokemon != nil {
             loadPokemon()
        }
       
        // Do any additional setup after loading the view.
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    private func dataDidLoad(){
        if let p = pokemon {
            nameLabel.text = p.name
        }
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    

    private func loadPokemon(){
        
        URLSession.shared.dataTask(with: (pokemon?.apiUrl!)!, completionHandler: {(data, response, error) in
            guard let data = data, error == nil else {print(error!); return}
            
            let json = try? JSONSerialization.jsonObject(with: data, options: [])
            
            if let dictionary = json as? [String: Any] {
                
                let id:Int
                let name:String
                let imageUrl:String
                
                if let jsonId = dictionary["id"] as? Int {
                    id = jsonId
                    if let jsonName = dictionary["name"] as? String {
                        name = jsonName
                        if let sprites = dictionary["sprites"] as? [String:Any] {
                            if let jsonImageUrl = sprites["front_default"] as? String {
                                imageUrl = jsonImageUrl
                                DispatchQueue.main.async {
                                  self.dataDidLoad()
                                }
                            }
                        }
                    }
                }
            }
            
        }).resume()
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
