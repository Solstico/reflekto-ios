//
//  ViewController.swift
//  reflekto
//
//  Created by Michał Kwiecień on 11.02.2017.
//  Copyright © 2017 Solstico. All rights reserved.
//

import UIKit

class MainTestViewController: UITableViewController {

    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var timeIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var weatherLabel: UILabel!
    @IBOutlet weak var watherIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var greetingsLabel: UILabel!
    @IBOutlet weak var greetingsIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var nameIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var sexLabel: UILabel!
    @IBOutlet weak var sexIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var complimentLabel: UILabel!
    @IBOutlet weak var complimentIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var weatherAdditionalLabel: UILabel!
    @IBOutlet weak var weatherAdditionalIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var weatherAdviceLabel: UILabel!
    @IBOutlet weak var weatherAdviceIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var calendarLabel: UILabel!
    @IBOutlet weak var calendarIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var mailLabel: UILabel!
    @IBOutlet weak var mailIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var travelTimeLabel: UILabel!
    @IBOutlet weak var travelTimeIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refreshData()
    }
    
    private func refreshData() {
        showIndicators(true)
        DataInteractor.getTime(success: { value in
            timeIndicator.stopAnimating()
            timeLabel.text = value
        }) { error in
            timeIndicator.stopAnimating()
            timeLabel.text = error.localizedDescription
        }
        
    }
    
    private func showIndicators(_ show: Bool) {
        show ? timeIndicator.startAnimating() : timeIndicator.stopAnimating()
        show ? watherIndicator.startAnimating() : watherIndicator.stopAnimating()
        show ? greetingsIndicator.startAnimating() : greetingsIndicator.stopAnimating()
        show ? nameIndicator.startAnimating() : nameIndicator.stopAnimating()
        show ? sexIndicator.startAnimating() : sexIndicator.stopAnimating()
        show ? complimentIndicator.startAnimating() : complimentIndicator.stopAnimating()
        show ? weatherAdditionalIndicator.startAnimating() : weatherAdditionalIndicator.stopAnimating()
        show ? weatherAdviceIndicator.startAnimating() : weatherAdviceIndicator.stopAnimating()
        show ? calendarIndicator.startAnimating() : calendarIndicator.stopAnimating()
        show ? mailIndicator.startAnimating() : mailIndicator.stopAnimating()
        show ? travelTimeIndicator.startAnimating() : travelTimeIndicator.stopAnimating()
    }
    
    
    //MARK: Actions
    @IBAction func refreshDidTap(_ sender: Any) {
        refreshData()
    }
    

}

