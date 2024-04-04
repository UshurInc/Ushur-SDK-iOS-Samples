//
//  ViewController.swift
//  ushur_sdk_demo
//
//  Created by mymac on 24/07/23.
//

import UIKit
import UshurSDK

class ViewController: UIViewController {
    //MARK: Variables
    var activityView: UIActivityIndicatorView?
    var imageArray: [UIImage] = [UIImage]()
    private lazy var imagePicker: ImagePicker = {
        let imagePicker = ImagePicker()
        imagePicker.delegate = self
        return imagePicker
    }()
    var ushur = Ushur(token: "",useEdgeOcr: true)
    //MARK: Outlets
    @IBOutlet weak var addImageButton: UIButton!
    @IBOutlet weak var uploadImageButton: UIButton!
    @IBOutlet weak var imagesCollectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.imagesCollectionView.register(UINib(nibName: "ImageCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "ImageCollectionViewCell")
        self.imagesCollectionView.dataSource = self
        self.imagesCollectionView.delegate = self
        imagePicker.photoGalleryAsscessRequest()
        ushur.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        imagesCollectionView.collectionViewLayout = layout
    }
    
    //MARK: Functions
    func showActivityIndicator() {
        activityView = UIActivityIndicatorView(style: .large)
        activityView?.center = self.view.center
        self.view.addSubview(activityView!)
        activityView?.startAnimating()
        self.view.isUserInteractionEnabled = false
    }
    
    func hideActivityIndicator(){
        if (activityView != nil){
            activityView?.stopAnimating()
            self.view.isUserInteractionEnabled = true
        }
    }
    
    
    func imageResolution(image: UIImage){
        let heightInPoints = image.size.height
        let heightInPixels = heightInPoints * image.scale
        
        let widthInPoints = image.size.width
        let widthInPixels = widthInPoints * image.scale
        
        print(widthInPixels, heightInPixels)
        
    }
    
    func resizeImage(image: UIImage,newWidth: CGFloat, newHeight: CGFloat) -> UIImage? {
        
        UIGraphicsBeginImageContext(CGSizeMake(newWidth, newHeight))
        image.draw(in: CGRectMake(0, 0, newWidth, newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }
    
    //MARK: Button Actions
    @IBAction func addImageButtonAction(_ sender: UIButton){
        imagePicker.present(parent: self, sourceType: .photoLibrary)
    }
    
    @IBAction func uploadImageButtonAction(_ sender: UIButton){
        if imageArray.count == 0 {return}
        self.showActivityIndicator()
        var imageData = [Data]()
        for item in imageArray{
            if let imgData = item.jpegData(compressionQuality: 1.0){
//                print(imgData.count)
                imageData.append(imgData)
            }else{
//                print("Invalid image size")
            }
        }
        ushur.processDocument(imageDataArray: imageData, config: .InsuranceCard)
        imageArray.removeAll()
        self.imagesCollectionView.reloadData()
    }
    
    
    @IBAction func uploadPillsButtonAction(_ sender: UIButton){
        if imageArray.count == 0 {return}
        self.showActivityIndicator()
        var imageData = [Data]()
        for item in imageArray{
            if let imgData = item.jpegData(compressionQuality: 1.0){
//                print(imgData.count)
                imageData.append(imgData)
            }else{
                print("Invalid image size")
            }
        }
        ushur.processDocument(imageDataArray: imageData, config: .PillBox)
        imageArray.removeAll()
        self.imagesCollectionView.reloadData()
    }
    
}

extension ViewController: UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCollectionViewCell", for: indexPath) as! ImageCollectionViewCell
        cell.imgView.image = imageArray[indexPath.row]
        cell.deleteButton.tag = indexPath.row
        cell.deleteCompletionBlock = { deleted in
            if deleted {
                let alertController = UIAlertController(title: "Delete!", message: "Are you sure?", preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "Yes", style: .default, handler: { action in
                    self.imageArray.remove(at: indexPath.row)
                    DispatchQueue.main.async {
                        self.imagesCollectionView.reloadData()
                    }
                }))
                alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
                DispatchQueue.main.async {
                    self.present(alertController, animated: true)
                }
            }
        }
        return cell
    }
    
}


extension ViewController: UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let collectionWidth = collectionView.frame.width
        return CGSize(width: collectionWidth/2-5, height: (collectionWidth/2)*0.75)
        
    }
    
}

extension ViewController: ImagePickerDelegate {
    func imagePicker(_ imagePicker: ImagePicker, grantedAccess: Bool, to sourceType: UIImagePickerController.SourceType) {
        guard grantedAccess else { return }
        imagePicker.present(parent: self, sourceType: sourceType)
    }
    
    func imagePicker(_ imagePicker: ImagePicker, didSelect image: UIImage) {
//        if let resizeImage = resizeImage(image: image, newWidth: 1024, newHeight: 768){
//            self.imageArray.append(resizeImage)
//        }else{
//            print("Alert: Image not resized")
//            self.imageArray.append(image)
//        }
        self.imageArray.append(image)
        imagePicker.dismiss()
        self.imagesCollectionView.reloadData()
    }
    
    func cancelButtonDidClick(on imageView: ImagePicker) {
        imagePicker.dismiss()
//        print("Cancel button Action")
    }
    
}


extension ViewController: ResponseDelegate{
    func didGetResponse(result: Data?) {
        DispatchQueue.main.async {
            self.hideActivityIndicator()
        }
        if let finalData = result{
            do{
                // Print show all result inside alert
                if let json = try JSONSerialization.jsonObject(with: finalData,options: []) as? [String: Any]{
                    let convertedString = String(data: finalData, encoding: .utf8) // the data will be converted to the string
                    DispatchQueue.main.async {
                        self.showAlert(title: "Api Response", message: convertedString ?? "")
                    }
                }else{
                    DispatchQueue.main.async {
                        self.showAlert(title: "Response", message: "JSON coundn't serialize")
                    }
                }
            }catch{
                let convertedString = String(data: finalData, encoding: .utf8) // the data will be converted to the string

                DispatchQueue.main.async {
                    self.showAlert(title: "Error", message: convertedString ?? "")
                }
                print(error.localizedDescription)
            }
        }else{
            DispatchQueue.main.async {
                self.showAlert(title: "Error", message: "Something went wrong")
            }
        }
    }
    
    func didHaveInvalidInput(errorMessage: String) {
        DispatchQueue.main.async {
            self.hideActivityIndicator()
        }
        DispatchQueue.main.async {
            self.showAlert(title: "Error", message: errorMessage)
        }
//        print("Error message: \(errorMessage)")
    }
    
    func invalidImageSizeIndex(indexOfImage: Int) {
        DispatchQueue.main.async {
            self.hideActivityIndicator()
        }
//        print("Invalid images:",indexOfImage)
    }
    
    
}


extension ViewController{
    
    func showAlert(title: String, message: String){
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Ok", style: .default))
        self.present(alertController, animated: true)
    }
}
