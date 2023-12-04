//
//  GuessGameViewController.swift
//  Image-modification-toolkit
//
//  Created by Juncheng Yang on 11/7/23.
//

import UIKit

class GuessGameViewController: UIViewController {

    var categorieName: String?
    var index: Int?
    
    @IBAction func flower(_ sender: Any) {
        categorieName = "Disney Princess"
        index = 3
    }
    @IBAction func monuments(_ sender: Any) {
        categorieName = "Monuments"
        index = 2
    }
    
    @IBAction func dog(_ sender: Any) {
        categorieName = "Animals"
        index = 1
    }
    @IBAction func monaLisa(_ sender: Any) {
        categorieName = "Paintings"
        index = 0
    }

    var categories: [CategoryModel] = [
        CategoryModel(category: "Paintings", images: [
            ImageModel2(imageName: "starrynight", answer: "Starry Night", cimageName: "cstarrynight"),
            ImageModel2(imageName: "monalisa2", answer: "Mona Lisa", cimageName: "cmonalisa"),
            ImageModel2(imageName: "thescream", answer: "The Scream", cimageName: "cthescream"),
            ImageModel2(imageName: "girlwithapearlearring", answer: "Girl With a Pearl Earring", cimageName: "cgirlwithapearlearring")
        ]),
        CategoryModel(category: "Animals", images: [
            ImageModel2(imageName: "lion", answer: "Lion", cimageName: "clion"),
            ImageModel2(imageName: "elephant", answer: "Elephant", cimageName: "celephant"),
            ImageModel2(imageName: "penguin", answer: "Penguin", cimageName: "cpenguin"),
            ImageModel2(imageName: "giraffe", answer: "Giraffe", cimageName: "cgiraffe"),
            ImageModel2(imageName: "dog", answer: "Dog", cimageName: "cgiraffe"),
            ImageModel2(imageName: "monarch", answer: "Monarch Butterfly", cimageName: "cgiraffe"),
        ]),
        CategoryModel(category: "Monuments", images: [
            ImageModel2(imageName: "pyramid", answer: "Pyramids of Giza", cimageName: "cpyramidsofgiza"),
            ImageModel2(imageName: "liberty", answer: "Statue of Liberty", cimageName: "cstatueofliberty"),
            ImageModel2(imageName: "taj", answer: "Taj Mahal", cimageName: "ctajmahal"),
            ImageModel2(imageName: "eiffel", answer: "Eiffel Tower", cimageName: "ceiffeltower"),
        ]),
        CategoryModel(category: "Disney Princesses", images: [
            ImageModel2(imageName: "moana", answer: "Moana", cimageName: "celsa"),
            ImageModel2(imageName: "tiana", answer: "Tiana", cimageName: "celsa"),
            ImageModel2(imageName: "belle", answer: "Belle", cimageName: "cbelle"),
            ImageModel2(imageName: "cinder", answer: "Cinderella", cimageName: "ccinderella"),
            ImageModel2(imageName: "snow", answer: "Snow White", cimageName: "csnowwhite"),
        ]),
    ]


        
    
        override func viewDidLoad() {
            super.viewDidLoad()
        }

        override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            if segue.identifier == categorieName {
                if let destinationVC = segue.destination as? GuessIndividualViewController {
                    destinationVC.category = categories[index ?? 0]
                }
            }
        }
    }
