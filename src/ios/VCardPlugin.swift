import Contacts

@objc(VCardPlugin) class VCardPlugin : CDVPlugin{
    // MARK: Properties
    var pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR)
    @objc(createVCard:) func createVCard(_ command: CDVInvokedUrlCommand) {
        
        if let value = command.arguments[0] as? [String: String] {
            if let name = value["NOME"], let secondName = value["COGNOME"], let number = value["NUMERO_CELL"] {
                let contact = createContact(Contact(name: name, secondName: secondName, number: number))
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
        
        contact.phoneNumbers = [CNLabeledValue(
                                    label:CNLabelPhoneNumberiPhone,
                                    value:CNPhoneNumber(stringValue:value.number))]
        
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
    var number: String
}
