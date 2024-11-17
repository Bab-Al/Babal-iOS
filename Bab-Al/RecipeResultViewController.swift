//
//  RecipeResultViewController.swift
//  Bab-Al
//
//  Created by 정세린 on 11/14/24.
//

import UIKit

class RecipeResultViewController: UIViewController, UITableViewDataSource {

    @IBOutlet weak var recipeTableView: UITableView!
    var recipes: [Recipe] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        recipeTableView.dataSource = self
        
        // Enable dynamic height for table view cells
        recipeTableView.rowHeight = UITableView.automaticDimension
        recipeTableView.estimatedRowHeight = 100
        
        recipeTableView.reloadData()
    }
   
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recipes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RecipeCell", for: indexPath)
        let recipe = recipes[indexPath.row]
        
        cell.textLabel?.numberOfLines = 0 // Allow multiple lines
        cell.textLabel?.text = """
                Name: \(recipe.name)
                Time: \(recipe.minutes) mins
                Calories: \(recipe.calories)
                Carbohydrates: \(recipe.carbohydrate)g
                Protein: \(recipe.protein)g
                Fat: \(recipe.fat)g
                Steps (\(recipe.n_steps)):
                \(recipe.steps.joined(separator: ", "))
                Ingredients (\(recipe.n_ingredients)):
                \(recipe.ingredients.joined(separator: ", "))
                """
        return cell
    }
    
}
