//
//  RegisterViewController.swift
//  Messenger
//
//  Created by İsmail Parlak on 11.12.2023.
//

import UIKit
import Firebase
import JGProgressHUD

class RegisterViewController: UIViewController, UINavigationControllerDelegate {
    
    private let spinner = JGProgressHUD(style: .dark)
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.clipsToBounds = true
        return scrollView
    }()
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "person.circle")
        imageView.tintColor = .gray
        imageView.contentMode = .scaleAspectFit
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 2
        imageView.layer.borderColor = UIColor.lightGray.cgColor
        return imageView
    }()
    
    private let firstNameField:UITextField = {
        let field = UITextField()
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.returnKeyType = .continue
        field.layer.cornerRadius = 12
        field.layer.borderWidth = 1
        field.layer.borderColor = UIColor.lightGray.cgColor
        field.placeholder = "First Name..."
        
        field.leftView = UIView(frame: CGRect(x: 0,
                                              y: 0,
                                              width: 5,
                                              height: 0))
        field.leftViewMode = .always    
        return field
    }()
    
    private let lastNameField:UITextField = {
        let field = UITextField()
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.returnKeyType = .continue
        field.layer.cornerRadius = 12
        field.layer.borderWidth = 1
        field.layer.borderColor = UIColor.lightGray.cgColor
        field.placeholder = "Last Name..."
        
        field.leftView = UIView(frame: CGRect(x: 0,
                                              y: 0,
                                              width: 5,
                                              height: 0))
        field.leftViewMode = .always
        return field
    }()
    
    private let emailField:UITextField = {
        let field = UITextField()
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.returnKeyType = .continue
        field.layer.cornerRadius = 12
        field.layer.borderWidth = 1
        field.layer.borderColor = UIColor.lightGray.cgColor
        field.placeholder = "Email Adsress..."
        
        field.leftView = UIView(frame: CGRect(x: 0,
                                              y: 0,
                                              width: 5,
                                              height: 0))
        field.leftViewMode = .always
        
        return field
    }()
    
   
    
    private let passwordField:UITextField = {
        let field = UITextField()
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.returnKeyType = .done
        field.layer.cornerRadius = 12
        field.layer.borderWidth = 1
        field.layer.borderColor = UIColor.lightGray.cgColor
        field.placeholder = "Passwod..."
        
        field.leftView = UIView(frame: CGRect(x: 0,
                                              y: 0,
                                              width: 5,
                                              height: 0))
        field.leftViewMode = .always
        field.isSecureTextEntry = true
        
        return field
    }()
    
    
    private let registerButton : UIButton = {
        let button = UIButton()
        button.setTitle("Register", for: .normal)
        button.backgroundColor = .systemGreen
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.layer.masksToBounds = true
        button.titleLabel?.font = .systemFont(ofSize: 20,weight: .bold)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Create Account"
        view.backgroundColor = .white
        
       
        
        registerButton.addTarget(self,
                              action: #selector(registerButtonTapped),
                              for: .touchUpInside)
        
        firstNameField.delegate = self
        lastNameField.delegate = self
        emailField.delegate = self
        passwordField.delegate = self
        
        
        view.addSubview(scrollView)
        scrollView.addSubview(imageView)
        scrollView.addSubview(firstNameField)
        scrollView.addSubview(lastNameField)
        scrollView.addSubview(emailField)
        scrollView.addSubview(passwordField)
        scrollView.addSubview(registerButton)
        
        imageView.isUserInteractionEnabled = true
        scrollView.isUserInteractionEnabled = true
        
        let gesture = UITapGestureRecognizer(target: self,
                                            action: #selector(didTapChangeProfilePic))
        
        imageView.addGestureRecognizer(gesture)
        

    }
    
    @objc private func didTapChangeProfilePic(){
        presentPhotoActionSheet()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollView.frame = view.bounds
        let size = view.width/4
        imageView.frame = CGRect(x:(view.width-size)/2,
                                 y:40,
                                 width : size,
                                 height:size)
        imageView.layer.cornerRadius = imageView.width/2
        firstNameField.frame = CGRect(x: 30,
                                  y:imageView.bottom+10,
                                  width : scrollView.width-60,
                                 height:52  )
        lastNameField.frame = CGRect(x: 30,
                                  y:firstNameField.bottom+10,
                                  width : scrollView.width-60,
                                 height:52  )
        emailField.frame = CGRect(x: 30,
                                  y:lastNameField.bottom+10,
                                  width : scrollView.width-60,
                                 height:52  )
        passwordField.frame = CGRect(x: 30,
                                  y:emailField.bottom+10,
                                  width : scrollView.width-60,
                                 height:52  )
        registerButton.frame = CGRect(x: 30,
                                  y:passwordField.bottom+10,
                                  width : scrollView.width-60,
                                 height:52  )
    }
    
    
    
    @objc func didTapRegister(){
        let vc = RegisterViewController()
        vc.title = "Create Account"
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc private func registerButtonTapped() {
        emailField.resignFirstResponder()
        passwordField.resignFirstResponder()
        
        guard let firstName = firstNameField.text,
              let lastName = lastNameField.text,
              let email = emailField.text ,
              let password = passwordField.text,
              !firstName.isEmpty ,
              !lastName.isEmpty,
              !email.isEmpty,
              !password.isEmpty ,
              password.count >= 6 else{
            alertUserLoginError()
            return
        }
        
        spinner.show(in: view)
        
        DatabaseMenager.shared.userExists(with: email, comletion: {
            [weak self] exists in guard !exists else{
                return
            }
        })
        
        spinner.show(in: view)
        
        FirebaseAuth.Auth.auth().createUser(withEmail: email, password: password,completion: { [weak self] authResult,error in
            guard let strongSelf = self else {
                return
            }
            
      
            
            DispatchQueue.main.async{
                self?.spinner.dismiss()
            }
            
            guard let result = authResult ,  error == nil else{
                print("Error creating user")
                return
            }
            
            let chatUser =  ChatAppUser(firstName: firstName,
                                        lastName: lastName,
                                        emailAddress: email
            )
            DatabaseMenager.shared.insertUser(with: chatUser, comletion: {
                success in if success{
                    guard let image = self?.imageView.image, let data = image.pngData() else{
                        return
                    }
                    let fileName = chatUser.profilePictureFileName
                    StorageManager.shared.uploadProfilePicture(with: data,fileName: fileName,completion: {result in
                        switch result {
                        case .success(let downloadUrl):
                            UserDefaults.standard.set(downloadUrl , forKey: "profile_picture_url")
                            print(downloadUrl)
                        case .failure(let error):
                            print("Storage manager error: \(error)")
                        }
                    })
                    
                }
            })
            
            strongSelf.navigationController?.dismiss(animated: true , completion: nil)
            
        })
        
        
    }
    
    func alertUserLoginError(){
        let alert = UIAlertController(title: "Woops",
                                      message: "Please enter all information to create a new account.",
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss",
                                      style: .cancel,
                                      handler: nil))
        present(alert,animated: true)
    }


}


