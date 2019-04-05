//
//  PokemonCaughtListTableViewController.swift
//  Ios-Pokedex
//
//  Created by Muuk Van der Sande on 04/04/2019.
//  Copyright © 2019 Muuk Van der Sande. All rights reserved.
//

import UIKit

class CaughtPokemonListTableViewController: UITableViewController, UISplitViewControllerDelegate {

    var pokemons: [Pokemon]?
    {
        didSet{
            tableView.reloadData()
        }
    }
    
    var jsonVersion = UserDefaults.standard.integer(forKey: "jsonVersion")

    
    @IBAction func refreshTabel(_ sender: UIBarButtonItem) {
        tableView.reloadData()
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        pokemons = getCoughtPokemons()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        splitViewController?.delegate = self
    }

    // MARK: - Table view data source
    
    
    func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController: UIViewController, onto primaryViewController: UIViewController) -> Bool {
        return true
    }
    

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return pokemons?.count ?? 0
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CaughtPokemonCell", for: indexPath)
        if pokemons != nil
        {
            cell.textLabel?.text = pokemons?[indexPath.row].name
            cell.detailTextLabel?.text = pokemons?[indexPath.row].nickname
            if let imageData = pokemons?[indexPath.row].imageFront {
                cell.imageView?.image = UIImage(data: imageData)
            }
        }
        // Configure the cell...

        return cell
    }
 
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "CaughtPokemonSelector" {
            if let pokemonIndex = tableView.indexPathForSelectedRow{
                if let cpvc = segue.destination as? CaughtPokemonViewController
                {
                    cpvc.pokemon = pokemons?[pokemonIndex.row]
                }
            }
        }
    }
    
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if jsonVersion < UserDefaults.standard.integer(forKey: "jsonVersion") {
            pokemons = getCoughtPokemons()
            jsonVersion = UserDefaults.standard.integer(forKey: "jsonVersion")
        }
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            // Delete the row from the data source
            pokemons?.remove(at: indexPath.row)
            saveCaughtPokemons(of: pokemons!)
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
                UserDefaults.standard.set((( UserDefaults.standard.integer(forKey: "jsonVersion")) + 1), forKey: "jsonVersion")
                
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
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
