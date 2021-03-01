//
//  ActivationViewController.swift
//  MyKey
//
//  Created by Dani Shifer on 12/12/2019.
//  Copyright © 2019 Dani Shifer. All rights reserved.
//

import UIKit
import MyKeyKit
import PromiseKit

class ActivationViewController: UITableViewController {

    var activityIndicator: UIActivityIndicatorView!
    var activityIndicatorBarItem: UIBarButtonItem!
    var doneBarItem: UIBarButtonItem!
    
    var hasError: Bool = false
    @IBOutlet var errorLabel: UILabel!
    
    @IBAction func fieldChanged(_ sender: UITextField) {
        updateDoneButton()
    }
    
    
    @IBOutlet var givenNameField: UITextField!
    @IBOutlet var familyNameField: UITextField!
    
    @IBOutlet weak var activationCodeStackView: UIStackView!
    @IBOutlet var activationCodeOutletCollection: [ActivationTextField]!
    var activationCodeIndexes: [ActivationTextField:Int] = [:]
    
    @IBAction func givenNameReturned(_ sender: UITextField) {
        familyNameField.becomeFirstResponder()
    }
    
    @IBAction func familyNameReturned(_ sender: UITextField) {
        activationCodeOutletCollection.first?.becomeFirstResponder()
    }
    
    override func viewDidLoad() {
        for index in 0 ..< activationCodeOutletCollection.count {
            activationCodeOutletCollection[index].activationDelegate = self
            activationCodeIndexes[activationCodeOutletCollection[index]] = index
        }
        
        activationCodeStackView.semanticContentAttribute = .forceLeftToRight
        
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if #available(iOS 13.0, *) {
            activityIndicator = UIActivityIndicatorView(style: .medium)
        } else {
            activityIndicator = UIActivityIndicatorView(style: .gray)
        }
        
        activityIndicatorBarItem = UIBarButtonItem(customView: activityIndicator)
        
        doneBarItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(donePressed(sender:)))
        doneBarItem.isEnabled = false
        
        showDoneButton()
        
        givenNameField.becomeFirstResponder()
    }
    
    func updateDoneButton() {
        if givenNameField.text?.count ?? 0 > 0
            && familyNameField.text?.count ?? 0 > 0
            && getActivationCode().count == 10 {
            doneBarItem.isEnabled = true
        } else {
            doneBarItem.isEnabled = false
        }
    }
    
    enum Direction { case left, right }

    func setNextResponder(_ index: Int?, direction: Direction) {
        guard let index = index else { return }

        if direction == .left {
            index == 0 ?
                (_ = activationCodeOutletCollection.first?.resignFirstResponder()) :
                (_ = activationCodeOutletCollection[(index - 1)].becomeFirstResponder())
        } else {
            index == activationCodeOutletCollection.count - 1 ?
                (_ = activationCodeOutletCollection.last?.resignFirstResponder()) :
                (_ = activationCodeOutletCollection[(index + 1)].becomeFirstResponder())
        }
    }
    
    func showActivityIndicator() {
        self.navigationItem.rightBarButtonItem = activityIndicatorBarItem
    }
    
    func showDoneButton() {
        self.navigationItem.rightBarButtonItem = doneBarItem
    }
    
    func getActivationCode() -> String {
        return self.activationCodeOutletCollection.reduce(into: "") { (prev, curr) in
            prev.append(curr.text!)
        }
    }
    
    func handleActivationError(_ err: Error) {
        self.navigationItem.setHidesBackButton(false, animated: true)
        activityIndicator.stopAnimating()
        showDoneButton()
        
        switch err {
        case MyKeyClientError.statusWithPayload(let code, let payload):
            print("Activation error [\(code)]: \(payload)")
            setActivationError(code: code)
        case MyKeyClientError.status(let code):
            print("Activation error [\(code)]")
            setActivationError(code: code)
        default:
            print("Unknown activation error: \(err)")
            setActivationError(code: 500)
        }
    }
    
    func setActivationError(code: Int) {
        self.hasError = true

        switch code {
        case 403,406:
            errorLabel.text = NSLocalizedString("activation-error-incorrect", comment: "")
        default:
            errorLabel.text = NSLocalizedString("activation-error-temporary", comment: "")
        }
        
        self.tableView.reloadData()
    }
    

    @objc func donePressed(sender: UITapGestureRecognizer) {
        self.hasError = false
        self.tableView.reloadData()
        
        self.navigationItem.setHidesBackButton(true, animated: true)
        activityIndicator.startAnimating()
        showActivityIndicator()
        
        
        let request = ActivatePhoneRequest(
            givenName: givenNameField.text!,
            familyName: familyNameField.text!,
            activationCode: self.getActivationCode()
        )
        
        let globalClient = GlobalClient(baseUrl: Configuration.GlobalClientURL)
        
        firstly {
            globalClient.activatePhone(request)
        }.get { response in
            // Store role and device information in the secure store
            SecureStore.shared.setRole(response.role)
            SecureStore.shared.saveDevice(response.device)
            
            // Store institute id and url securely
            SecureStore.shared.setInstituteId(response.instituteId)
            SecureStore.shared.setInstituteURL(response.instituteGateway)
            
            // Store institute metadata
            let instituteMetadata = RealmInstituteMetadata()
            instituteMetadata.id = response.instituteId
            instituteMetadata.name = response.instituteName
            
            DataStore.shared.addInstituteMetadata(instituteMetadata)
        }.done { _ in
            // Dismiss modal and broadcast activation completion message
            self.dismiss(animated: true, completion: {
                NotificationCenter.default.post(name: .didCompleteActivation, object: nil)
            })
        }.catch(handleActivationError)
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "activation-given-name".localized
        case 1:
            return "activation-family-name".localized
        case 2:
            return "activation-activation-code".localized
        default:
            return nil
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        switch section {
        case 2:
            return "activation-activation-code-desc".localized
        default:
            return nil
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return hasError ? 4 : 3
    }
}

extension ActivationViewController: ActivationTextFieldDelegate {
    func didDeleteOnEmpty(_ field: ActivationTextField) {
        let fieldIndex = activationCodeIndexes[field]
        
        if let fieldIndex = fieldIndex {
            if fieldIndex > 0 {
                activationCodeOutletCollection[fieldIndex - 1].text = ""
            }
        }
        
        setNextResponder(activationCodeIndexes[field], direction: .left)
    }
}


extension ActivationViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let activationField = textField as? ActivationTextField else { return true }
        if range.length == 0 {
            activationField.text = string
            updateDoneButton()
            setNextResponder(activationCodeIndexes[activationField], direction: .right)
            return false
        } else if range.length == 1 {
            textField.text = ""
            updateDoneButton()
            setNextResponder(activationCodeIndexes[activationField], direction: .left)
            return false
        }
        return false
    }
}

