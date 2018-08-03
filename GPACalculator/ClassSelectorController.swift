/**
 * Copyright (c) 2017 Westlake APC
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import UIKit
import Toast_Swift

class ClassSelectorController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    var selected = 0
    var toasted = false
    var toasting = false
    
    @IBOutlet var classNameField: UITextField!
    @IBOutlet var multiplierField: UITextField!
    @IBOutlet var currentGradeField: UITextField!
    @IBOutlet var creditsField: UITextField!
    
    @IBOutlet var multiplierBar: UISegmentedControl!
    @IBOutlet var creditsBar: UISegmentedControl!
    
    @IBOutlet var warningLabel: UILabel!
    
    @IBOutlet var addClassButton: UIButton!
    @IBOutlet var cancelButton: UIBarButtonItem!
    
    @IBOutlet var picker: UIPickerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Information.initializeArray()
        
        picker.delegate = self
        picker.dataSource = self
        
        cancelButton.isEnabled = true
        
        picker.selectRow(Information.selectedRow, inComponent: 0, animated: false)
        pickerView(picker, didSelectRow: Information.selectedRow, inComponent: 0)
        
        classNameField.addTarget(self, action: #selector(self.disablePicker), for: UIControlEvents.editingChanged)
        multiplierField.addTarget(self, action: #selector(self.disablePicker), for: UIControlEvents.editingChanged)
        multiplierBar.addTarget(self, action: #selector(self.disablePicker), for: UIControlEvents.valueChanged)
        currentGradeField.addTarget(self, action: #selector(self.disablePicker), for: UIControlEvents.editingChanged)
        creditsField.addTarget(self, action: #selector(self.disablePicker), for: UIControlEvents.editingChanged)
        creditsBar.addTarget(self, action: #selector(self.disablePicker), for: UIControlEvents.valueChanged)
    }

    // Exit View
    @IBAction func exit(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return Information.classesAndGrades[row].name
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int{
        return Information.classesAndGrades.count
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selected = row
        
        classNameField.text = Information.classesAndGrades[selected].name
        currentGradeField.text = "\(Information.classesAndGrades[selected].grade)"
        
        switch Information.classesAndGrades[selected].multiplier {
            case 1.0:
                multiplierBar.selectedSegmentIndex = 0
                multiplierField.text = ""
            case 1.1:
                multiplierBar.selectedSegmentIndex = 1
                multiplierField.text = ""
            case 1.2:
                multiplierBar.selectedSegmentIndex = 2
                multiplierField.text = ""
            default:
                multiplierBar.selectedSegmentIndex = 3
                multiplierField.text = "\(Information.classesAndGrades[selected].multiplier)"
        }
        
        switch Information.classesAndGrades[selected].credits {
            case 0.5:
                creditsBar.selectedSegmentIndex = 0
                creditsField.text = ""
            case 1.0:
                creditsBar.selectedSegmentIndex = 1
                creditsField.text = ""
            default:
                creditsBar.selectedSegmentIndex = 2
                creditsField.text = "\(Information.classesAndGrades[selected].credits)"
        }
    }
    
    @IBAction func updateClass(_ sender: Any) {
        // Class name
        guard let className = classNameField.text, !className.isEmpty else {
            showWarning()
            print("No class name specified.")
            return
        }
        
        // Multiplier
        var multiplier: Double = -1
        
        switch multiplierBar.selectedSegmentIndex {
            case 0:
                multiplier = 1
            case 1:
                multiplier = 1.1
            case 2:
                multiplier = 1.2
            default:
                guard let multiplierText = multiplierField.text, !multiplierText.isEmpty else {
                    showWarning()
                    print("No multiplier specified.")
                    return
                }
                
                // Can't use guard without let.
                guard let _multiplier = Double(multiplierText) else {
                    showWarning()
                    print("Malformed multiplier.")
                    return
                }
                multiplier = _multiplier
        }
        
        // Current grade
        guard let currentGradeText = currentGradeField.text, !currentGradeText.isEmpty else {
            showWarning()
            print("No current grade specified.")
            return
        }
        guard let currentGrade = Int(currentGradeText) else {
            showWarning()
            print("Malformed current grade.")
            return
        }
        
        // Credits
        var credits: Double = -1
        
        switch creditsBar.selectedSegmentIndex {
            case 0:
                credits = 0.5
            case 1:
                credits = 1.0
            default:
                guard let creditsText = creditsField.text, !creditsText.isEmpty else {
                    showWarning()
                    print("No credits specified.")
                    return
                }
                
                // Can't use guard without let.
                guard let _credits = Double(creditsText) else {
                    showWarning()
                    print("Malformed credits.")
                    return
                }
                credits = _credits
        }
        
        // Add the class
        Information.classesAndGrades[selected] = Information(className, grade: currentGrade, multiplier: multiplier, credits: credits)
        ArchiveDataSystem.archiveGradeData(infoList: Information.classesAndGrades, key: "savedList")
        
        classNameField.text = ""
        multiplierField.text = ""
        multiplierBar.selectedSegmentIndex = 0
        currentGradeField.text = ""
        creditsField.text = ""
        creditsBar.selectedSegmentIndex = 0
        
        cancelButton.isEnabled = false
        
        // Let button animation finish.
        DispatchQueue.main.async {
            self.view.endEditing(true)
            
            usleep(10000)
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
        
        if touches.contains(where: { touch in
            picker.frame.contains(touch.location(in: self.view))
        }) {
            if !picker.isUserInteractionEnabled && !toasting {
                toasting = true
                
                self.view.makeToast("Save before editing another class.", duration: 3.0, position: .bottom)
                toasted = true
                
                DispatchQueue.global().async {
                    usleep(4000000)
                    self.toasting = false
                }
            }
        }
    }
    
    // Show Missing Information Warning
    func showWarning() {
        
        if toasting {return}
        
        self.view.makeToast("You have missing information.", duration: 3.0, position: .bottom)
        toasting = true
        
        DispatchQueue.global().async {
            usleep(4000000)
            self.toasting = false
        }
    }
    
    @objc func disablePicker() {
        picker.isUserInteractionEnabled = false
        // picker.backgroundColor = .red
        /*
        if !toasted {
            self.view.makeToast("Save before editing another class.", duration: 3.0, position: .bottom)
            toasted = true
        }*/
    }
}
