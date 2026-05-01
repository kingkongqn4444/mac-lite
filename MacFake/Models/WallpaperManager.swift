import SwiftUI
import Photos

@Observable
final class WallpaperManager {
    var wallpaperImage: UIImage? {
        didSet { saveToDisk() }
    }

    private static let storageKey = "macfake_wallpaper"

    init() {
        loadFromDisk()
    }

    func setWallpaper(from asset: PHAsset) {
        let options = PHImageRequestOptions()
        options.deliveryMode = .highQualityFormat
        options.isSynchronous = false
        PHImageManager.default().requestImage(
            for: asset,
            targetSize: CGSize(width: 1200, height: 800),
            contentMode: .aspectFill,
            options: options
        ) { image, _ in
            DispatchQueue.main.async {
                self.wallpaperImage = image
            }
        }
    }

    func resetToDefault() {
        wallpaperImage = nil
        try? FileManager.default.removeItem(at: Self.wallpaperFileURL)
    }

    // MARK: - Persistence

    private static var wallpaperFileURL: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("wallpaper.jpg")
    }

    private func saveToDisk() {
        guard let image = wallpaperImage,
              let data = image.jpegData(compressionQuality: 0.8) else { return }
        try? data.write(to: Self.wallpaperFileURL)
    }

    private func loadFromDisk() {
        guard let data = try? Data(contentsOf: Self.wallpaperFileURL),
              let image = UIImage(data: data) else { return }
        wallpaperImage = image
    }
}
