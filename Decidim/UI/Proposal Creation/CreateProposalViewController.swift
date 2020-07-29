//
//  CreateProposalViewController.swift
//  Decidim
//
//  Created by Kyle Donnelly on 7/13/20.
//  Copyright © 2020 Kyle Donnelly. All rights reserved.
//

import UIKit

class CreateProposalViewController: UIViewController {
    
    fileprivate static let InputCellId = "InputCell"
    fileprivate static let ImageCellId = "ImageCell"
    fileprivate static let DateCellId = "DateCell"
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet var doneButtonItem: UIBarButtonItem!
    
    fileprivate var proposalTitle: String? {
        didSet { refreshDoneButton() }
    }
    fileprivate var proposalDescription: String? {
        didSet { refreshDoneButton() }
    }
    
    fileprivate var thumbnail: UIImage?
    fileprivate var deadline: Date!
    
    public static func create() -> UIViewController {
        let sb = UIStoryboard(name: "CreateProposal", bundle: .main)
        let vc = sb.instantiateInitialViewController() as! UINavigationController
        return vc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.refreshDoneButton()
        self.deadline = Date(timeIntervalSinceNow: 60 * 60 * 24 * 7)
    }
    
    fileprivate func refreshDoneButton() {
        if let title = self.proposalTitle, title.count > 0,
           let description = self.proposalDescription, description.count > 0 {
            self.doneButtonItem.isEnabled = true
        } else {
            self.doneButtonItem.isEnabled = false
        }
    }
    
}

extension CreateProposalViewController {
    
    @IBAction func didTapCancelButton(_ sender: Any) {
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func didTapDoneButton(_ sender: Any) {
        guard let title = self.proposalTitle, let description = self.proposalDescription else {
            return
        }
        
        let deadline: Date = self.deadline
        let proposal = PublicProposalDataController.shared().addProposal(title: title, description: description, thumbnail: self.thumbnail, deadline: self.deadline)
        
        ProposalDetailDataController.shared(proposal: proposal).refresh { dc in
            dc.data = [ProposalDetail(proposal: proposal, authorId: 1, likeCount: 0, deadline: deadline, amendmentCount: 0)]
        }
        
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    
}

extension CreateProposalViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 || indexPath.row == 1 {
            return 50
        } else if indexPath.row == 2 {
            return 72
        } else {
            return 128
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: Self.InputCellId, for: indexPath) as! ProposalInputCell
            cell.setup(field: "Title", content: self.proposalTitle, required: true) { [weak self] text in
                self?.proposalTitle = text
            }
            return cell
        } else if indexPath.row == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: Self.InputCellId, for: indexPath) as! ProposalInputCell
            cell.setup(field: "Description", content: self.proposalDescription, required: true) { [weak self] text in
                self?.proposalDescription = text
            }
            return cell
        } else if indexPath.row == 2 {
            let cell = tableView.dequeueReusableCell(withIdentifier: Self.ImageCellId, for: indexPath) as! ProposalImageCell
            cell.setup(thumbnail: self.thumbnail) { [weak self] in
                self?.showImagePicker(indexPath: indexPath)
            }
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: Self.DateCellId, for: indexPath) as! ProposalDatePickerCell
            cell.setup(deadline: self.deadline) { [weak self] date in
                self?.deadline = date
            }
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 2 {
            self.showImagePicker(indexPath: indexPath)
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = .clear
    }
    
}

extension CreateProposalViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    fileprivate func showImagePicker(indexPath: IndexPath) {
        let imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = true
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        if let mediaTypes = UIImagePickerController.availableMediaTypes(for: .photoLibrary) {
            imagePicker.mediaTypes = mediaTypes
        }
        
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = self.mediaImage(info: info) {
            self.thumbnail = image
        }
        
        picker.dismiss(animated: true) { [weak self] in
            self?.tableView.reloadData()
        }
    }
    
    private func mediaImage(info: [UIImagePickerController.InfoKey: Any]) -> UIImage? {
        if let image = info[.editedImage] as? UIImage {
            return image
        }
        
        if let image = info[.originalImage] as? UIImage {
            return image
        }
        
        return nil
    }
    
}
