//
//  ViewController.swift
//  Project7
//
//  Created by Kaan on 26.07.2022.
//

import UIKit

class ViewController: UITableViewController {
    var petitions = [Petition]()
    var filteredPetitions = [Petition]()
    var urlString : String?
    override func viewDidLoad() {
        super.viewDidLoad()
        performSelector(inBackground: #selector(fetchJSON), with: nil)
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .bookmarks, target: self, action: #selector(showAlert))
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(search))
        
    }
    
    
    @objc func fetchJSON ()    {
        performSelector(onMainThread: #selector(urlSwitcher), with: nil, waitUntilDone: true)
        guard let urlString = urlString else {
            return
        }

        if let url = URL(string: urlString) {
            if let data = try? Data(contentsOf: url) {
                self.parse(json: data)
                return
            }
            
            self.performSelector(onMainThread: #selector(self.showError), with: nil, waitUntilDone: false)
        }
        
        
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        filteredPetitions.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let petition = filteredPetitions[indexPath.row]
        cell.textLabel?.text = petition.title
        cell.detailTextLabel?.text = petition.body
        return cell
    }
    
    func parse(json: Data) {
        let decoder = JSONDecoder()
        
        if let jsonPetitions = try? decoder.decode(Petitions.self, from: json) {
            petitions = jsonPetitions.results
            filteredPetitions = petitions
            DispatchQueue.main.async {
                self.tableView.performSelector(onMainThread: #selector(UITableView.reloadData), with: nil, waitUntilDone: false)
            }
        }  else {
            performSelector(onMainThread: #selector(showError), with: nil, waitUntilDone: false)
        }
        
        
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = DetailViewController()
        vc.detailItem = filteredPetitions[indexPath.row]
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func showError() {
        
        let ac = UIAlertController(title: "Loading error", message: "There was a problem loading the feed; please check your connection and try again.", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        self.present(ac, animated: true)
        
        
    }
    @objc func showAlert(){
        let ac2 = UIAlertController(title: "Do you want to learn what is the source?", message: "From White US man..!", preferredStyle: .alert)
        ac2.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac2, animated: true)
        
    }
    
    @objc func search(){
        let ac = UIAlertController(title: "What do u want to search?", message: nil, preferredStyle: .alert)
        ac.addTextField()
        let searchAction = UIAlertAction(title: "Search", style: .default){[weak self] _ in
            guard let text = ac.textFields?.first?.text else{ return }
            self?.filterPetitions(text)
            
        }
        ac.addAction(searchAction)
        
        present(ac, animated: true)
    }
    func filterPetitions(_ text: String) {
        let text = text.trimmingCharacters(in: CharacterSet(charactersIn: " "))
        guard (text.count != 0) else {
            filteredPetitions = petitions
            tableView.reloadData()
            return}
        filteredPetitions = petitions.filter({ pet in
            
            return pet.title.lowercased().contains(text.lowercased()) || pet.body.lowercased().contains(text.lowercased())
        })
        
        tableView.reloadData()
    }
    
    @objc func urlSwitcher ()  {
        if navigationController?.tabBarItem.tag == 0 {
            self.urlString = "https://www.hackingwithswift.com/samples/petitions-1.json"
            
        } else {
            self.urlString = "https://www.hackingwithswift.com/samples/petitions-2.json"
        }
    }
}
