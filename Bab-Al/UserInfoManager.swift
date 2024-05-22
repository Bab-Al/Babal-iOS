//
//  UserInfoManager.swift
//  Bab-Al
//
//  Created by 정세린 on 4/28/24.
//

import Foundation
import Alamofire

class UserInfoManager {
    static let shared = UserInfoManager()
    
    private let baseURL = "http://hongik-babal.ap-northeast-2.elasticbeanstalk.com/"
    private var authToken: String?

    
    private init() {
    }
    
    var token: String?
    
    var userInfo: UserInfo = UserInfo()
    
    func setUserName(_ name: String) {
        userInfo.name = name
    }

    func setUserEmail(_ email: String) {
        userInfo.email = email
    }

    func setUserPassword(_ password: String) {
        userInfo.password = password
    }
    
    func setUserAge(_ age: Int) {
        userInfo.age = age
    }

    func setUserGender(_ gender: String) {
        userInfo.gender = gender
    }

    func setUserHeight(_ height: Int) {
        userInfo.height = height
    }

    func setUserWeight(_ weight: Int) {
        userInfo.weight = weight
    }

    func setUserActivityLevel(_ activity: Int) {
        userInfo.activity = activity
    }

    func setUserFoodCategory(_ foodCategory: [String]) {
        userInfo.foodCategory = foodCategory
    }
    
    func getUserInfo() -> UserInfo? {
        return userInfo
    }
    
    // Function to send user information to the backend
    func sendUserInfoToServer(userInfo: UserInfo, completion: @escaping (Result<String, Error>) -> Void) {
        let parameters: [String: Any] = [
            "name": "\(userInfo.name)",
            "email": "\(userInfo.email)",
            "password": "\(userInfo.password)",
            "age": userInfo.age,
            "gender": "\(userInfo.gender)",
            "height": userInfo.height,
            "weight": userInfo.weight,
            "activity": userInfo.activity,
            "foodCategory": userInfo.foodCategory
        ]
        print(parameters)
            
        let url = baseURL + "user/signup"
            
        AF.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: ["Content-Type":"application/json", "Accept":"application/json"])
            .validate(statusCode: 200..<300)
            .responseDecodable(of: UserResponse.self) { response in
                    switch response.result {
                    case .success(let userResponse):
                        completion(.success(userResponse.message))
                    case .failure(let error):
                        completion(.failure(error))
                    }
                }
    }
    
    func login(email: String, password: String, completion: @escaping (Result<String, LoginError>) -> Void) {
        let loginURL = baseURL + "user/login"
        
        let parameters: [String: Any] = [
            "email": email,
            "password": password
        ]
        
        AF.request(loginURL, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: ["Content-Type":"application/json", "Accept":"application/json"])
            .validate(statusCode: 200..<300)
            .responseDecodable(of: LoginResponse.self) { response in
                switch response.result {
                case .success(let loginResponse):
                    if let token = loginResponse.result?.token {
                        self.token = token
                        completion(.success(loginResponse.result!.token))
                    }
                case .failure(let error):
                    if let data = response.data,
                       let loginResponse = try? JSONDecoder().decode(LoginResponse.self, from: data) {
                        switch loginResponse.code {
                        case "MEMBER4001":
                            completion(.failure(.member4001(message: loginResponse.message)))
                        case "MEMBER4004":
                            completion(.failure(.member4004(message: loginResponse.message)))
                        default:
                            completion(.failure(.unknownError(message: loginResponse.message)))
                        }
                    } else {
                        completion(.failure(.unknownError(message: error.localizedDescription)))
                    }
                }
            }
    }
    
    func logout() {
        clearAuthToken()
    }
    
    // Function to get the stored JWT token
    func getAuthToken() -> String? {
        return authToken
    }
    
    // Function to clear the stored JWT token (e.g., on logout)
    func clearAuthToken() {
        authToken = nil
    }
    
    func printUserInfo() {
        print("Name: \(userInfo.name)")
        print("Email: \(userInfo.email)")
        print("Password: \(userInfo.password)")
        print("Age: \(userInfo.age)")
        print("Gender: \(userInfo.gender)")
        print("Height: \(userInfo.height)")
        print("Weight: \(userInfo.weight)")
        print("Activity: \(userInfo.activity)")
        print("Food Category: \(userInfo.foodCategory)")
    }

}


struct UserInfo {
    var name: String = ""
    var email: String = ""
    var password: String = ""
    var age: Int = 0
    var gender: String = ""
    var height: Int = 0
    var weight: Int = 0
    var activity: Int = 0
    var foodCategory: [String] = []
}

struct UserResponse: Codable {
    let isSuccess: Bool
    let code: String
    let message: String
    let result: String
}

enum LoginError: Error {
    case success(token: String)
    case member4001(message: String)
    case member4004(message: String)
    case unknownError(message: String)
}

struct LoginResponse: Codable {
    let isSuccess: Bool
    let code: String
    let message: String
    let result: TokenResult?
}

struct TokenResult: Codable {
    let token: String
}
