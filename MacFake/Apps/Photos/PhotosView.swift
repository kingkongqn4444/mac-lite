import SwiftUI
import Photos

struct PhotosView: View {
    let windowState: WindowState
    @State private var assets: [PHAsset] = []
    @State private var selectedAsset: PHAsset?
    @State private var authorized = false
    @State private var selectedTab = "Library"

    private let columns = [GridItem(.adaptive(minimum: 60), spacing: 2)]

    var body: some View {
        HStack(spacing: 0) {
            // Sidebar
            VStack(alignment: .leading, spacing: 0) {
                sidebarSection("Library") {
                    sidebarItem("All Photos", icon: "photo.fill", tab: "Library")
                    sidebarItem("Recents", icon: "clock.fill", tab: "Recents")
                    sidebarItem("Favorites", icon: "heart.fill", tab: "Favorites")
                }
                sidebarSection("Media Types") {
                    sidebarItem("Videos", icon: "video.fill", tab: "Videos")
                    sidebarItem("Screenshots", icon: "camera.viewfinder", tab: "Screenshots")
                }
                Spacer()
            }
            .frame(width: 130)
            .background(MacColors.sidebarBackground)
            .padding(.top, 4)

            Divider()

            // Content
            if !authorized {
                permissionView
            } else if let selected = selectedAsset {
                detailView(selected)
            } else {
                gridView
            }
        }
        .onAppear {
            windowState.title = "Photos"
            requestAccess()
        }
    }

    // MARK: - Sidebar

    @ViewBuilder
    private func sidebarSection(_ title: String, @ViewBuilder content: () -> some View) -> some View {
        Text(title)
            .font(MacFonts.sidebarHeader)
            .foregroundStyle(MacColors.tertiaryText)
            .padding(.horizontal, 10)
            .padding(.top, 8)
            .padding(.bottom, 2)
        content()
    }

    @ViewBuilder
    private func sidebarItem(_ title: String, icon: String, tab: String) -> some View {
        Button {
            selectedTab = tab
            selectedAsset = nil
        } label: {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 10))
                    .frame(width: 14)
                Text(title).font(MacFonts.sidebar)
                Spacer()
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 3)
            .background(
                RoundedRectangle(cornerRadius: 4)
                    .fill(selectedTab == tab ? MacColors.sidebarSelection : .clear)
                    .padding(.horizontal, 4)
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Permission

    private var permissionView: some View {
        VStack(spacing: 12) {
            Image(systemName: "photo.on.rectangle.angled")
                .font(.system(size: 36))
                .foregroundStyle(.secondary)
            Text("Photos Access Required")
                .font(.system(size: 13, weight: .medium))
            Text("Allow access to view your photo library")
                .font(MacFonts.body)
                .foregroundStyle(.secondary)
            Button("Allow Access") { requestAccess() }
                .buttonStyle(.borderedProminent)
                .controlSize(.small)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Grid

    private var gridView: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 2) {
                ForEach(assets, id: \.localIdentifier) { asset in
                    PhotoThumbnail(asset: asset)
                        .onTapGesture { selectedAsset = asset }
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Detail

    private func detailView(_ asset: PHAsset) -> some View {
        VStack(spacing: 0) {
            HStack {
                Button {
                    selectedAsset = nil
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 10))
                    Text("Back")
                        .font(MacFonts.body)
                }
                .buttonStyle(.plain)
                Spacer()
            }
            .padding(6)

            PhotoFullView(asset: asset)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }

    // MARK: - Data

    private func requestAccess() {
        PHPhotoLibrary.requestAuthorization(for: .readWrite) { status in
            DispatchQueue.main.async {
                authorized = status == .authorized || status == .limited
                if authorized { loadPhotos() }
            }
        }
    }

    private func loadPhotos() {
        let options = PHFetchOptions()
        options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        options.fetchLimit = 200
        let result = PHAsset.fetchAssets(with: .image, options: options)
        var fetched: [PHAsset] = []
        result.enumerateObjects { asset, _, _ in fetched.append(asset) }
        assets = fetched
    }
}

// MARK: - Thumbnail

struct PhotoThumbnail: View {
    let asset: PHAsset
    @State private var image: UIImage?

    var body: some View {
        Group {
            if let img = image {
                Image(uiImage: img)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } else {
                Rectangle().fill(Color(white: 0.9))
            }
        }
        .frame(width: 60, height: 60)
        .clipped()
        .onAppear { loadThumbnail() }
    }

    private func loadThumbnail() {
        let options = PHImageRequestOptions()
        options.isSynchronous = false
        options.deliveryMode = .opportunistic
        PHImageManager.default().requestImage(
            for: asset,
            targetSize: CGSize(width: 120, height: 120),
            contentMode: .aspectFill,
            options: options
        ) { img, _ in
            image = img
        }
    }
}

// MARK: - Full View

struct PhotoFullView: View {
    let asset: PHAsset
    @State private var image: UIImage?

    var body: some View {
        Group {
            if let img = image {
                Image(uiImage: img)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            } else {
                ProgressView()
            }
        }
        .onAppear { loadFull() }
    }

    private func loadFull() {
        let options = PHImageRequestOptions()
        options.deliveryMode = .highQualityFormat
        PHImageManager.default().requestImage(
            for: asset,
            targetSize: CGSize(width: 800, height: 800),
            contentMode: .aspectFit,
            options: options
        ) { img, _ in
            image = img
        }
    }
}
