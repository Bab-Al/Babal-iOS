//
//  RecipeResultViewController.swift
//  Bab-Al
//
//  Created by 정세린 on 11/14/24.
//

import UIKit

class RecipeResultViewController: UIViewController {

//    @IBOutlet weak var recipeTableView: UITableView!
    

    @IBOutlet weak var name1Label: UILabel!
    @IBOutlet weak var cooktime1Label: UILabel!
    @IBOutlet weak var calories1Label: UILabel!
    @IBOutlet weak var carbo1Label: UILabel!
    @IBOutlet weak var protein1Label: UILabel!
    @IBOutlet weak var fat1Label: UILabel!
    @IBOutlet weak var ingredients1TextView: UITextView!
    @IBOutlet weak var steps1TextView: UITextView!
    
    
    @IBOutlet weak var name2Label: UILabel!
    @IBOutlet weak var cooktime2Label: UILabel!
    @IBOutlet weak var calories2Label: UILabel!
    @IBOutlet weak var carbo2Label: UILabel!
    @IBOutlet weak var protein2Label: UILabel!
    @IBOutlet weak var fat2Label: UILabel!
    @IBOutlet weak var ingredients2TextView: UITextView!
    @IBOutlet weak var steps2TextView: UITextView!
    
    
    var recipe: [Recipe] = []
//    var recipe: Recipe?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        displayRecipe()
        

//        recipeTableView.dataSource = self
//        
//        // Enable dynamic height for table view cells
//        recipeTableView.rowHeight = UITableView.automaticDimension
//        recipeTableView.estimatedRowHeight = 100
//        
//        recipeTableView.reloadData()
    }
    
    func displayRecipe() {
        
        guard recipe.count >= 2 else { return }

        let recipe1 = recipe[0]
        name1Label.text = "\(recipe1.name)"
        cooktime1Label.text = "\(recipe1.minutes) mins"
        calories1Label.text = "\(recipe1.calories)kcal"
        carbo1Label.text = "\(recipe1.carbohydrate)g"
        protein1Label.text = "\(recipe1.protein)g"
        fat1Label.text = "\(recipe1.fat)g"
        steps1TextView.text = recipe1.steps.joined(separator: "\n")
        ingredients1TextView.text = recipe1.ingredients.joined(separator: ", ")
        
        let recipe2 = recipe[1]
        name2Label.text = "\(recipe2.name)"
        cooktime2Label.text = "\(recipe2.minutes) mins"
        calories2Label.text = "\(recipe2.calories)kcal"
        carbo2Label.text = "\(recipe2.carbohydrate)g"
        protein2Label.text = "\(recipe2.protein)g"
        carbo2Label.text = "\(recipe2.fat)g"
        steps2TextView.text = recipe2.steps.joined(separator: "\n")
        ingredients2TextView.text = recipe2.ingredients.joined(separator: ", ")
        
    }
    
   
    
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return recipes.count
//    }
//    
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "RecipeCell", for: indexPath)
//        let recipe = recipes[indexPath.row]
//        
//        cell.textLabel?.numberOfLines = 0 // Allow multiple lines
//        cell.textLabel?.text = """
//                Name: \(recipe.name)
//                Time: \(recipe.minutes) mins
//                Calories: \(recipe.calories)
//                Carbohydrates: \(recipe.carbohydrate)g
//                Protein: \(recipe.protein)g
//                Fat: \(recipe.fat)g
//                Steps (\(recipe.n_steps)):
//                \(recipe.steps.joined(separator: ", "))
//                Ingredients (\(recipe.n_ingredients)):
//                \(recipe.ingredients.joined(separator: ", "))
//                """
//        return cell
//    }
    
}
