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
    
    @IBOutlet weak var catchButton: UIButton!
    
    @IBOutlet weak var pokemonImage: UIImageView!
    
    @IBOutlet weak var weightDataLabel: UILabel!
    
    @IBOutlet weak var heightDataLabel: UILabel!
    
    @IBOutlet weak var typeDataLabel: UILabel!
    
    @IBOutlet weak var genusDataLabel: UILabel!
    
    @IBOutlet weak var flavorTextDataLabel: UILabel!
    
    
    
    
    
    @IBAction func catchPokemon(_ sender: UIButton) {
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
        
            var pokemons = self!.getCoughtPokemons() ?? [Pokemon]()
            
            if let p = self!.pokemon {
                pokemons.append(p)
                self!.saveCaughtPokemons(of: pokemons)
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now()) {
                Toast.show(message: "\(self!.pokemon?.name ?? "") catched", controller: self!)
            }
        }
    }
    
 
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let p = pokemon {
            if let image = p.imageFront {
                 pokemonImage.image = UIImage(data: image)
            }
            nameLabel.text = p.name?.uppercased()
            var weight = String(format:"%.1f", p.weight ?? 0.0)
            weight += "kg"
            weightDataLabel.text = weight
            var height = String(format:"%.1f",p.height ?? 0.0)
            height += "m"
            heightDataLabel.text = height
            var typeString = ""
            var first = true
            for type in p.types {
                if first {
                    typeString = type
                    first = false
                }
                else {
                    typeString += "/\(type)"
                }
            }
            typeDataLabel.text = typeString.uppercased()
            genusDataLabel.text = p.genera?.uppercased()
            flavorTextDataLabel.text = p.flavorText
        }
    }
    
    
    
    private func saveCaughtPokemons(of pokemons:[Pokemon])
    {
        if let JsonDataPokemons = arrayToJSONData(from: pokemons) {
            
            let itemName = "pokemonsJson"
            do {
                let directory = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
                let fileURL = directory.appendingPathComponent(itemName)
                
                try JsonDataPokemons.write(to: fileURL, options: .atomic)
                
                UserDefaults.standard.set(fileURL, forKey: "pathForJSON")
                print(UserDefaults.standard.integer(forKey: "jsonVersion"))
                UserDefaults.standard.set(((UserDefaults.standard.integer(forKey: "jsonVersion")) + 1), forKey: "jsonVersion")
                print(UserDefaults.standard.integer(forKey: "jsonVersion"))
            } catch {
                print(error)
            }
        }
    }
    
    private func arrayToJSONData(from array: [Pokemon]) -> Data? {
        
        do {
            let jsonEncoder = JSONEncoder()
            let jsonData = try jsonEncoder.encode(array)
            
            return jsonData
        }
        catch {
            print(error)
        }
        return nil
    }
    
    private func JSONToArray(from JSONData: Data) -> [Pokemon]? {
        
        let decoder = JSONDecoder()
        do {
            if let array = try decoder.decode([Pokemon]?.self, from: JSONData) {
                return array
            }
        }
        catch {
            print(error)
        }
        return nil
    }
    
    private func getCoughtPokemons() -> [Pokemon]? {
        
        let fileUrl = UserDefaults.standard.url(forKey: "pathForJSON")
        do {
            if (fileUrl != nil) {
                let jsonPokemonData = try Data(contentsOf: fileUrl!, options: [])
                
                return JSONToArray(from: jsonPokemonData)
            }
        } catch {
            print(error)
        }
        return nil
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
