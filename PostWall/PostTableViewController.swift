//
//  PostTableViewController.swift
//  PostWall
//
//  Created by 翁淑惠 on 2020/12/22.
//

import UIKit
import Alamofire

class PostTableViewController: UITableViewController, UINavigationControllerDelegate {
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var articleTextView: UITextView!
    @IBOutlet weak var imageButton: UIButton!
    let formatterIn = dateFormatter(formatType: "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ")
    let formatterOut = dateFormatter(formatType: "yyyy-MM-dd HH:mm")
    var field: PostBody.Fields?
    var imgurUrl = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        
        var postDate = formatterOut.string(from: Date())
        
        if field != nil {
            nameTextField.text = field?.name
            articleTextView.text = field?.article
            
            postDate = formatterOut.string(from: formatterIn.date(from: field?.postDate ?? postDate) ?? Date())
            
            if let url = URL(string: (field?.image[0].url)!) {
                URLSession.shared.dataTask(with: url) { (data, response, error) in
                    if let data = data {
                        DispatchQueue.main.async {
                            self.imageButton.setBackgroundImage(UIImage(data: data), for: .normal)
                        }
                    }
                }.resume()
            }
        }
        dateLabel.text = postDate
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        nameTextField.endEditing(true)
        articleTextView.endEditing(true)
    }
    
    // MARK: - Table view data source
    /* controll from program
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 0
    }
    */
    
    /* controll from program
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 0
    }
    */
    
    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        
        let name = nameTextField.text ?? ""
        let postDate = dateLabel.text ?? ""
        let article = articleTextView.text ?? ""
        
        var imageUrl = ""
        //imageUrl = "https://i.imgur.com/by12Fcn.jpg"
        if imageButton.backgroundImage(for: .normal)?.isSymbolImage == false {
            imageUrl = imgurUrl
        }
        let image = [PostBody.imageData(url: imageUrl)]
        
        field = PostBody.Fields(name: name, postDate: postDate, image: image, article: article)
    }
    
    func uploadImgur(uiImage: UIImage) {
        
        if let apiKey = Bundle.main.object(forInfoDictionaryKey: "ImgurAPIKey") {
            let headers: HTTPHeaders = ["Authorization": "Client-ID \(apiKey)",]
        
            AF.upload(multipartFormData: { (data) in
                let imageData = uiImage.jpegData(compressionQuality: 0.9)
                data.append(imageData!, withName: "image")

            }, to: "https://api.imgur.com/3/image", headers: headers).responseDecodable(of: UploadImgurResult.self, queue: .main, decoder: JSONDecoder()) { (response) in
                
                /*print json data
                let json = try? JSONSerialization.jsonObject(with: response.data!, options: .allowFragments) as? [String:Any]
                print(json as Any)
                */
                switch response.result {
                case .success(let result):
                    //keep imgur url
                    self.imgurUrl = result.data.link
                    print(self.imgurUrl)
                case .failure(let error):
                    print(error)
                }
            }
        }
    }
    
    @IBAction func pickPhoto(_ sender: Any) {
        //choose source from
        let sourceAlertController = UIAlertController(title: "選擇照片來源", message: "", preferredStyle: .actionSheet)
        let imagePickerController = UIImagePickerController()
        let albumAction = UIAlertAction(title: "從相簿選", style: .default) { (UIAlertAction) in
            imagePickerController.sourceType = .photoLibrary
            imagePickerController.delegate = self
            self.present(imagePickerController, animated: true, completion: nil)
        }
        let cameraAction = UIAlertAction(title: "拍照", style: .default) { (UIAlertAction) in
            imagePickerController.sourceType = .camera
            imagePickerController.delegate = self
            self.present(imagePickerController, animated: true, completion: nil)
        }
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        sourceAlertController.addAction(albumAction)
        sourceAlertController.addAction(cameraAction)
        sourceAlertController.addAction(cancelAction)
        present(sourceAlertController, animated: true, completion: nil)
    }
    
}

extension PostTableViewController: UIImagePickerControllerDelegate {
    //finish picking photo and show
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        uploadImgur(uiImage: (info[.originalImage] as? UIImage)!)
        
        self.imageButton.setBackgroundImage(info[.originalImage] as? UIImage, for: .normal)
        dismiss(animated: true, completion: nil)
    }
}
