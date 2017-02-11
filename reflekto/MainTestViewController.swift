//
//  ViewController.swift
//  reflekto
//
//  Created by Michał Kwiecień on 11.02.2017.
//  Copyright © 2017 Solstico. All rights reserved.
//

import UIKit
import CoreLocation

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
    
    let locManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locManager.requestAlwaysAuthorization()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refreshData()
    }
    
    private func refreshData() {
        showIndicators(true)
        
        DataInteractor.getTime(success: { value in
            self.timeIndicator.stopAnimating()
            self.timeLabel.text = value
        }) { error in
            self.timeIndicator.stopAnimating()
            self.timeLabel.text = error.localizedDescription
        }
        
        DataInteractor.getWeather(success: { value in
            self.watherIndicator.stopAnimating()
            self.weatherLabel.text = value
        }) { error in
            self.watherIndicator.stopAnimating()
            self.weatherLabel.text = error.localizedDescription
        }
        
        DataInteractor.getName(success: { value in
            self.nameIndicator.stopAnimating()
            self.nameLabel.text = value
        }) { error in
            self.nameIndicator.stopAnimating()
            self.nameLabel.text = error.localizedDescription
        }
        
        DataInteractor.getSex(success: { value in
            self.sexIndicator.stopAnimating()
            self.sexLabel.text = value
        }) { error in
            self.sexIndicator.stopAnimating()
            self.sexLabel.text = error.localizedDescription
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
        if show {
            timeLabel.text = nil
            weatherLabel.text = nil
            greetingsLabel.text = nil
            nameLabel.text = nil
            sexLabel.text = nil
            complimentLabel.text = nil
            weatherAdditionalLabel.text = nil
            weatherAdviceLabel.text = nil
            calendarLabel.text = nil
            mailLabel.text = nil
            travelTimeLabel.text = nil
        }
    }
    
    
    //MARK: Actions
    @IBAction func refreshDidTap(_ sender: Any) {
        refreshData()
    }
    

}

