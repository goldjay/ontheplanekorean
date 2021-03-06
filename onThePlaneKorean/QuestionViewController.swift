//
//  QuestionViewController.swift
//  onThePlaneKorean
//
//  Created by Jay Steingold on 1/30/17.
//  Copyright © 2017 Goldjay. All rights reserved.
//

import UIKit
import GameplayKit //For shuffling the array

protocol sendBack {
    func setSentData(highScore: Double)
}


class QuestionViewController: UIViewController {
    
    @IBOutlet weak var button1: UIButton!
    @IBOutlet weak var button2: UIButton!
    @IBOutlet weak var button3: UIButton!
    @IBOutlet weak var button4: UIButton!
    
    
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var quizNumLabel: UILabel!
    
    @IBOutlet weak internal var timerWidth: NSLayoutConstraint!
    
    var sendBack: sendBack?
    
    //Data from the quiz
    var correctAnswer: Int = 0
    var numAnswered: Int = 0
    var numCorrect: Int = 0
    var message = ""
    
    //For saving data
    //var completed: Bool = false
    var highScore: Double = 0
    
    //For the timer
    var timer = Timer()
    var originalWidth: CGFloat = 0
    var decrementAmt: CGFloat = 0
    var numSecs: CGFloat = 30
    var count: CGFloat = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("NOW NUM IS: \(num)")
        
        setButtonAndBackground(num: num)
 
        //Set original width for timer bar
        originalWidth = 343
        print("Original width: \(originalWidth)")
        decrementAmt = originalWidth / speed //Global options variable
        
