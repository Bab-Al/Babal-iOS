//
//  MealRecordingViewController.swift
//  Bab-Al
//
//  Created by 정세린 on 8/23/24.
//

import UIKit
import Alamofire
import Foundation

class MealRecordingViewController: UIViewController {
    
    var mealType: String?
    
    @IBOutlet weak var mealtypeLabel: UILabel!
    @IBOutlet weak var foodnameTextField: UITextField!
    @IBOutlet weak var carbohydrateTextField: UITextField!
    @IBOutlet weak var proteinTextField: UITextField!
    @IBOutlet weak var fatTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mealtypeLabel.text = mealType
    }
    
    @IBAction func uploadButton(_ sender: UIButton) {
        guard let mealtime = mealtypeLabel.text,
              let carbohydrateText = carbohydrateTextField.text, let carbohydrate = Int(carbohydrateText),
              let proteinText = proteinTextField.text, let protein = Int(proteinText),
              let fatText = fatTextField.text, let fat = Int(fatText),
              let foodName = foodnameTextField.text else {
            print("Error: Invalid input")
            return
        }
        
        // Create the parameters dictionary (JSON)
        let parameters: [String: Any] = [
            "mealtime": mealtime,
            "carbohydrate": carbohydrate,
            "protein": protein,
            "fat": fat,
            "foodName": foodName
        ]
        
        // Define the URL for the POST request
        let url = "http://hongik-babal.ap-northeast-2.elasticbeanstalk.com/main/history"
        
        let token = UserInfoManager.shared.token!
        print("Token sending: \(token)")
        
        // Make the POST request using Alamofire
        AF.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: ["Authorization": "Bearer \(token)", "accept":"application/json"])
            .responseDecodable(of: MealResponse.self) { response in
                switch response.result {
                case .success(let mealResponse):
                    // Successfully decoded the response
                    print("Success: \(mealResponse.success)")
                    print("Message: \(mealResponse.message)")
                    // Handle the successful response here
                    
                case .failure(let error):
                    print("Error: \(error)")
                    // Handle the error here
                }
            }
    }
}

struct MealResponse: Decodable {
    let success: Bool
    let message: String
}
