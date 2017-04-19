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
    
    @IBOutlet weak var textfield: UITextField!
    
    let locManager = CLLocationManager()
    let bluetoothService = BluetoothServiceManager()
    var peripheralService: PeripheralBluetoothService?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locManager.requestAlwaysAuthorization()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refreshData()
    }
    
    private func connectToBLEDevice() {
        let deviceUUID = UUID(uuidString: "5A99E231-EE77-49D8-8B20-1D6BEE302B92")!
        let servicesUUIDs = [UUID(uuidString: "6E400001-B5A3-F393-E0A9-E50E24DCCA9E")!]
        let characteristicsUUIDs = [UUID(uuidString: "6E400002-B5A3-F393-E0A9-E50E24DCCA9E")!]
        
        bluetoothService.peripheralConnectionSuccess = { [weak self] peripheral in
            print("Jestem połączony z peripheralem: \(peripheral)")
            self?.peripheralService = PeripheralBluetoothService(withPeripheral: peripheral)
        }
        
        bluetoothService.peripheralConnectionFailure = { peripheral, error in
            print("Błąd łączenia z peripheralem: \(String(describing: peripheral)) \n błąd: \(String(describing: error))")
        }
        
        bluetoothService.peripheralDisconnected = { peripheral, error in
            print("Rozłączyłem się z peripheralem: \(String(describing: peripheral)) \n błąd: \(String(describing: error))")
        }
        
        bluetoothService.connectToMirror(withUUID: deviceUUID, serviceUUIDs: servicesUUIDs, characteristicsUUIDs: characteristicsUUIDs)
    }
    
    private func refreshData() {
        connectToBLEDevice()
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
        
        DataInteractor.getWeatherAdditional(success: { value in
            self.weatherAdditionalIndicator.stopAnimating()
            self.weatherAdditionalLabel.text = value
        }) { error in
            self.weatherAdditionalIndicator.stopAnimating()
            self.weatherAdditionalLabel.text = error.localizedDescription
        }
        
        DataInteractor.getWeatherAdvice(success: { value in
            self.weatherAdviceIndicator.stopAnimating()
            self.weatherAdviceLabel.text = value
        }) { error in
            self.weatherAdviceIndicator.stopAnimating()
            self.weatherAdviceLabel.text = error.localizedDescription
        }
        
        DataInteractor.getNextEvent(success: { value in
            self.calendarIndicator.stopAnimating()
            self.calendarLabel.text = value
        }) { error in
            self.calendarIndicator.stopAnimating()
            self.calendarLabel.text = error.localizedDescription
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
    
    @IBAction func sendTextFromTextfield(_ sender: Any) {
        peripheralService?.write(string: textfield.text)
    }
}

extension MainTestViewController {
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch indexPath.row {
        case 0:
            peripheralService?.write(string: "\(indexPath.row)0\(timeLabel.text ?? "")")
        case 1:
            peripheralService?.write(string: "\(indexPath.row)0\(weatherLabel.text ?? "")")
        case 2:
            peripheralService?.write(string: "\(indexPath.row)0\(greetingsLabel.text ?? "")")
        case 3:
            peripheralService?.write(string: "\(indexPath.row)0\(nameLabel.text ?? "")")
        case 4:
            peripheralService?.write(string: "\(indexPath.row)0\(sexLabel.text ?? "")")
        case 5:
            peripheralService?.write(string: "\(indexPath.row)0\(complimentLabel.text ?? "")")
        case 6:
            peripheralService?.write(string: "\(indexPath.row)0\(weatherAdditionalLabel.text ?? "")")
        case 7:
            peripheralService?.write(string: "\(indexPath.row)0\(weatherAdviceLabel.text ?? "")")
        case 8:
            peripheralService?.write(string: "\(indexPath.row)0\(calendarLabel.text ?? "")")
        case 9:
            peripheralService?.write(string: "\(indexPath.row)0\(mailLabel.text ?? "")")
        case 10:
            peripheralService?.write(string: "\(indexPath.row)0\(travelTimeLabel.text ?? "")")
        default:
            peripheralService?.write(string: "default")
        }
    }
    
}

