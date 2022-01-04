//
//  UserDefaultHelper.swift
//  uberbiz
//
//  Created by Filbert Hartawan on 26/01/21.
//

import Foundation

class UserDefaultHelper{
    static let shared = UserDefaultHelper()
    
    func setupIsOnBoardLoaded(){
        let userDefaults = UserDefaults.standard
        userDefaults.set(true, forKey: "is_first_login")
        userDefaults.synchronize()
    }
    
    func setupQBUser(userId:String){
        let userDefaults = UserDefaults.standard
        userDefaults.set(userId, forKey: "QB_userId")
        userDefaults.synchronize()
    }
    
    func updateSearchHistory(searchQuery:String){
        var searchHistoriesTemp:[String] = []
        if let searchHistories = UserDefaults.standard.array(forKey: "search_histories") as? [String]{
            searchHistoriesTemp = searchHistories
        }
        
        if searchHistoriesTemp.count == 3{
            searchHistoriesTemp.remove(at: 0)
        }
        
        searchHistoriesTemp.append(searchQuery)
        
        let userDefaults = UserDefaults.standard
        userDefaults.set(searchHistoriesTemp, forKey: "search_histories")
        userDefaults.synchronize()
    }
    
    func getIsOnBoardLoaded()->Bool{
        return UserDefaults.standard.bool(forKey: "is_first_login")
    }
    
    func getQBUser()->String?{
        if let QBUserId = UserDefaults.standard.string(forKey: "QB_userId"){
           return QBUserId
        }
        return nil
    }
    
    func setupUser(data:Data){
        let userDefaults = UserDefaults.standard
        userDefaults.set(data, forKey: "current_user")
        userDefaults.synchronize()
    }
    
    func getUser()->User?{
        if let data = UserDefaults.standard.data(forKey: "current_user"){
            do {
                return try JSONDecoder().decode(User.self, from: data)
            }catch(let error){
                print(error)
                return nil
            }
        }
        return nil
    }
    
    func getSearchHistories()->[String]{
        if let searchHistories = UserDefaults.standard.array(forKey: "search_histories") as? [String]{
            return searchHistories
        }
        return []
    }
    
    func clearSearchHistory(){
        let userDefaults = UserDefaults.standard
        userDefaults.removeObject(forKey: "search_histories")
        userDefaults.synchronize()
    }
    
    func deleteUser(){
        let userDefaults = UserDefaults.standard
        userDefaults.removeObject(forKey: "current_user")
        userDefaults.synchronize()
    }
}
