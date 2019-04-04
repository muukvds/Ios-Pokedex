//
//  PokemonListTableViewController.swift
//  Ios-Pokedex
//
//  Created by Muuk Van der Sande on 02/04/2019.
//  Copyright © 2019 Muuk Van der Sande. All rights reserved.
//

import UIKit

class PokemonListTableViewController: UITableViewController, UISplitViewControllerDelegate {

    var pokemons = [Pokemon]()
    
    var offset = 0
    var limit = 150
    var steps = 150
    
    var isFetshingPokemon = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
  
        fetchPokemons()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        splitViewController?.delegate = self
    }
    
    
    func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController: UIViewController, onto primaryViewController: UIViewController) -> Bool {
        return true
    }
    
    
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
            return pokemons.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "pokemonCell", for: indexPath)
        
            cell.textLabel?.text = pokemons[indexPath.row].name
            if let imageData = pokemons[indexPath.row].image {
                cell.imageView?.image = UIImage(data: imageData)
            }
            return cell
    }
    
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let lastElement = pokemons.count - 1
        if indexPath.row == lastElement {
            if !isFetshingPokemon {
                fetchPokemons()
            }
        }
    }
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "PokemonSelector" {
            if let pokemonIndex = tableView.indexPathForSelectedRow{
                if let pvc = segue.destination as? PokemonViewController
                {
                    pvc.pokemon = pokemons[pokemonIndex.row]
                }
            }
        }
    }
    
    
    
    
    
    
    private func fetchPokemons() {
        isFetshingPokemon = true
        tableView.reloadSections(IndexSet(integer: 1), with: .none)
        DispatchQueue.global(qos: .userInitiated).async {
            var pokemonURls = [URL?]()
            
            let url = URL(string: "https://pokeapi.co/api/v2/pokemon?offset=\(self.offset)&limit=\(self.limit)")
            
            URLSession.shared.dataTask(with: url!, completionHandler: {(data, response, error) in
                guard let data = data, error == nil else {print(error!); return}
                
                let json = try? JSONSerialization.jsonObject(with: data, options: [])
                
                if let dictionary = json as? [String: Any] {
                    if let results = dictionary["results"] as? [Any] {
                        for pokemons in results {
                            if let pokemon = pokemons as? [String:Any]{
                                if let pokemonUrl = pokemon["url"] as? String {
                                    let nurl = URL(string: pokemonUrl)
                                    pokemonURls.append(nurl)
                                }
                            }
                        }
                    }
                }
                
                for pokemonUrl in pokemonURls {
                    
                    URLSession.shared.dataTask(with: pokemonUrl!, completionHandler: {(data, response, error) in
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
                                            self.pokemons.append(Pokemon(withId: id, withName: name, withImageUrl: imageUrl,withApiUrl: pokemonUrl))
                                            
                                            DispatchQueue.main.async {
                                                self.tableView.reloadData()
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        
                    }).resume()
                }
                self.isFetshingPokemon = false
                self.offset += self.steps
                
            }).resume()
        }
    }

    

}
