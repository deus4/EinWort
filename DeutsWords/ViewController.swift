//
//  ViewController.swift
//  DeutsWords
//
//  Created by deus4 on 21/10/16.
//  Copyright © 2016 Deus4. All rights reserved.
//

import UIKit
import SwiftCSV

class ViewController: UIViewController {
    
    @IBOutlet weak var arrow: UIImageView!
    @IBOutlet weak var arrowView: UIView!
    @IBOutlet weak var colorButton: UIButton!
    @IBOutlet weak var ideeButton: UIButton!
    @IBOutlet weak var wordLabel: UILabel!
    @IBOutlet weak var noWordTextView: UITextView!
    @IBOutlet weak var brandLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    var lastDisplayedData : DateComponents? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.applicationDidBecomeActive(_:)),
            name: NSNotification.Name.UIApplicationDidBecomeActive,
            object: nil)
        animateArrow()
        let swipeGest = UISwipeGestureRecognizer(target: self, action: #selector(self.arrowGesture(_:)))
        let tapGest = UITapGestureRecognizer(target: self, action: #selector(self.arrowGesture(_:)))
        swipeGest.direction = UISwipeGestureRecognizerDirection.left
        arrowView.addGestureRecognizer(tapGest)
        arrowView.addGestureRecognizer(swipeGest)
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    func animateArrow() {
        UIView.animateKeyframes(withDuration: 1, delay: 0, options: [.repeat, .autoreverse], animations: {
            self.arrow.transform = CGAffineTransform(scaleX: 2, y: 2)
        }, completion: nil)
    }
    
    func getCsvFile() -> CSV?{
        let csvURL = Bundle(for: ViewController.self).url(forResource: "Words", withExtension: "csv")!
        do {
            let csv = try CSV(url: csvURL as NSURL)
            return csv
        } catch {
            print(error)
            return nil
        }
    }
    
    func arrowGesture(_ sender: UIGestureRecognizer) {
        arrowView.isHidden = true
        self.showWord(word: self.getWordForDate(components: self.getCurrentDateComponetns()))
    }
    
    @IBAction func ideeButtonAction(_ sender: UIButton) {
        self.ideeButton.isUserInteractionEnabled = false
        self.colorButton.isUserInteractionEnabled = false
        let windowBounds = self.view.window!.bounds
        let frame = CGRect(x: 14, y: 20, width: windowBounds.width - 28, height: windowBounds.height - 40)
        let view = IdeeView.instanceFromNib() as! IdeeView
        view.frame = frame
        view.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
        view.closeButton.isUserInteractionEnabled = true
        if self.colorButton.titleLabel!.text! == "Rot"{
            view.closeButton.setImage(UIImage(named: "blueCloseButton"), for: UIControlState.normal)
            view.backgroundColor = UIColor(red: 211/255, green: 225/255, blue: 239/255, alpha: 1)
            for label in view.textLabels as [UILabel]{
                label.textColor = UIColor(red: 0/255, green: 105/255, blue: 145/255, alpha: 1.0)
            }
        }else {
        }
        self.view.addSubview(view)
        UIView.animate(withDuration: 0.3, animations: {
            view.transform = CGAffineTransform(scaleX: 1, y: 1)
        }, completion: { (ended) -> Void in
        })
    }
    func setSizeForWord(word: String){
        let stringLength = word.characters.count
        switch stringLength {
        case _ where stringLength <= 5:
            wordLabel.font = wordLabel.font.withSize(50)
            break
        case _ where stringLength <= 10:
            wordLabel.font = wordLabel.font.withSize(40)
            break
        default:
            wordLabel.font = wordLabel.font.withSize(30)
            break
        }
    }
    
    @IBAction func colorButtonAction(_ sender: UIButton) {
        let redColor = UIColor(red: 238/255, green: 49/255, blue: 36/255, alpha: 1.0)
        let blueColor = UIColor(red: 0/255, green: 84/255, blue: 128/255, alpha: 1.0)
        UIView.animate(withDuration: 0.5, animations: {
            switch sender.titleLabel!.text! {
            case "Rot":
                self.view.backgroundColor = redColor
                self.colorButton.setTitle("Blau", for: UIControlState.normal)
                self.ideeButton.setTitleColor(redColor, for: UIControlState.normal)
                self.colorButton.setTitleColor(redColor, for: UIControlState.normal)
            case "Blau":
                self.view.backgroundColor = blueColor
                self.colorButton.setTitle("Rot", for: UIControlState.normal)
                self.ideeButton.setTitleColor(blueColor, for: UIControlState.normal)
                self.colorButton.setTitleColor(blueColor, for: UIControlState.normal)
            default:
                print("some error")
            }
        })
    }
    
    //test buttons
    @IBAction func previosDay(_ sender: UIButton) {
        if !dateLabel.text!.isEmpty{
            lastDisplayedData?.day! -= 1
            let calendar = Calendar.current
            let date = calendar.date(from: lastDisplayedData!)
            lastDisplayedData = calendar.dateComponents([.day,.month,.year], from: date!)
            showWorodForNewDate()
        }
    }
    @IBAction func nextDay(_ sender: UIButton) {
        if  !dateLabel.text!.isEmpty{
            lastDisplayedData?.day! += 1
            let calendar = Calendar.current
            let date = calendar.date(from: lastDisplayedData!)
            lastDisplayedData = calendar.dateComponents([.day,.month,.year], from: date!)
            showWorodForNewDate()
            
        }
    }
    func showWorodForNewDate() {
        setTextForNoWordView(components: lastDisplayedData!)
        wordLabel.text = getWordForDate(components: lastDisplayedData!)
        setSizeForWord(word: getWordForDate(components: lastDisplayedData!))
        wordLabel.isHidden = wordLabel.text!.isEmpty
        noWordTextView.isHidden = !wordLabel.text!.isEmpty
        let dateString = "\(lastDisplayedData!.day!)·\(lastDisplayedData!.month!)·\(lastDisplayedData!.year!)"
        dateLabel.text = dateString
        
        
    }
    //end test buttons
    
    func getCurrentDateComponetns() -> DateComponents{
        let date = NSDate()
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day,.month,.year], from: date as Date)
        return components
    }
    
    func getWordForDate(components: DateComponents) -> String{
        var word = ""
        let csvFile = getCsvFile()
        let monthNames = ["Januar","Februar","März","April","Mai","Juni","Juli","August","September","Oktober","November","Dezember"]
        let stringDate = "\(components.day!)\(monthNames[components.month! - 1])"
        
        for row in (csvFile?.rows)!{
            if row["Datum"] == stringDate && components.year! == 2017 {
                word = row["Wort"]!
                break
            }
        }
        return word
    }
    
    func showWord(word: String) {
        lastDisplayedData = getCurrentDateComponetns()
        let word = getWordForDate(components: lastDisplayedData!)
        if word.isEmpty {
            setTextForNoWordView(components: lastDisplayedData!)
            changeViewInHorizontal(oldView: arrow, newView: noWordTextView)
            dateLabel.text = castDateComponentsToString(components: lastDisplayedData!)
            changeViewsInVertical(oldView: brandLabel, newView: dateLabel)
        }else {
            wordLabel.text = word
            setSizeForWord(word: word)
            changeViewInHorizontal(oldView: arrow, newView: wordLabel)
        }
    }
    
    func changeViewInHorizontal(oldView: UIView, newView: UIView){
        newView.isHidden = false
        let oldViewTransform = CGAffineTransform(translationX: -self.view.bounds.width, y: 0)
        let newViewTransform = CGAffineTransform(translationX: self.view.bounds.width, y: 0)
        newView.transform = newViewTransform
        UIView.animate(withDuration: 0.5, animations: { () -> Void in
            oldView.transform = oldViewTransform
            newView.transform = CGAffineTransform(translationX: 0, y: 0)
        }, completion: { (completed) -> Void in
            if completed{
                oldView.isHidden = true
                self.view.isUserInteractionEnabled = true
            }
        })
    }
    
    func changeViewsInVertical(oldView: UIView, newView: UIView){
        newView.isHidden = false
        let oldViewTransform = CGAffineTransform(translationX: 0, y: 100)
        let newViewTransform = CGAffineTransform(translationX: 0, y: 100)
        newView.transform = newViewTransform
        UIView.animate(withDuration: 0.5, animations: { () -> Void in
            oldView.transform = oldViewTransform
            newView.transform = CGAffineTransform(translationX: 0, y: 0)
        }, completion: { (completed) -> Void in
            if completed{
                oldView.isHidden = true
            }
        })
    }
    
    func castDateComponentsToString(components: DateComponents) -> String {
        return "\(components.day!)·\(components.month!)·\(components.year!)"
    }
    
    func setTextForNoWordView(components: DateComponents) {
        if components.year! < 2017 {
            noWordTextView.text = "Die App «Ein Wort» kann ab dem\n01.01.2017 genutzt werden.\n\nViel Spass!"
        }else if components.year! > 2017 {
            noWordTextView.text = "Vielen Dank, dass Sie die App\n«Ein Wort» genutzt haben.\n\nDas Kunstprojekt war Teil einer\nReihe kultureller Interventionen\nim Rahmen der Klett und\nBalmer-Neujahrsedition 2017."
        }
    }
    
    
    func applicationDidBecomeActive(_: NSNotification) {
        let currentDate = getCurrentDateComponetns()
        if arrowView.isHidden && currentDate != lastDisplayedData{
            if !wordLabel.isHidden {
                changeViewInHorizontal(oldView: wordLabel, newView: arrow)
            }else if !noWordTextView.isHidden{
                changeViewInHorizontal(oldView: noWordTextView, newView: arrow)
            }
            arrowView.transform = CGAffineTransform(translationX: self.view.bounds.width, y: 0)
            UIView.animate(withDuration: 0.6, animations: { () -> Void in
                self.arrowView.transform = CGAffineTransform(translationX: 0, y: 0)
            }, completion: { (ended) -> Void in
                if ended {
                    self.arrowView.isHidden = false
                }
            })
            lastDisplayedData = currentDate
            animateArrow()
            changeViewsInVertical(oldView: dateLabel, newView: brandLabel)
        }else if !arrow.isHidden{
            arrow.transform = CGAffineTransform(translationX: 0, y: 0)
            animateArrow()
        }
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
}

