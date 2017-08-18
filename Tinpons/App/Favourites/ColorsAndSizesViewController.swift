//
//  ColorsAndSizesViewController.swift
//  WeGoLoco
//
//  Created by Dirk Hornung on 10/8/17.
//
//

import UIKit
import Eureka
import Whisper

let colorDictionary = ["Azul" : #colorLiteral(red: 0.01680417731, green: 0.1983509958, blue: 1, alpha: 1), "Negro" : #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1), "Rojo" : #colorLiteral(red: 1, green: 0.1491314173, blue: 0, alpha: 1)]

class ColorsAndSizesViewController: FormViewController, LoadingAnimationProtocol {
    
    // MARK: LoadingAnimationProtocol
    var loadingAnimationView: UIView!
    var loadingAnimationOverlay: UIView!
    var loadingAnimationIndicator: UIActivityIndicatorView!
    
    var tinpon: Tinpon!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadingAnimationView = navigationController?.view
    
        tableView.isEditing = false
        
        // Sizes
        sizeSection(category: tinpon.category!)
        
        // Colors
        form +++ SelectableSection<ListCheckRow<String>>("Colores", selectionType: .multipleSelection) { $0.tag = "colorSection" }
        let colors = ["negro", "azul", "rojo"]
        for option in colors {
            form.last! <<< ListCheckRow<String>(option){ listRow in
                listRow.title = option
                listRow.selectableValue = option
                listRow.value = nil
                }.cellUpdate { cell, row in
                    let color = colorDictionary[row.title!]
                    cell.tintColor = color
                    cell.textLabel?.textColor = color
            }
        }

        
        form +++ Section("") {
            $0.tag = "Continuar"
            }
            <<< ButtonRow() {
                $0.title = "Continuar"
                }.cellSetup { buttonCell, _ in
                    buttonCell.tintColor = #colorLiteral(red: 0, green: 0.8166723847, blue: 0.9823040366, alpha: 1)
                }.onCellSelection{[weak self] buttonCell, row in
                    guard let strongSelf = self else { return }
                    
                    let sizeSection = strongSelf.form.sectionBy(tag: "sizeSection") as! SelectableSection<ListCheckRow<String>>
                    let selectedSizes = sizeSection.selectedRows()
                    let colorSection = strongSelf.form.sectionBy(tag: "colorSection") as! SelectableSection<ListCheckRow<String>>
                    let selectedColors = colorSection.selectedRows()

                    if selectedSizes.count > 0 && selectedColors.count > 0 {
                        strongSelf.addSizesAndColorsToTinpon(selectedSizes, colors: selectedColors)
                        strongSelf.performSegue(withIdentifier: "segueToQuantities", sender: self)
                    } else {
                        let message = Message(title: "Hay que seleccionar tamaños y colores.", backgroundColor: .red)
                        Whisper.show(whisper: message, to: strongSelf.navigationController!, action: .show)
                    }
        }
    }
    
    fileprivate func addSizesAndColorsToTinpon(_ sizes: [ListCheckRow<String>], colors: [ListCheckRow<String>]) {
        for colorRow in colors {
            let color = Color(spanishName: colorRow.selectableValue!)
            var sizeVariations = Array<SizeVariation>()
            for sizeRow in sizes {
                let sizeVariation = SizeVariation(size: sizeRow.selectableValue!, quantity: 0)
                sizeVariations.append(sizeVariation)
            }
            let colorVariation = ColorVariation(sizeVariations: sizeVariations, images: [TinponImage]())
            tinpon.productVariations[color] = colorVariation
        }
    }
    
    // MARK: - Helper
    private func sizeSection(category: String) {
        switch category {
        case "👕":
            let sizes = Sizes.dictionary[category] as! [String]
            form +++ SelectableSection<ListCheckRow<String>>("\(category) Tamaños", selectionType: .multipleSelection) { $0.tag = "sizeSection" }
            for option in sizes {
                form.last! <<< ListCheckRow<String>(option){ listRow in
                    listRow.title = option
                    listRow.selectableValue = option
                    listRow.value = nil
                }
            }
        case "👖":
            let sizes = Sizes.dictionary[category] as! [String : [Int]]
            form +++ Section("\(category) Tamaños")
            for size in sizes["width"]! {
                form.last! <<< MultipleSelectorRow<Int>() {
                    $0.title = "\(size) x "
                    $0.options = sizes["length"]!
                    }
                    .onPresent { from, to in
                        to.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: from, action: #selector(ColorsAndSizesViewController.multipleSelectorDone(_:)))
                }
            }
        case "👞":
            let sizes = Sizes.dictionary[category] as! [Int]
            form +++ SelectableSection<ListCheckRow<Int>>("\(category) Tamaños", selectionType: .multipleSelection) { $0.tag = "sizeSection" }
            for option in sizes {
                form.last! <<< ListCheckRow<Int>{ listRow in
                    listRow.title = "\(option)"
                    listRow.selectableValue = option
                    listRow.value = nil
                }
            }
        default: ()
        }
    }
    
    func multipleSelectorDone(_ item:UIBarButtonItem) {
        _ = navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let quantitiesViewController = segue.destination as! QuantitiesViewController
        quantitiesViewController.tinpon = self.tinpon
    }
}
