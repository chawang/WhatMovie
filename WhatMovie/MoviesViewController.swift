//
//  MoviesViewController.swift
//  WhatMovie
//
//  Created by Charles Wang on 10/15/16.
//  Copyright © 2016 Charles Wang. All rights reserved.
//

import UIKit
import AFNetworking
import NVActivityIndicatorView

class MoviesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, NVActivityIndicatorViewable {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var networkStatusLabel: UILabel!
    var movies: [NSDictionary]?
    var endpoint: String!
    var networkConnected: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshControlAction(refreshControl:)), for: UIControlEvents.valueChanged)
        tableView.insertSubview(refreshControl, at: 0)
        
        self.networkStatusLabel.isHidden = self.networkConnected
        NVActivityIndicatorView.DEFAULT_TYPE = .ballTrianglePath
        startAnimating()
        
        let apiKey = "751b0b5a3f40d505720913f64e3e9a66"
        let urlstring = URL(string:"https://api.themoviedb.org/3/movie/" + endpoint + "?api_key=\(apiKey)&language=en-US")
        let request = URLRequest(url: urlstring!)
        let session = URLSession(
            configuration: URLSessionConfiguration.default,
            delegate:nil,
            delegateQueue:OperationQueue.main
        )
        
        let task : URLSessionDataTask = session.dataTask(with: request,completionHandler: { (dataOrNil, response, error) in
            if let data = dataOrNil {
                if let responseDictionary = try! JSONSerialization.jsonObject(with: data, options:[]) as? NSDictionary {
                    NSLog("response: \(responseDictionary)")
                    
                    self.movies = responseDictionary["results"] as? [NSDictionary]
                    self.tableView.reloadData()
                    self.stopAnimating()
                    self.networkConnected = true
                    self.networkStatusLabel.isHidden = self.networkConnected
                }
            } else {
                self.networkConnected = false
                self.networkStatusLabel.isHidden = self.networkConnected
                self.stopAnimating()
            }
        });
        task.resume()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int)
        -> Int {
        if let movies = movies {
            return movies.count
        } else {
            return 0
        }
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath)
        -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MovieCell", for: indexPath) as! MovieCell
        
        let movie = movies![indexPath.row]
            
        let title = movie["title"] as? String
        let overview = movie["overview"] as? String
        cell.movieTitle.text = title
        cell.movieOverview.text = overview
            
        let baseURL = "https://image.tmdb.org/t/p/w500"
        if let posterPath = movie["poster_path"] as? String {
        let posterURL = URL(string: baseURL + posterPath)
        cell.posterView.setImageWith(posterURL!)
        }
        
        print(title)
            
        return cell
    }

    func refreshControlAction(refreshControl: UIRefreshControl) {
        let apiKey = "751b0b5a3f40d505720913f64e3e9a66"
        let urlstring = URL(string:"https://api.themoviedb.org/3/movie/" + endpoint + "?api_key=\(apiKey)&language=en-US")
        let request = URLRequest(url: urlstring!)
        let session = URLSession(
            configuration: URLSessionConfiguration.default,
            delegate:nil,
            delegateQueue:OperationQueue.main
        )
        
        let task : URLSessionDataTask = session.dataTask(with: request,completionHandler: { (dataOrNil, response, error) in
            if let data = dataOrNil {
                if let responseDictionary = try! JSONSerialization.jsonObject(with: data, options:[]) as? NSDictionary {
                    NSLog("response: \(responseDictionary)")
                    
                    self.movies = responseDictionary["results"] as? [NSDictionary]
                    self.tableView.reloadData()
                    self.networkConnected = true
                    self.networkStatusLabel.isHidden = self.networkConnected
                }
            } else {
                self.networkConnected = false
                self.networkStatusLabel.isHidden = self.networkConnected
            }
            refreshControl.endRefreshing()
        });
        task.resume()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        let cell = sender as! UITableViewCell
        let indexPath = tableView.indexPath(for: cell)
        let movie = movies![indexPath!.row]
        
        let detailViewController = segue.destination as! DetailViewController
        
        detailViewController.movie = movie
    }
}
