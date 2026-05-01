import SwiftUI
import MapKit

struct MapsView: View {
    let windowState: WindowState
    @State private var position = MapCameraPosition.automatic
    @State private var searchText = ""
    @State private var searchResults: [MKMapItem] = []

    var body: some View {
        VStack(spacing: 0) {
            // Search bar
            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 10))
                    .foregroundStyle(.secondary)
                TextField("Search Maps", text: $searchText)
                    .font(MacFonts.body)
                    .textFieldStyle(.plain)
                    .onSubmit { search() }
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(Color(white: 0.92))

            // Map
            Map(position: $position) {
                UserAnnotation()
                ForEach(searchResults, id: \.self) { item in
                    if let coord = item.placemark.location?.coordinate {
                        Marker(item.name ?? "", coordinate: coord)
                    }
                }
            }
            .mapControls {
                MapCompass()
                MapScaleView()
                MapUserLocationButton()
            }
        }
        .onAppear {
            windowState.title = "Maps"
            position = .region(MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: 10.8231, longitude: 106.6297),
                span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            ))
        }
    }

    private func search() {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = searchText
        MKLocalSearch(request: request).start { response, _ in
            searchResults = response?.mapItems ?? []
            if let first = searchResults.first?.placemark.location?.coordinate {
                position = .region(MKCoordinateRegion(
                    center: first,
                    span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                ))
            }
        }
    }
}
