//
//  PDFHelper.swift
//  App
//
//  Created by Андрей Закржевский on 14/05/2019.
//

import Foundation

final class PDFHelper: NSObject {
    
    let pathToInvoiceHTMLTemplate = Bundle.main.path(forResource: "order_form_template", ofType: "html")
    
//    let pathToSingleItemHTMLTemplate = Bundle.main.path(forResource: "single_item", ofType: "html")
//
//    let pathToLastItemHTMLTemplate = Bundle.main.path(forResource: "last_item", ofType: "html")
    
    let fullName = "Andrei Zakrzhevskii"
    let jobName = "@andrei_sergeich"
    let eMail = "and.zak.one@gmail.com"
    let address = "Tolstogo, 56, 131"
    let city = "Novosibirsk"
    let state = "Novosibirsk oblast"
    let zip = "630008"
    let phone = "+79994665311"
    let scanner = "Noritsu HS-1800"
    let skinTones = "Neutral"
    let contrast = "Neutral"
    let bwContrast = "Neutral"
    let special = "Make it great!\nAs always."
    let expressScanning = "2-4 days + 100%"
    let receivedDate = "15.05.2019"
    var invoiceNumber: String!
    var pdfFilename: String!
//    #FULL_NAME#
//    #JOB_NAME#
//    #EMAIL#
//    #ADDRESS#
//    #CITY#
//    #STATE#
//    #ZIP#
//    #PHONE#
//    #SCANNER#
//    #SKIN_TONES#
//    #CONTRAST#
//    #BW_CONTRAST#
//    #EXPRESS_SCANNING#
//    #SPECIAL#
//    #RECEIVED_DATE#
//    #INVOICE_NUMBER#
    
//    let senderInfo = "Gabriel Theodoropoulos<br>123 Somewhere Str.<br>10000 - MyCity<br>MyCountry"
//
//    let dueDate = ""
//
//    let paymentMethod = "Wire Transfer"
//
//    let logoImageURL = "http://www.appcoda.com/wp-content/uploads/2015/12/blog-logo-dark-400.png"
//
//    var invoiceNumber: String!
//
//    var pdfFilename: String!
    
    override init() {
        super.init()
    }
    
    func renderPDF(invoiceNumber: String) -> String! {
        self.invoiceNumber = invoiceNumber
        
        do {
            // Load the invoice HTML template code into a String variable.
            var HTMLContent = try String(contentsOfFile: pathToInvoiceHTMLTemplate!)
            
            // Replace all the placeholders with real values except for the items.
            HTMLContent = HTMLContent.replacingOccurrences(of: "#FULL_NAME#", with: fullName)
            
            HTMLContent = HTMLContent.replacingOccurrences(of: "#INVOICE_NUMBER#", with: invoiceNumber)
            
            HTMLContent = HTMLContent.replacingOccurrences(of: "#RECEIVED_DATE#", with: receivedDate)
            
            HTMLContent = HTMLContent.replacingOccurrences(of: "#JOB_NAME#", with: jobName)
            
            HTMLContent = HTMLContent.replacingOccurrences(of: "#EMAIL#", with: eMail)
            
            HTMLContent = HTMLContent.replacingOccurrences(of: "#SPECIAL#", with: special.replacingOccurrences(of: "\n", with: "<br>"))
            
            HTMLContent = HTMLContent.replacingOccurrences(of: "#ADDRESS#", with: address)
            
            HTMLContent = HTMLContent.replacingOccurrences(of: "#CITY#", with: city)
            
            HTMLContent = HTMLContent.replacingOccurrences(of: "#STATE#", with: state)
            
            HTMLContent = HTMLContent.replacingOccurrences(of: "#ZIP#", with: zip)
            
            HTMLContent = HTMLContent.replacingOccurrences(of: "#PHONE#", with: phone)
            
            HTMLContent = HTMLContent.replacingOccurrences(of: "#SCANNER#", with: scanner)
            
            HTMLContent = HTMLContent.replacingOccurrences(of: "#SKIN_TONES#", with: skinTones)
            
            HTMLContent = HTMLContent.replacingOccurrences(of: "#CONTRAST#", with: contrast)
            
            HTMLContent = HTMLContent.replacingOccurrences(of: "#BW_CONTRAST#", with: bwContrast)
            
            HTMLContent = HTMLContent.replacingOccurrences(of: "#EXPRESS_SCANNING#", with: expressScanning)
            
            HTMLContent = HTMLContent.replacingOccurrences(of: "#SPECIAL#", with: special)
            
//            var allItems = ""
            
            // For all the items except for the last one we'll use the "single_item.html" template.
            // For the last one we'll use the "last_item.html" template.
//            for i in 0..<items.count {
//                var itemHTMLContent: String!
//
//                // Determine the proper template file.
////                if i != items.count - 1 {
////                    itemHTMLContent = try String(contentsOfFile: pathToSingleItemHTMLTemplate!)
////                }
////                else {
////                    itemHTMLContent = try String(contentsOfFile: pathToLastItemHTMLTemplate!)
////                }
//
//                // Replace the description and price placeholders with the actual values.
//                itemHTMLContent = itemHTMLContent.replacingOccurrences(of: "#ITEM_DESC#", with: items[i]["item"]!)
//
//                // Format each item's price as a currency value.
//                //let formattedPrice = AppDelegate.getAppDelegate().getStringValueFormattedAsCurrency(items[i]["price"]!)
//                itemHTMLContent = itemHTMLContent.replacingOccurrences(of: "#PRICE#", with: items[i]["price"]!)
//
//                // Add the item's HTML code to the general items string.
//                allItems += itemHTMLContent
//            }
            
            // Set the items.
//            HTMLContent = HTMLContent.replacingOccurrences(of: "#ITEMS#", with: allItems)
            
            // The HTML code is ready.
            return HTMLContent
            
        }
        catch {
            print("Unable to open and use HTML template files.")
        }
        
        return nil
    }
}
