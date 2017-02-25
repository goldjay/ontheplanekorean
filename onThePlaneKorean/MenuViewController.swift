//
//  MenuViewController.swift
//  onThePlaneKorean
//
//  Created by Jay Steingold on 1/30/17.
//  Copyright © 2017 Goldjay. All rights reserved.
//

import UIKit
import CoreData

class MenuViewController: UIViewController, sendBack {
    @IBOutlet weak var level1: UIButton!
    @IBOutlet weak var level2: UIButton!
    @IBOutlet weak var level3: UIButton!
    @IBOutlet weak var level4: UIButton!
    @IBOutlet weak var practiceQuiz: UIButton!
    @IBOutlet weak var phraseBook: UIButton!
    
    var currentDeck: [[String]] = []
    var numLevels = 6
    
    //Load info from Core Data
    //var savedDecks = [deckData]()
    
    var decks = [NSManagedObject?]()
    
    //isCompleted
    //highScore
    
    override func viewDidAppear(_ animated: Bool) {
        /*
        addTopBorder(btn: level1, color: UIColor.customYellow)
        addTopBorder(btn: level2, color: UIColor.customRed)
        addTopBorder(btn: level3, color: UIColor.customBlue)
        addTopBorder(btn: level4, color: UIColor.customGreen)
        */
    }
    
    
    
    func addTopBorder(btn: UIButton, color: UIColor){
        let lineView = UIView(frame: CGRect(x: 0,y: 0,width: 343,height: 5)) //Magic number FIX
        lineView.backgroundColor = color
        btn.addSubview(lineView)
    }
    
    //Get data from Coredata
    override func viewWillAppear(_ animated: Bool) {
      
        addTopBorder(btn: level1, color: UIColor.customYellow)
        addTopBorder(btn: level2, color: UIColor.customRed)
        addTopBorder(btn: level3, color: UIColor.customBlue)
        addTopBorder(btn: level4, color: UIColor.customGreen)
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        //Managed object context
        let managedContext = appDelegate.persistentContainer.viewContext
 
        //DeleteAllData() //Clears core data for debug
 
        //Fetch from Core Data
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "DeckData")
        
        do {
            decks = try managedContext.fetch(fetchRequest)
            print("Loading data")
            print(decks)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        
        print(decks.count)
 
        
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func levelSelected(_ sender: UIButton) {
        
        let num = sender.tag
        
        //Move button to the side
        UIView.animate(withDuration: 0.75, delay: 0, options: UIViewAnimationOptions.curveEaseIn, animations: {
        
            var offset = 0;
            
            let btn : CGRect = sender.frame
            
            let originXbutton = btn.origin.x
            let originYbutton = btn.origin.y
            
            let originWidthbutton = btn.size.width
            let originHeightbutton = btn.size.height
            
            if originWidthbutton > 200 {
                offset = -300
                //sender.frame = frmPlay
                sender.setTitle("\(num)", for: .normal)
            }else{
                offset = 300
                sender.setTitle("LEVEL \(num) ", for: .normal)
            }
            
            sender.frame = CGRect(x: originXbutton, y: originYbutton, width: originWidthbutton+CGFloat(offset), height: originHeightbutton)
            
            }, completion: nil)
    }
    
    
    
    
    //Do something with the data returned
    func setSentData(highScore: Double){
        
        print("YOU GOT THIS SCORE!")
        print(highScore)
        
        //save to core data
        self.save(highScore: highScore)
    }
 
    
    //Saves to core data
    func save(highScore: Double){
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            print("COULD NOT SAVE")
            return
        }
        
        //In memory 'scratchpad' for managed objects
        let managedContext = appDelegate.persistentContainer.viewContext
        
        //Create a new managed object and insert it into managed object context
        
        print("THIS MANY DECKS: ")
        print(decks.count)
        
        if decks.count == 0 {
            print("FIRST DECK CREATED")
            //Create a new managed object and set its high score
            let entity = NSEntityDescription.entity(forEntityName: "DeckData", in: managedContext)!
            let deck = NSManagedObject(entity: entity, insertInto: managedContext)
            deck.setValue(highScore, forKeyPath: "highScore")
        } else{
            //Otherwise update the managed object
            let currHigh = decks[0]?.value(forKey: "highScore") as! Double
            
            print("CURRENT HIGH: ")
            print(currHigh)
            
            if(currHigh < highScore){
                print("UPDATING THE HIGH SCORE to \(highScore)")
                //Change the highscore
                decks[0]?.setValue(highScore, forKey: "highScore")
            }
        }
        
        //Commit changes and save to disk
        do {
            try managedContext.save()
            //decks.append(deck)
            print("SAVED!")
        } catch let error as NSError {
            print("Could not save. \(error.userInfo)")
        }
    }
    
