import SwiftUI
import Contacts

struct ContactsView: View {
    let windowState: WindowState
    @State private var contacts: [CNContact] = []
    @State private var selectedContact: CNContact?
    @State private var authorized = false
    @State private var searchText = ""

    private var filteredContacts: [CNContact] {
        if searchText.isEmpty { return contacts }
        return contacts.filter {
            "\($0.givenName) \($0.familyName)".localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        HStack(spacing: 0) {
            // Contact list
            VStack(spacing: 0) {
                // Search
                HStack {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 9))
                        .foregroundStyle(.secondary)
                    TextField("Search", text: $searchText)
                        .font(MacFonts.body)
                        .textFieldStyle(.plain)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)

                Divider()

                if !authorized {
                    VStack(spacing: 8) {
                        Image(systemName: "person.crop.circle")
                            .font(.system(size: 28))
                            .foregroundStyle(.secondary)
                        Button("Allow Access") { requestAccess() }
                            .buttonStyle(.borderedProminent)
                            .controlSize(.small)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    ScrollView {
                        LazyVStack(spacing: 0) {
                            ForEach(filteredContacts, id: \.identifier) { contact in
                                Button {
                                    selectedContact = contact
                                } label: {
                                    HStack(spacing: 6) {
                                        Circle()
                                            .fill(.blue.opacity(0.2))
                                            .frame(width: 22, height: 22)
                                            .overlay(
                                                Text(contactInitials(contact))
                                                    .font(.system(size: 8, weight: .medium))
                                                    .foregroundStyle(.blue)
                                            )
                                        Text("\(contact.givenName) \(contact.familyName)")
                                            .font(MacFonts.body)
                                            .lineLimit(1)
                                        Spacer()
                                    }
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 3)
                                    .background(
                                        selectedContact?.identifier == contact.identifier ?
                                        MacColors.sidebarSelection : .clear
                                    )
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                }
            }
            .frame(width: 180)
            .background(MacColors.sidebarBackground)

            Divider()

            // Detail
            if let contact = selectedContact {
                contactDetail(contact)
            } else {
                VStack {
                    Image(systemName: "person.crop.circle")
                        .font(.system(size: 36))
                        .foregroundStyle(.secondary)
                    Text("Select a contact")
                        .font(MacFonts.body)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .onAppear {
            windowState.title = "Contacts"
            requestAccess()
        }
    }

    // MARK: - Detail

    @ViewBuilder
    private func contactDetail(_ contact: CNContact) -> some View {
        ScrollView {
            VStack(spacing: 12) {
                // Avatar
                Circle()
                    .fill(.blue.opacity(0.15))
                    .frame(width: 50, height: 50)
                    .overlay(
                        Text(contactInitials(contact))
                            .font(.system(size: 18, weight: .medium))
                            .foregroundStyle(.blue)
                    )

                Text("\(contact.givenName) \(contact.familyName)")
                    .font(.system(size: 14, weight: .semibold))

                // Phone numbers
                ForEach(contact.phoneNumbers, id: \.identifier) { phone in
                    detailRow(
                        label: CNLabeledValue<NSString>.localizedString(forLabel: phone.label ?? "phone"),
                        value: phone.value.stringValue
                    )
                }

                // Emails
                ForEach(contact.emailAddresses, id: \.identifier) { email in
                    detailRow(label: "email", value: email.value as String)
                }
            }
            .padding(16)
            .frame(maxWidth: .infinity)
        }
    }

    @ViewBuilder
    private func detailRow(label: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label.lowercased())
                .font(.system(size: 9))
                .foregroundStyle(.secondary)
            Text(value)
                .font(.system(size: 11))
                .foregroundStyle(.blue)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func contactInitials(_ contact: CNContact) -> String {
        let first = contact.givenName.prefix(1)
        let last = contact.familyName.prefix(1)
        return "\(first)\(last)".uppercased()
    }

    private func requestAccess() {
        let store = CNContactStore()
        store.requestAccess(for: .contacts) { granted, _ in
            DispatchQueue.main.async {
                authorized = granted
                if granted { loadContacts() }
            }
        }
    }

    private func loadContacts() {
        let store = CNContactStore()
        let keys: [CNKeyDescriptor] = [
            CNContactGivenNameKey as CNKeyDescriptor,
            CNContactFamilyNameKey as CNKeyDescriptor,
            CNContactPhoneNumbersKey as CNKeyDescriptor,
            CNContactEmailAddressesKey as CNKeyDescriptor,
            CNContactIdentifierKey as CNKeyDescriptor,
        ]
        let request = CNContactFetchRequest(keysToFetch: keys)
        request.sortOrder = .givenName
        var fetched: [CNContact] = []
        try? store.enumerateContacts(with: request) { contact, _ in
            fetched.append(contact)
        }
        contacts = fetched
    }
}
