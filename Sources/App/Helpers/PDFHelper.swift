//
//  PDFHelper.swift
//  App
//
//  Created by Андрей Закржевский on 14/05/2019.
//

import Foundation
import Vapor
import wkhtmltopdf

final class PDFHelper: NSObject {
    
    
    
//    let pathToSingleItemHTMLTemplate = Bundle.main.path(forResource: "single_item", ofType: "html")
//
//    let pathToLastItemHTMLTemplate = Bundle.main.path(forResource: "last_item", ofType: "html")
    
//    let fullName = "Andrei Zakrzhevskii"
//    let jobName = "@andrei_sergeich"
//    let eMail = "and.zak.one@gmail.com"
//    let address = "Tolstogo, 56, 131"
//    let city = "Novosibirsk"
//    let state = "Novosibirsk oblast"
//    let zip = "630008"
//    let phone = "+79994665311"
//    let scanner = "Noritsu HS-1800"
//    let skinTones = "Neutral"
//    let contrast = "Neutral"
//    let bwContrast = "Neutral"
//    let special = "Make it great!\nAs always."
//    let expressScanning = "2-4 days + 100%"
//    let receivedDate = "15.05.2019"
//    var invoiceNumber: String!
//    var pdfFilename: String!
    
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
    
    func renderPDF(invoiceNumber: String,
                   receivedDate: Date,
                   eMail: String,
                   fullName: String,
                   jobName: String,
                   special: String,
                   address: String,
                   city: String,
                   state: String,
                   zip: String,
                   phone: String,
                   scanner: String,
                   skinTones: String,
                   contrast: String,
                   bwContrast: String,
                   expressScanning: String
                   ) -> String {
//        let pathToInvoiceHTMLTemplate = Bundle.main.url(forResource: "order_form_template", withExtension: "html")
//        self.invoiceNumber = invoiceNumber
        
        do {
            let directory = DirectoryConfig.detect()
            let configDir = "Resources"
            
            let fileURL = URL(fileURLWithPath: directory.workDir)
                .appendingPathComponent(configDir, isDirectory: true)
                .appendingPathComponent("order_form_template.html", isDirectory: false)
            
//            if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
//            if fileURL {
            //reading
                //let fileURL = dir.appendingPathComponent("order_form_template.html")
                
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd.MM.yyyy"
            let receivedDateFormatted = dateFormatter.string(from: receivedDate)
                
            var HTMLContent = try String(contentsOf: fileURL, encoding: .utf8)
                
//            HTMLContent = HTMLContent.replacingOccurrences(of: "\'", with: "\\\'")
            HTMLContent = HTMLContent.replacingOccurrences(of: "<", with: "&lt;")
            HTMLContent = HTMLContent.replacingOccurrences(of: ">", with: "&gt;")
            HTMLContent = HTMLContent.replacingOccurrences(of: "'", with: "&#39;")
            
            
            
            HTMLContent = HTMLContent.replacingOccurrences(of: "#FULL_NAME#", with: fullName)
            
            HTMLContent = HTMLContent.replacingOccurrences(of: "#INVOICE_NUMBER#", with: invoiceNumber)
            
            HTMLContent = HTMLContent.replacingOccurrences(of: "#RECEIVED_DATE#", with: receivedDateFormatted)
                
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
            
            return HTMLContent
//            }
        }
        catch {
            print("Unable to open and use HTML template files.")
        }
        return ""
    }
}