        quizNumLabel.text = "QUIZ LEVEL \(num + 1)"
        askQuestion()
    }
    
    func setButtonAndBackground(num: Int) {
        
        var selectedColor: UIColor
        
        print("NOW NUM IS: \(num)")
        
        switch(num){
        case 1:
            selectedColor = UIColor.customYellow
            break
        case 2:
            selectedColor = UIColor.customRed
            break
        case 3:
            selectedColor = UIColor.customBlue
            break
        default:
            selectedColor = UIColor.customGreen
            break
        }
        
        self.view.backgroundColor = selectedColor
        button1.setTitleColor(selectedColor, for: .normal)
        button2.setTitleColor(selectedColor, for: .normal)
        button3.setTitleColor(selectedColor, for: .normal)
        button4.setTitleColor(selectedColor, for: .normal)
        minSizeButtonText(myButton: button1)
        minSizeButtonText(myButton: button2)
        minSizeButtonText(myButton: button3)
        minSizeButtonText(myButton: button4)
        navigationController?.navigationBar.barTintColor = selectedColor
        
    }

    func askQuestion(action: UIAlertAction! = nil) {
        //TO DO: SIMPLIFY
        let selectedColor = self.view.backgroundColor
        let buttonArr = [self.button1, self.button2, self.button3, self.button4]
        
        
        for btn in buttonArr {
            btn?.setTitleColor(selectedColor, for: .normal)
        }
        
        var deckNum = 0
        var answerNum = 1
        
        if(!checkIfFinished()){
            let shuffledDeck = GKRandomSource.sharedRandom().arrayByShufflingObjects(in: currentDeck) as! [[String]]
            
            //Choose a random answer
            correctAnswer = Int(arc4random_uniform(4) + 1)
            
            //Choose if question is in Korean or english
            let language = Int(arc4random_uniform(2))
            if language == 1{
                deckNum = 0
                answerNum = 1
            }else{
                deckNum = 1
                answerNum = 0
            }
            
            button1.setTitle(shuffledDeck[1][deckNum], for: UIControlState.normal)
            button2.setTitle(shuffledDeck[2][deckNum], for: UIControlState.normal)
            button3.setTitle(shuffledDeck[3][deckNum], for: UIControlState.normal)
            button4.setTitle(shuffledDeck[4][deckNum], for: UIControlState.normal)
            
            //MARK: MYSTERY
            if(mode == "mystery"){
                delayWithSeconds(1){
                    //Fade out
                    UIView.animate(withDuration: 0.8, animations: {
                        
                        for btn in buttonArr{
                            btn?.setTitleColor(.white, for: .normal)
                        }
                        
                    }, completion: nil)
                }
            }
            
            //For mystery mode, the answers disappear or the question disappears after 1 sec
            
            
            questionLabel.text = shuffledDeck[correctAnswer][answerNum]
            
            timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(QuestionViewController.setTimerLabel), userInfo: nil, repeats: true)
        }
    }
    
    func checkIfFinished() -> Bool{
        if mode != "suddenDeath" && numAnswered == (numQuestions) {
            
            timer.invalidate()
            //print(Double(numCorrect/numAnswered))
            
            //If you did well enough, you can move to the next level
            if Double(numCorrect) / Double(numAnswered) >= 0.9 {
                
                //Maybe change this to a percentage if add # of cards
                highScore =  (Double(numCorrect / numAnswered)) * 100
                
                message = "You have answered \(numCorrect) out of \(numAnswered) questions correct."
            }
            else{
                //Message about trying harder
                message = "You have answered \(numCorrect) out of \(numAnswered) questions correct. I think you could use more practice."
            }
            gameOver(message: message)
            
            return true
        }
        //In the case of marathon mode
        return false
    }
    
    @IBAction func answerTapped(_ sender: UIButton) {
        //Change color of correct button
        let correctButton: UIButton = self.view.viewWithTag(correctAnswer) as! UIButton
        
        if sender == correctButton{
            buttonFlash(sender: sender, color: UIColor.customLightGreen)
            
            
        }else{
            buttonFlash(sender: sender, color: UIColor.customLightRed)
            buttonFlash(sender: correctButton, color: UIColor.customLightGreen)
            if(mode == "marathon"){
                gameOver(message: "You went for \(numAnswered) questions!")
                timer.invalidate()
                return //TO DO: Revisit effects
            }
        }
        
        resetTimerLabel()

        //If the title on the button tapped is the same as the correctAnswer
        if sender.tag == correctAnswer {
            numCorrect += 1
        }
        
        numAnswered += 1
        
        // Reset constraint
        timerWidth.constant = originalWidth
        self.view.layoutIfNeeded()
        
        //wait a moment before asking again
        delayWithSeconds(1){
            self.askQuestion()
        }
        
    }
    
    //MARK: TIMER
    func setTimerLabel()
    {
        let currWidth = timerLabel.frame.width
        
        timerWidth.constant = currWidth
        self.view.layoutIfNeeded()
        
        
        //If you ran out of time
        if currWidth <= 0
        {
            if(mode == "suddenDeath"){
                gameOver(message: "Too slow! You got \(numAnswered) right.")
            }
            
            numAnswered += 1
            //Alert the correct answer
            let correctButton: UIButton = self.view.viewWithTag(correctAnswer) as! UIButton
            
            buttonFlash(sender: correctButton, color: UIColor.customLightGreen)
            
            
            self.resetTimerLabel()
            delayWithSeconds(0.8){
            self.askQuestion()
            return
            }
            
            
        }
        
        
        let frmPlay : CGRect = timerLabel.frame
        
        let originXbutton = frmPlay.origin.x
        let originYbutton = frmPlay.origin.y
        
        let oldHeight = frmPlay.size.height
        let newWidth = originalWidth - (decrementAmt * count)
        
        UIView.animate(withDuration: 0.01, delay: 0, options: UIViewAnimationOptions.curveLinear, animations: {
            
            self.timerLabel.frame = CGRect(x: originXbutton, y: originYbutton, width: newWidth, height: oldHeight)
            }, completion: nil)
        
        count += 1
    }
    
    func resetTimerLabel()
    {
        //Set width to original
        let frmPlay : CGRect = timerLabel.frame
        
        let originXbutton = frmPlay.origin.x
        let originYbutton = frmPlay.origin.y
        
        let oldHeight = frmPlay.size.height
        let newWidth = originalWidth
        
        timerLabel.frame = CGRect(x: originXbutton, y: originYbutton, width: newWidth, height: oldHeight)
        
        timerWidth.constant = originalWidth
        self.view.layoutIfNeeded()
        
        timer.invalidate()
        count = 0
    }
    
    func gameOver(message: String){
        print("You got this many right: \(numCorrect)\n")
        print("And you answered this many: \(numAnswered)\n")
        
        //Send info back
        sendBack?.setSentData(highScore: highScore)
        
        //Reset stats
        numAnswered = 0
        numCorrect = 0
        
        //TO DO: Possible transition to view with stats/words missed
        let ac = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Back", style: .default, handler: backToMenu))
        ac.addAction(UIAlertAction(title: "Again", style: .default, handler: askQuestion))
        
        present(ac, animated: true)
    }
    
    func backToMenu(action: UIAlertAction! = nil) {
        //Send info back
        sendBack?.setSentData(highScore: highScore)
        navigationController!.pushViewController(storyboard!.instantiateViewController(withIdentifier: "Menu") as UIViewController, animated: true)
        
    }
    
    func buttonFlash(sender: UIButton, color: UIColor){
        //Fade in
        UIView.animate(withDuration: 0.4, animations: {
            sender.backgroundColor = color
            sender.setTitleColor(UIColor.white, for: UIControlState.normal)
            //sender.titleLabel?.text = (sender.titleLabel?.text)! + "wow"
            
            }, completion: nil)
        //Pause
        delayWithSeconds(1){
            sender.backgroundColor = UIColor.white
            //sender.alpha = 1
            //Fade out
            /*
            UIView.animate(withDuration: 0.4, animations: {
             
                }, completion: nil)
            */
        }
        
        
    }
    
    func delayWithSeconds(_ seconds: Double, completion: @escaping () -> ()) {
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
            completion()
        }
    }
    
    func minSizeButtonText(myButton: UIButton){
        myButton.titleLabel?.minimumScaleFactor = 0.5
        myButton.titleLabel?.numberOfLines = 0
        myButton.titleLabel?.adjustsFontSizeToFitWidth = true
    }
}
