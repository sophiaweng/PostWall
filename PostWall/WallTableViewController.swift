//
//  WallTableViewController.swift
//  PostWall
//
//  Created by 翁淑惠 on 2020/12/22.
//

import UIKit

class WallTableViewController: UITableViewController {
    
    var posts = [PostBody.Record]()
    let formatterIn = dateFormatter(formatType: "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ")
    let formatterOut = dateFormatter(formatType: "yyyy-MM-dd HH:mm")
    
    func fetchPosts() {
        if let apiKey = Bundle.main.object(forInfoDictionaryKey: "AirtableAPIKey"),
           let url = URL(string: "https://api.airtable.com/v0/app1ir0SiD4zmC8zt/PostWall?sort[][field]=postDate&sort[][direction]=desc") {
            
            var request = URLRequest(url: url)
            request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
            
            URLSession.shared.dataTask(with: request) { (data, response, error) in
                
                if let data = data,
                   let content = String(data: data, encoding: .utf8) {
                    let decoder = JSONDecoder()
                    do {
                        print(content)
                        
                        let result = try decoder.decode(PostBody.self, from: data)
                        self.posts = result.records
                        
                        DispatchQueue.main.async {
                            self.tableView.reloadData()
                        }
                    } catch {
                        print(error)
                    }
                }
            }.resume()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchPosts()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return posts.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "\(WallTableViewCell.self)", for: indexPath) as! WallTableViewCell

        // Configure the cell
        let post = posts[indexPath.row]
        
        cell.nameLabel.text = post.fields.name
        cell.articleLabel.text = post.fields.article
        
        let postDate = formatterOut.string(from: formatterIn.date(from: post.fields.postDate) ?? Date())
        cell.dateLabel.text = postDate
        
        cell.imgImageView.image = UIImage(systemName: "photo")
        if let url = URL(string: post.fields.image[0].url) {
            URLSession.shared.dataTask(with: url) { (data, response, error) in
                if let data = data {
                    DispatchQueue.main.async {
                        cell.imgImageView.image = UIImage(data: data)
                    }
                }
            }.resume()
        }
        
        return cell
    }
    

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
        if let controller = segue.destination as? PostTableViewController,
           let row = tableView.indexPathForSelectedRow?.row {
            
            controller.field = posts[row].fields
        }
    }
    
    
    @IBAction func unwindToWallTableView(_ unwindSegue: UIStoryboardSegue) {
        if let sourceViewController = unwindSegue.source as? PostTableViewController,
           let field = sourceViewController.field {
            
            let postDate = formatterOut.string(from: Date())
            let postBody = PostBody(records: [.init(fields: .init(name: field.name, postDate: postDate, image: field.image, article: field.article))])
            
            /* TODO
            if let indexPath = tableView.indexPathForSelectedRow {
                //update
            //insert
            } else {
                //insert
            }
            */
            uploadPostData(postBody: postBody)
            
            //fetchPosts()
            posts.insert(contentsOf: postBody.records, at: 0)
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
            
        }
        // Use data from the view controller which initiated the unwind segue
        
    }
    
    func uploadPostData(postBody: PostBody) {
        if let apiKey = Bundle.main.object(forInfoDictionaryKey: "AirtableAPIKey"),
           let url = URL(string: "https://api.airtable.com/v0/app1ir0SiD4zmC8zt/PostWall") {
        
            var request = URLRequest(url: url)
            request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            let encoder = JSONEncoder()
            request.httpBody = try? encoder.encode(postBody)
            
            URLSession.shared.dataTask(with: request) { (data, response, error) in
                if let data = data,
                   let content = String(data: data, encoding: .utf8) {
                    print(content)
                }
            }.resume()
        }
    }

}
