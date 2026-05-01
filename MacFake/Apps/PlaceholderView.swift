import SwiftUI

struct PlaceholderView: View {
    let app: FakeApp

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: app.iconName)
                .font(.system(size: 32))
                .foregroundStyle(app.iconColor)
            Text(app.displayName)
                .font(MacFonts.body)
                .foregroundStyle(MacColors.secondaryText)
            Text("Coming Soon")
                .font(MacFonts.bodySmall)
                .foregroundStyle(MacColors.tertiaryText)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
