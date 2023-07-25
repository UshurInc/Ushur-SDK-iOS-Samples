//  Copyright 2023. All rights reserved.

import UIKit
import BSImagePicker
import Photos
import UshurSDK



class ViewController: UIViewController {
    // Outlets
    @IBOutlet weak var uploadImageBtn: UIButton!
    @IBOutlet weak var testSdkBtn: UIButton!
    @IBOutlet weak var imagesCollectionView: UICollectionView!
    @IBOutlet weak var uploadImageImageView: UIImageView!
    private let ushur = Ushur()
    private let imagePicker = UIImagePickerController()
    private var ImageData = [Data]()
    private var invalidImageIndex: Int? = nil
    private var maximumImageSelection = 10
    private let viewForActivityIndicator = UIView()
    private let loadingTextLabel = UILabel()
    private var activityIndicatorView = UIActivityIndicatorView()

    // MARK: - View life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        ushur.delegate = self
        self.testSdkBtn.isHidden = true
        self.imagesCollectionView.dataSource = self
    }
    
    // MARK: - BtnAction
    // Tapping the button launches sdk APIs.
    @IBAction func testSdkBtnAction(_ sender: UIButton) {
        let emailSerivceId = ""
        let emailSubject = ""
        let emailBody = ""
        let replyToEmail = ""
        let token = ""
        let UeTag = ""
        DispatchQueue.main.async {
            self.showActivityIndicator()
        }
        ushur.processDocument(imageDataArray: ImageData,
                                     emailServiceId: emailSerivceId,
                                     emailSubject: emailSubject,
                                     emailBody: emailBody,
                                     replyTo: replyToEmail,
                                     tokenId: token,
                                     UeTag: UeTag)
    }
    
    //Tapping the button brings up the photo picker.
    @IBAction func uploadImageBtnAction(_ sender: UIButton) {
        let prompt = UIAlertController(title: kUploadImageTitleText,
                                       message: kUploadImageMessageText,
                                       preferredStyle: .actionSheet)
        
        // for opening camera
        func openCamera(_ _: UIAlertAction) {
            self.imagePicker.delegate = self
            if AVCaptureDevice.authorizationStatus(for: AVMediaType.video) ==  AVAuthorizationStatus.authorized {
                DispatchQueue.main.async {
                    self.imagePicker.sourceType = .camera
                    self.present(self.imagePicker, animated: true)
                }
            } else {
                AVCaptureDevice.requestAccess(for: .video) { (granted: Bool) -> Void in
                    if granted == true {
                        DispatchQueue.main.async {
                            self.imagePicker.sourceType = .camera
                            self.present(self.imagePicker, animated: true)                            }
                    } else {
                        // User rejected
                        let alert = UIAlertController(title: kAlertText,
                                                      message: kCameraUnauthorisedError,
                                                      preferredStyle: UIAlertController.Style.alert)
                        alert.addAction(UIAlertAction(title: kOkText,
                                                      style: UIAlertAction.Style.default,
                                                      handler: nil))
                        DispatchQueue.main.async {
                            self.present(alert, animated: true, completion: nil)
                        }
                    }
                }
            }
        }
        let cameraAction = UIAlertAction(title: kCamera,
                                         style: .default,
                                         handler: openCamera)
        prompt.addAction(cameraAction)
        
        // for opening gallery
        let bsImagePicker = ImagePickerController()
        bsImagePicker.settings.selection.max = maximumImageSelection
        func presentLibrary(_ _: UIAlertAction) {
            let status = PHPhotoLibrary.authorizationStatus()
            switch status {
            case .authorized, .restricted:
                //handle authorized status
                presentImagePicker(bsImagePicker, select: { (asset) in
                    // User selected an asset. Do something with it. Perhaps begin processing/upload?
                }, deselect: { (asset) in
                    // User deselected an asset. Cancel whatever you did when asset was selected.
                }, cancel: { (assets) in
                    // User canceled selection.
                }, finish: { (assets) in
                    for asset in assets {
                        let manager = PHImageManager.default()
                        let options = PHImageRequestOptions()
                        options.version = .original
                        options.isSynchronous = true
                        manager.requestImageDataAndOrientation(for: asset, options: options) { data, _, _, _ in
                            if let data = data {
                                self.ImageData.append(data)
                            }
                        }
                    }
                    self.checkForMinAndMaxImage()
                    self.imagesCollectionView.reloadData()
                })
            case .denied :
                //handle denied status
                let alert = UIAlertController(title: kAlertText,
                                              message: kPhotoLibraryUnauthorisedError,
                                              preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: kOkText,
                                              style: UIAlertAction.Style.default,
                                              handler: nil))
                DispatchQueue.main.async {
                    self.present(alert, animated: true, completion: nil)
                }
            case .notDetermined:
                // ask for permissions
                PHPhotoLibrary.requestAuthorization { status in
                    switch status {
                    case .authorized, .restricted :
                        self.presentImagePicker(bsImagePicker, select: { (asset) in
                            // User selected an asset. Do something with it. Perhaps begin processing/upload?
                        }, deselect: { (asset) in
                            // User deselected an asset. Cancel whatever you did when asset was selected.
                        }, cancel: { (assets) in
                            // User canceled selection.
                        }, finish: { (assets) in
                            for asset in assets {
                                let manager = PHImageManager.default()
                                let options = PHImageRequestOptions()
                                options.version = .original
                                options.isSynchronous = true
                                manager.requestImageDataAndOrientation(for: asset, options: options) { data, _, _, _ in
                                    if let data = data {
                                        self.ImageData.append(data)
                                    }
                                }
                            }
                            self.checkForMinAndMaxImage()
                            self.imagesCollectionView.reloadData()
                        })
                    default:
                        break
                    }
                }
            default:
                break
            }
            
        }
        let libraryAction = UIAlertAction(title: kPhotoLibrary,
                                          style: .default,
                                          handler: presentLibrary)
        let cancelAction = UIAlertAction(title: kCancel,
                                         style: .cancel,
                                         handler: nil)
        prompt.addAction(libraryAction)
        prompt.addAction(cancelAction)
        self.present(prompt, animated: true, completion: nil)
    }
    
    //Managing the disabling upload image button and proceed
    private func checkForMinAndMaxImage() {
        self.testSdkBtn.isHidden = false
        self.uploadImageBtn.isEnabled = true
        self.maximumImageSelection = 10
        self.uploadImageImageView.image = UIImage(named: "BrowseImage")
        if ImageData.isEmpty {
            self.invalidImageIndex = nil
            self.testSdkBtn.isHidden = true
        } else if ImageData.count == 10{
            self.uploadImageImageView.image = UIImage(named: "BrowseImageDisabled")
            self.uploadImageBtn.isEnabled = false
        } else {
            self.maximumImageSelection = 10 - ImageData.count
        }
    }
}

