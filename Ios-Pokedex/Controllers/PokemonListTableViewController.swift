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
    var limit = 50
    var steps = 50
    var startFetshingBeforEnd = 15
    
    var isFetshingPokemon = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchPokemons()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        splitViewController?.delegate = self
    }
    
      //make sure to show table view in splitcontroller when app starts
    func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController: UIViewController, onto primaryViewController: UIViewController) -> Bool {
        return true
    }

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
            if let imageData = pokemons[indexPath.row].imageFront {
                cell.imageView?.image = UIImage(data: imageData)
            }
            return cell
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let lastElement = pokemons.count - startFetshingBeforEnd
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
            var pokemonURls = [URL]()
            
           if let url = URL(string: "https://pokeapi.co/api/v2/pokemon?offset=\(self.offset)&limit=\(self.limit)") {
                URLSession.shared.dataTask(with: url, completionHandler: {(data, response, error) in
                    guard let data = data, error == nil else {print(error!); return}
                    
                    let json = try? JSONSerialization.jsonObject(with: data, options: [])
                    
                    if let dictionary = json as? [String: Any] {
                        if let results = dictionary["results"] as? [Any] {
                            for pokemons in results {
                                if let pokemon = pokemons as? [String:Any]{
                                    if let pokemonUrlString = pokemon["url"] as? String {
                                       if let pokemonURL = URL(string: pokemonUrlString) {
                                            pokemonURls.append(pokemonURL)
                                        }
                                    }
                                }
                            }
                        }
                    }
                    
                    // fetsh requierd pokemon data for table view (name and image) end reload table view
                    for pokemonUrl in pokemonURls {
                        URLSession.shared.dataTask(with: pokemonUrl, completionHandler: {(data, response, error) in
                            guard let data = data, error == nil else {print(error!); return}
                            
                            let json = try? JSONSerialization.jsonObject(with: data, options: [])
                            if let dictionary = json as? [String: Any] {
                                
                                if let id = dictionary["id"] as? Int {
                                    if let name = dictionary["name"] as? String {
                                        if let sprites = dictionary["sprites"] as? [String:Any] {
                                            if let imageUrl = sprites["front_default"] as? String {
                                                self.pokemons.append(Pokemon(withId: id, withName: name, withImageUrl: imageUrl,withApiUrl: pokemonUrl))
                                                DispatchQueue.main.async {
                                                    self.pokemons.sort {$0.id < $1.id}
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
}
