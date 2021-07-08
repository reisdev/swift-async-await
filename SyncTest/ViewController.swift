//
//  ViewController.swift
//  SyncTest
//
//  Created by ReisDev on 07/07/21.
//

import UIKit

struct Character: Codable {
    var name: String
    var gender: String
    var birthYear: String
    
    private enum CodingKeys: String,CodingKey {
        case name
        case gender
        case birthYear = "birth_year"
    }
}


class ViewController: UIViewController {
    
    // - MARK: Text Field
    @IBOutlet var textField: UITextField!;
    
    // - MARK: Buttons
    @IBOutlet var dispatchButton: UIButton!;
    @IBOutlet var asyncButton: UIButton!;
    
    // - MARK: Labels
    @IBOutlet var characterNameLabel: UILabel!;
    @IBOutlet var genderLabel: UILabel!;
    @IBOutlet var birthYearLabel: UILabel!;
    
    // - MARK: Actions
    @IBAction func dispatchButtonPressed(_ sender: UIButton) {
        let id = self.textField.text ?? "1"

        async {
            getDataWithDispatchQueue(id,onCompleted: { (people) in
                self.fillLabels(people)
            }, onError: { error in
                debugPrint(error)
            })
        }
    }
    
    @IBAction func asyncButtonPressed(_ sender: UIButton) {
        let id = self.textField.text ?? "1"

        async {
            do {
                let data = try await getDataWithAsyncAwait(id)
                self.fillLabels(data)
            } catch(let error) {
                debugPrint(error)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    private func fillLabels(_ data: Character){
        DispatchQueue.main.async {
            self.characterNameLabel.text = data.name;
            self.genderLabel.text = data.gender.capitalized
            self.birthYearLabel.text = data.birthYear
        }
    }
    
    // - MARK: Requests
    private func getDataWithDispatchQueue(_ id: String,onCompleted: @escaping(Character) -> (), onError: @escaping (Error) -> ()) {
        DispatchQueue.global().async {
            let request = URLRequest(url: URL(string: "https://swapi.dev/api/people/\(id)")!)
            
            URLSession.shared.dataTask(with: request) { (data,response,error) in
                if let message = error {
                    onError(message)
                }
                do {
                    let people = try JSONDecoder().decode(Character.self, from: data!)
                    onCompleted(people)
                } catch (let message){
                    onError(message)
                }
            }.resume()
        }
    }
    
    private func getDataWithAsyncAwait(_ id: String) async throws -> Character {
        
        let request = URLRequest(url: URL(string: "https://swapi.dev/api/people/\(id)")!)
        
        let (data,_) = try await URLSession.shared.data(for: request)
        let people = try JSONDecoder().decode(Character.self, from: data)
        
        return people
    }
}

