//
//  CaughtPokemonViewController.swift
//  Ios-Pokedex
//
//  Created by Muuk Van der Sande on 04/04/2019.
//  Copyright © 2019 Muuk Van der Sande. All rights reserved.
//

import UIKit

class CaughtPokemonViewController: UIViewController, UITextFieldDelegate {

    var pokemon: Pokemon?
    var cplvc: CaughtPokemonListTableViewController?
    
    @IBOutlet weak var pokemonImage: UIImageView!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var nicknameTextField: UITextField!
    
    @IBOutlet weak var weightDataLabel: UILabel!
    
    @IBOutlet weak var heightDataLabel: UILabel!
    
    @IBOutlet weak var typeDataLabel: UILabel!
    
    @IBOutlet weak var genusDataLabel: UILabel!
    
    @IBOutlet weak var flavorTextDataLabel: UILabel!
    
    @IBAction func releasePokemon(_ sender: UIButton) {
        if let pokemon = self.pokemon {
            
            DispatchQueue.main.async {
                Toast.show(message: "\(pokemon.nickname ?? pokemon.name ?? "") released", controller: self)
            }
            
            cplvc?.releasePokemon(pokemon)
//           navigationController?.popViewController(animated: true)
        }
    }

    @IBAction func saveChanges(_ sender: UIButton) {
        if let pokemon = self.pokemon {
            pokemon.nickname = nicknameTextField.text
            cplvc?.pokemonChanged()
            DispatchQueue.main.async {
                Toast.show(message: "\(pokemon.name ?? "") got the nickname \(pokemon.nickname ?? "")", controller: self)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        nicknameTextField.delegate = self
        
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
            nicknameTextField.text = p.nickname
        }
    }
    
    // functions to close keybloard on return and toutch of keyboard
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    
    
    
}
