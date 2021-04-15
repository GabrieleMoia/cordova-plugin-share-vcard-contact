import Contacts

@objc(VCardPlugin) class VCardPlugin : CDVPlugin{
    // MARK: Properties
    var pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR)
    @objc(createVCard:) func createVCard(_ command: CDVInvokedUrlCommand) {
        
        if let value = command.arguments[0] as? [String: Any] {
            if let name = value["NOME"] as? String, let secondName = value["COGNOME"] as? String {
                let contact = createContact(Contact(name: name, secondName: secondName, number: value["NUMERO_CELL"] as? String, email: value["MAIL_UTENTE"] as? String))
                do {
                    try shareContacts(contacts: [contact])
                }
                catch {
                    // Handle error
                }
            }
        }
    }
    
    func createContact(_ value: Contact) -> CNContact {
        
        // Creating a mutable object to add to the contact
        let contact = CNMutableContact()
        
        contact.givenName = value.name
        contact.familyName = value.secondName
        if let number = value.number {
            contact.phoneNumbers = [CNLabeledValue(
                                        label:CNLabelPhoneNumberiPhone,
                                        value:CNPhoneNumber(stringValue: number))]
            
        }
        if let email = value.email {
            let workEmail = CNLabeledValue(label:CNLabelWork, value: email as NSString)
            contact.emailAddresses = [workEmail]
        }
        
        return contact
    }
    
    func shareContacts(contacts: [CNContact]) throws {
        
        guard let directoryURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first else {
            return
        }
        
        var filename = NSUUID().uuidString
        
        // Create a human friendly file name if sharing a single contact.
        if let contact = contacts.first, contacts.count == 1 {
            
            if let fullname = CNContactFormatter().string(from: contact) {
                filename = fullname.components(separatedBy: " ").joined(separator: "")
            }
        }
        
        let fileURL = directoryURL
            .appendingPathComponent(filename)
            .appendingPathExtension("vcf")
        
        let data = try CNContactVCardSerialization.data(with: contacts)
        
        try data.write(to: fileURL, options: [.atomicWrite])
        
        let activityViewController = UIActivityViewController(
            activityItems: [fileURL],
            applicationActivities: nil
        )
        
        self.viewController.present(activityViewController, animated: true, completion: {})
    }
}

struct Contact {
    var name: String
    var secondName: String
    var number: String?
    var email: String?
}