// MARK: - UIImagePickerControllerDelegate
extension ViewController: UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        // Dismiss picker, returning to original root viewController.
        dismiss(animated: true, completion: nil)
    }
    
    internal func imagePickerController(_ picker: UIImagePickerController,
                                        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        // Extract chosen image.
        let originalImage: UIImage = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
        if let data = originalImage.jpegData(compressionQuality: 1) {
            self.ImageData.append(data)
        }
        self.checkForMinAndMaxImage()
        DispatchQueue.main.async {
            self.imagesCollectionView.reloadData()
            // Dismiss the picker to return to original view controller.
            self.dismiss(animated: true, completion: nil)
        }
    }
}

// MARK: - UICollectionViewDataSource
extension ViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return ImageData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: kImageCollectionViewCell,
                                                      for: indexPath) as! ImageCollectionViewCell
        cell.deleteImageBtn.tag = indexPath.row
        cell.deleteImageBtn.addTarget(self, action: #selector(deleteSelectedImage), for: .touchUpInside)
        cell.imageView.image = UIImage(data: ImageData[indexPath.row])
        cell.deleteImageBtn.setTitle("", for: .normal)
        cell.layer.cornerRadius = 5
        cell.layer.borderColor = kAppCGColor
        cell.layer.borderWidth = 2
        if indexPath.row == invalidImageIndex {
            cell.layer.borderColor = UIColor.red.cgColor
        }
        return cell
    }
    
    //  MARK: - Helper functions
    //Deleting the selected image from list
    @objc private func deleteSelectedImage(_ sender: UIButton) {
        self.ImageData.remove(at: sender.tag)
        self.checkForMinAndMaxImage()
        if sender.tag < invalidImageIndex ?? 0 {
            self.invalidImageIndex! -= 1
        } else if sender.tag == invalidImageIndex {
            self.invalidImageIndex = nil
        }
        self.imagesCollectionView.reloadData()
    }
}

