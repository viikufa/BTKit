//
//  ConnectableViewController.swift
//  BTKitTester
//
//  Created by Rinat Enikeev on 9/12/19.
//  Copyright © 2019 Rinat Enikeev. All rights reserved.
//

import UIKit
import BTKit
import CoreBluetooth

class ConnectableViewController: UITableViewController {
    var ruuviTag: RuuviTag!
    
    @IBOutlet weak var uuidOrMacLabel: UILabel!
    @IBOutlet weak var connectButton: UIButton!
    @IBOutlet weak var readButton: UIButton!
    
    var isConnected: Bool = false { didSet { updateUIIsConnected() } }
    var isReading: Bool = false { didSet { updateUIIsReading() } }
    
    private var values = [(Date,Double)]()
    private var connectToken: ObservationToken?
    private var readToken: ObservationToken?
    private let cellReuseIdentifier = "ConnectableTableViewCellReuseIdentifier"
    private lazy var timeFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "HH:mm:ss"
        return df
    }()
    
    deinit {
        connectToken?.invalidate()
        readToken?.invalidate()
    }
}

// MARK: - IBActions
extension ConnectableViewController {
    @IBAction func connectButtonTouchUpInside(_ sender: Any) {
        connectToken?.invalidate()
        connectToken = BTKit.scanner.connect(self, uuid: ruuviTag.uuid, connected: { (observer) in
            observer.isConnected = true
        }) { (observer) in
            observer.isConnected = false
        }
    }
    
    @IBAction func readButtonTouchUpInside(_ sender: Any) {
        if let from = Calendar.current.date(byAdding: .hour, value: -5, to: Date()) {
            readToken?.invalidate()
            isReading = true
            readToken = ruuviTag.celisus(for: self, from: from) { [weak self] (result) in
                self?.isReading = false
                self?.readToken?.invalidate()
                switch result {
                case .success(let values):
                    self?.values = values
                    self?.tableView.reloadData()
                case .failure(let error):
                    print(error)
                }
            }
        }
    }
}

// MARK: - View lifecycle
extension ConnectableViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        updateUI()
    }
}

// MARK: - UITableViewDataSource
extension ConnectableViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return values.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier, for: indexPath) as! ConnectableTableViewCell
        let value = values[indexPath.row]
        cell.timeLabel.text = timeFormatter.string(from: value.0)
        cell.valueLabel.text = String(format: "%0.2f", value.1)
        return cell
    }
}

// MARK: - Update UI
extension ConnectableViewController {
    private func updateUI() {
        updateUIUUIDOrMAC()
        updateUIIsConnected()
        updateUIIsReading()
    }
    
    private func updateUIUUIDOrMAC() {
        if isViewLoaded {
            uuidOrMacLabel.text = ruuviTag.mac ?? ruuviTag.uuid
        }
    }
    
    private func updateUIIsConnected() {
        if isViewLoaded {
            connectButton.isEnabled = !isConnected
            readButton.isEnabled = isConnected
        }
    }
    
    private func updateUIIsReading() {
        if isViewLoaded {
            readButton.isEnabled = !isReading && isConnected
        }
    }
}
