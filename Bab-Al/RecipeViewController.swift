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
    @IBOutlet weak var wizardButton: UIButton!
    
    var filteredResults: [String] = []
    var selectedWords: [String] = [] {
        didSet {
            wizardButton.isHidden = selectedWords.isEmpty
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.hidesBackButton = true
        
        searchBar.delegate = self
        tableView.dataSource = self
        tableView.delegate = self
        
        wizardButton.isHidden = true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardUp), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDown), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardUp(notification:NSNotification) {
        if let keyboardFrame:NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
       
            UIView.animate(
                withDuration: 0.3
                , animations: {
                    self.view.transform = CGAffineTransform(translationX: 0, y: 0)
                }
            )
        }
    }
    
    @objc func keyboardDown() {
        self.view.transform = .identity
    }
    

    @IBAction func searchButtonTapped(_ sender: UIButton) {
        guard let query = searchBar.text, !query.isEmpty else { return }
        fetchIngredients(for: query)
    }
    
        
    func fetchIngredients(for query: String) {
        
        let url = "http://hongik-babal.ap-northeast-2.elasticbeanstalk.com/recipe/ingredients"
        
        // Retrieve the token from UserInfoManager
        let token = UserInfoManager.shared.token!
        print("Token sending: \(token)")
        
        let parameters: [String: String] = ["alpha": query]
                
        AF.request(url, method: .get, parameters: parameters, headers: ["Authorization": "Bearer \(token)", "accept":"application/json"])
            .validate(statusCode: 200..<300) // Validates the response
            .responseDecodable(of: ResponseData.self) { response in
                switch response.result {
                case .success(let data):
                    if let filtered = data.result {
//                        self.updateProfileData(profile: profile)
                        self.filteredResults = filtered.ingredients
                        self.tableView.reloadData()
                        print("Received decoded data: \(data)")
                    } else {
                        print("Search data is missing from the response.")
                    }
                    
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
    
    struct ResponseData: Decodable {
        let result: IngredientsResponse?
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredResults.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = filteredResults[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedWord = filteredResults[indexPath.row]
//        searchBar.text = selectedWord
        addSelectedWordButton(selectedWord)
    }
    
    func addSelectedWordButton(_ word: String) {
        // Check if the word is already selected
        guard !selectedWords.contains(word) else { return }
        
        // Add to selected words list
        selectedWords.append(word)
        
        // Create a button for the selected word
        let button = UIButton(type: .system)
        button.setTitle(word, for: .normal)
        button.backgroundColor = UIColor(red: 253/255, green: 177/255, blue: 55/255, alpha: 1.0)
        button.layer.cornerRadius = 8
        button.clipsToBounds = true
        button.titleLabel?.font = UIFont.systemFont(ofSize: 13)
        button.titleLabel?.textAlignment = .center
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(removeSelectedWord), for: .touchUpInside)
        
        // Set square constraints for the button
//        button.translatesAutoresizingMaskIntoConstraints = false
//        button.widthAnchor.constraint(equalToConstant: 80).isActive = true
//        button.heightAnchor.constraint(equalToConstant: 80).isActive = true
        
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
    
    
    
    @IBAction func wizardButtonTapped(_ sender: UIButton) {
        // Prepare the selected ingredients
        guard !selectedWords.isEmpty else {
            print("No ingredients selected")
            return
        }
        
        // Define the POST endpoint and parameters
        let url = "http://hongik-babal.ap-northeast-2.elasticbeanstalk.com/recipe/recommendation"
        
        // Retrieve the token from UserInfoManager
        let token = UserInfoManager.shared.token!
        print("Token sending: \(token)")
        
        let parameters: [String: Any] = ["ingredients": selectedWords]
        print("selectedWords: \(selectedWords)")
        print("parameters: \(parameters)")
        
        // Send POST request
        AF.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: ["Authorization": "Bearer \(token)", "Content-Type":"application/json", "accept":"application/json"])
            .validate(statusCode: 200..<300) // Validates the response
            .responseDecodable(of: RecipeResponseData.self) { response in
                switch response.result {
                case .success(let data):
                    print("Response received: \(data)")
                    
                    // Navigate to the Response View Controller
                    self.showRecipeResultViewController(with: data.result)
                case .failure(let error):
                    print("Error sending request: \(error)")
                }
            }
    }
    
    func showRecipeResultViewController(with recipes:[Recipe]) {
        // Instantiate the new view controller
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let responseVC = storyboard.instantiateViewController(withIdentifier: "RecipeResultViewController") as? RecipeResultViewController else { return }
        
        // Pass the response data
        responseVC.recipes = recipes

        // Navigate to the new view controller
        navigationController?.pushViewController(responseVC, animated: true)
    }
    

}


// Define the response model
struct RecipeResponseData: Decodable {
    let result: [Recipe]  // Adjust this type to match your server's response
}

struct Recipe: Decodable {
    let name: String
    let minutes: Int
    let calories: Float
    let carbohydrate: Float
    let protein: Float
    let fat: Float
    let n_steps: Int
    let steps: [String]
    let n_ingredients: Int
    let ingredients: [String]
}