// MARK: - loader hide and unhide
extension ViewController {
    
    func showActivityIndicator() {
        viewForActivityIndicator.frame = CGRect(x: 0.0, y: 0.0,
                                                width: self.view.frame.size.width,
                                                height: self.view.frame.size.height)
        viewForActivityIndicator.backgroundColor = UIColor.lightGray
        viewForActivityIndicator.alpha = 0.9
        view.addSubview(viewForActivityIndicator)
        activityIndicatorView.center = CGPoint(x: self.view.frame.size.width / 2.0,
                                               y: self.view.frame.size.height / 2.0)
        activityIndicatorView.color = .black
        loadingTextLabel.textColor = .black
        loadingTextLabel.text = kLoaderText
        loadingTextLabel.font = UIFont.boldSystemFont(ofSize: 18.0)
        loadingTextLabel.sizeToFit()
        loadingTextLabel.center = CGPoint(x: activityIndicatorView.center.x,
                                          y: activityIndicatorView.center.y + 30)
        viewForActivityIndicator.addSubview(loadingTextLabel)
        activityIndicatorView.hidesWhenStopped = true
        activityIndicatorView.style = .large
        viewForActivityIndicator.addSubview(activityIndicatorView)
        activityIndicatorView.startAnimating()
    }
    
    func stopActivityIndicator() {
        viewForActivityIndicator.removeFromSuperview()
        activityIndicatorView.stopAnimating()
        activityIndicatorView.removeFromSuperview()
    }
}


// MARK: - Delegate functions for SDK
extension ViewController: ResponseDelegate {
    
    func invalidImageSizeIndex(indexOfImage: Int) {
        self.invalidImageIndex = indexOfImage
        self.imagesCollectionView.reloadData()
    }
    
    //Error handling
    func didHaveInvalidInput(errorMessage: String) {
        DispatchQueue.main.async {
            self.stopActivityIndicator()
            let alert = UIAlertController(title: kErrorText,
                                          message: errorMessage,
                                          preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: kOkText,
                                          style: UIAlertAction.Style.default,
                                          handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    //Success response
    func didGetResponse(result: Results ) {
        if let data = result.data {
            DispatchQueue.main.async {
                self.ImageData.removeAll()
                self.checkForMinAndMaxImage()
                self.imagesCollectionView.reloadData()
                self.stopActivityIndicator()
                let alert = UIAlertController(title: kImageResult,
                                              message:String(data: data, encoding: .utf8),
                                              preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: kOkText, style: UIAlertAction.Style.default,
                                              handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }
        //server error handling
        if let error = result.error {
            DispatchQueue.main.async {
                self.stopActivityIndicator()
                let alert = UIAlertController(title: kErrorText,
                                              message: error.localizedDescription,
                                              preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: kOkText,
                                              style: UIAlertAction.Style.default,
                                              handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
}