extension RegisterViewController:UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField == firstNameField  {
            lastNameField.becomeFirstResponder()
        }else if textField == lastNameField{
            emailField.becomeFirstResponder()
        }else if textField == emailField{
            passwordField.becomeFirstResponder()
        }else if textField == passwordField{
            registerButtonTapped()
        }
        
        return true
    }
}

extension RegisterViewController:UIImagePickerControllerDelegate {
    
    func presentPhotoActionSheet(){
        let actionSheet = UIAlertController(title: "Profile Picture",
                                            message: "How would you like to select a picture?",
                                            preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Cancel",
                                            style: .cancel,
                                            handler: nil))
        actionSheet.addAction(UIAlertAction(title: "Take Photo",
                                            style: .default,
                                            handler: {
            [weak self] _ in self?.presentCamera()
        }))
        actionSheet.addAction(UIAlertAction(title: "Chose Photo",
                                            style: .default,
                                            handler: {
            [weak self] _ in self?.presentPhotoPicker()
        }))
        
        present(actionSheet, animated: true)
        
    }
    
    func presentCamera(){
        let vc = UIImagePickerController()
        vc.sourceType = .camera
        vc.delegate = self
        vc.allowsEditing = true
        present(vc,animated: true)
    }
    
    func presentPhotoPicker(){
        let vc = UIImagePickerController()
        vc.sourceType = .photoLibrary
        vc.delegate = self
        vc.allowsEditing = true
        present(vc,animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true , completion: nil)
        guard let selectedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else{
            return
        }
        self.imageView.image = selectedImage
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true , completion: nil)
    }
}
