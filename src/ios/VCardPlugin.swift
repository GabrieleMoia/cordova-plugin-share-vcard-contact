import Contacts

@objc(VCardPlugin) class VCardPlugin : CDVPlugin{
    // MARK: Properties
    var pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR)
    @objc(createVCard:) func createVCard(_ command: CDVInvokedUrlCommand) {
//         let contact = createContact()
        print(command.arguments[0])
//        do {
//            try shareContacts([contact])
//        }
//        catch {
//            // Handle error
//        }
    }
    
    func createContact() -> CNContact {

        // Creating a mutable object to add to the contact
        let contact = CNMutableContact()

//        contact.imageData = Data // The profile picture as a NSData object

        contact.givenName = "John"
        contact.familyName = "Appleseed"

        contact.phoneNumbers = [CNLabeledValue(
            label:CNLabelPhoneNumberiPhone,
            value:CNPhoneNumber(stringValue:"(408) 555-0126"))]

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

//        print("filename: \(filename)")
//        print("contact: \(String(data: data, encoding: String.Encoding.utf8))")

        try data.write(to: fileURL, options: [.atomicWrite])

        let activityViewController = UIActivityViewController(
            activityItems: [fileURL],
            applicationActivities: nil
        )

        self.viewController.present(activityViewController, animated: true, completion: {})
    }
}
