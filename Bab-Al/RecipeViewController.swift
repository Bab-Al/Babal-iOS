//
//  RecipeViewController.swift
//  Bab-Al
//
//  Created by 정세린 on 11/9/24.
//

import UIKit
import Alamofire

class RecipeViewController: UIViewController, UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var selectedWordsStackView: UIStackView!
    @IBOutlet weak var searchButton: UIButton!
    
//    var allResults: [String] = []  // This will store the list of words fetched from your database
    var filteredResults: [String] = []
//    var currentRequest: DataRequest?
    var selectedWords: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.hidesBackButton = true
        
        searchBar.delegate = self
        tableView.dataSource = self
        tableView.delegate = self
    }
    

    @IBAction func searchButtonTapped(_ sender: UIButton) {
        guard let query = searchBar.text, !query.isEmpty else { return }
        fetchSuggestions(for: query)
    }
    
    
//    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
//        guard !searchText.isEmpty else {
//            filteredResults.removeAll()
//            tableView.reloadData()
//            return
//        }
//         
//        // Cancel any ongoing request to avoid overlapping
//        currentRequest?.cancel()
//        
//        // Debounce: Add a slight delay before making the request
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
//            // Call the API
//            self.fetchSuggestions(for: searchText)
//        }
//    }
        
    func fetchSuggestions(for query: String) {
        
        let url = "http://hongik-babal.ap-northeast-2.elasticbeanstalk.com/recipe/ingredients"
        
        // Retrieve the token from UserInfoManager
        let token = UserInfoManager.shared.token!
        print("Token sending: \(token)")
        
        let parameters: [String: String] = ["alpha": query]
                
        AF.request(url, method: .get, parameters: parameters, headers: ["Authorization": "Bearer \(token)", "accept":"application/json"])
            .validate(statusCode: 200..<300) // Validates the response
            .responseDecodable(of: IngredientsResponse.self) { response in
                switch response.result {
                case .success(let data):
                    self.filteredResults = data.ingredients
                    self.tableView.reloadData()
                case .failure(let error):
                    print("Error fetching suggestions: \(error.localizedDescription)")
                    self.filteredResults.removeAll()
                    self.tableView.reloadData()
                }
        }
    }
    
    
    struct IngredientsResponse: Decodable {
        let count: Int
        let ingredients: [String]
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredResults.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ResultCell", for: indexPath)
        cell.textLabel?.text = filteredResults[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedWord = filteredResults[indexPath.row]
        searchBar.text = selectedWord
        // Handle selection
    }
    
    func addSelectedWordButton(_ word: String) {
        // Check if the word is already selected
        guard !selectedWords.contains(word) else { return }
        
        // Add to selected words list
        selectedWords.append(word)
        
        // Create a button for the selected word
        let button = UIButton(type: .system)
        button.setTitle(word, for: .normal)
        button.backgroundColor = .systemGray5
        button.layer.cornerRadius = 5
        button.addTarget(self, action: #selector(removeSelectedWord), for: .touchUpInside)
        
        // Add the button to the stack view
        selectedWordsStackView.addArrangedSubview(button)
    }
        
    @objc func removeSelectedWord(_ sender: UIButton) {
        guard let word = sender.title(for: .normal) else { return }
        
        // Remove from selected words list
        if let index = selectedWords.firstIndex(of: word) {
            selectedWords.remove(at: index)
        }
        
        // Remove button from stack view
        sender.removeFromSuperview()
    }

}