    func goToNextView(viewName: String, num: Int){
           }
    
    @IBAction func selectTutorial(_ sender: UIButton) {
        currentDeck = [] //Clear deck from previous selection
        
        let num = sender.tag
        
        if let levelFilePath = Bundle.main.path(forResource: "level\(num)", ofType: "txt") {
            
            if let levelContents = try? String(contentsOfFile: levelFilePath) {
                //Split Q and A's by linebreak
                let lines = levelContents.components(separatedBy: CharacterSet.newlines)
                    .filter{ !$0.isEmpty }
                
                for line in lines{
                    //Splits each line into answer and clue
                    let parts = line.components(separatedBy: ":")
                    
                    let card = [parts[0],parts[1], parts[2]]
                    currentDeck.append(card)
                }
            }
            
            print(currentDeck)
            
            if let vc = storyboard?.instantiateViewController(withIdentifier: "Tutorial") as? TutorialViewController {
                
                vc.deck = currentDeck
                vc.num = num
                //vc.sendBack = self
                
                navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
    //TO DO: Add function for converting file to array of arrays string filename, string VC name
    
    
    @IBAction func selectQuiz(_ sender: UIButton) {
        currentDeck = [] //Clear deck from previous selection
        
        let num = sender.tag
        
        if let levelFilePath = Bundle.main.path(forResource: "level\(num)", ofType: "txt") {
            
            if let levelContents = try? String(contentsOfFile: levelFilePath) {
                //Split Q and A's by linebreak
                let lines = levelContents.components(separatedBy: CharacterSet.newlines)
                    .filter{ !$0.isEmpty }
                
                for line in lines{
                    //Splits each line into answer and clue
                    let parts = line.components(separatedBy: ":")
                    
                    let card = [parts[0],parts[1], parts[2]]
                    currentDeck.append(card)
                }
            }
            
            //print(currentDeck)
            
            if let vc = storyboard?.instantiateViewController(withIdentifier: "Question") as? QuestionViewController {
                
                vc.deck = currentDeck
                vc.num = num
                vc.sendBack = self
                
                navigationController?.pushViewController(vc, animated: true)
            }
        }

      
    }
    
    @IBAction func commonWordsList(_ sender: UIButton) {
        if let levelFilePath = Bundle.main.path(forResource: "commonWords", ofType: "txt") {
            
            if let levelContents = try? String(contentsOfFile: levelFilePath) {
                //Split Q and A's by linebreak
                let lines = levelContents.components(separatedBy: CharacterSet.newlines)
                    .filter{ !$0.isEmpty }
                
                for line in lines{
                    //Splits each line into answer and clue
                    let parts = line.components(separatedBy: ":")
                    
                    let card = [parts[0],parts[1], parts[2]]
                    currentDeck.append(card)
                }
            }
            
            //print(currentDeck)
            
            if let vc = storyboard?.instantiateViewController(withIdentifier: "ExpandingViewController") as? ExpandingTableViewController {
                
                vc.deck = currentDeck
                
                navigationController?.pushViewController(vc, animated: true)
            }
        }
        
    }
    
    //DEBUG FOR DELETE CORE DATA
    func DeleteAllData(){
        
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let managedContext = appDelegate.persistentContainer.viewContext
        let DelAllReqVar = NSBatchDeleteRequest(fetchRequest: NSFetchRequest<NSFetchRequestResult>(entityName: "DeckData"))
        do {
            try managedContext.execute(DelAllReqVar)
        }
        catch {
            print(error)
        }
    }
    
}
