import SwiftUI

//class RadioStationData: ObservableObject {
//    @Published var radioStations: [RadioStation] = []
//    @Published var searchQuery = ""
//}

struct RadioStationsView: View {
    @Environment(\.colorScheme) var colorScheme

    //    @State private var searchQuery: String = ""
    @ObservedObject var radioStationsData = RadioStationData()
    @State private var showNoStationFound = false
    @State private var showingWebView = false
    @State private var searching = false
    @State private var isError = false

//    @State private var showingActionSheet = false
//    @AppStorage("selectedStationData") private var selectedStationData: Data?
//    var selectedStation: RadioStation? {
//        get {
//            if let data = selectedStationData {
//                let decoder = JSONDecoder()
//                if let station = try? decoder.decode(RadioStation.self, from: data) {
//                    return station
//                }
//            }
//            return nil
//        }
//        set {
//            if let station = newValue {
//                let encoder = JSONEncoder()
//                if let data = try? encoder.encode(station) {
//                    selectedStationData = data
//                }
//            } else {
//                selectedStationData = nil
//            }
//        }
//    }

//    @AppStorage("showingActionSheet") private var showingActionSheet = false

    private var localStations = false
    private var country = ""
    private var state = ""
    private var genre = ""
    private var gradientLight: Gradient!
    private var gradientDark: Gradient!
    private var title = ""

    @Environment(\.presentationMode) private var presentationMode
    var onDone: (RadioStation) -> Void

    init(genre: String = "", colors: [Color]? = nil, localStations: Bool = false, country: String = "", state: String = "", onDone: @escaping (RadioStation) -> Void) {
        self.onDone = onDone
        self.localStations = localStations
        self.country = country
        self.state = state
        self.genre = genre
        var colors = colors == nil ? [.blue, .purple] : colors!
        colors = [Color.adaptiveBlack] + colors
        self.gradientLight = Gradient(colors: colors)
        self.gradientDark =  Gradient(stops: [
            .init(color: colors[0], location: 0),
            .init(color: colors[1], location: 0.4),
            .init(color: colors[2], location: 1)
        ])

        switch true {
            case localStations: title = "Local Stations"
            case genre.contains(" Stations") :
                title = genre
                self.genre = ""
            default: title = genre + " Stations"
        }

//        NotificationCenter.default.addObserver(forName: UIApplication.willResignActiveNotification, object: nil, queue: .main) { _ in
//            radioStationsData.showingActionSheet = true
//        }
    }

    var body: some View {
        ZStack {
            LinearGradient(gradient: colorScheme == .light ? gradientLight : gradientDark, startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
            if searching {
                ProgressView()
                    .scaleEffect(2)
                    .progressViewStyle(CircularProgressViewStyle(tint: .purple))
            }

            VStack (alignment: .leading) {
                HStack {
                    TextField("Search Text", text: $radioStationsData.searchQuery, onCommit: {
                        if localStations {
                        }
                        searchRadioStations(genre, country, state)
                    })
                    .padding(5)
                    .background(Color.clear)
                    .foregroundColor(.purple)
                    .padding(.horizontal)

                    if showNoStationFound {
                        Text("No station found")
                    }
                    Button(action: {
                        searchRadioStations(genre, country, state)
                    }) {
                        Image(systemName: "magnifyingglass") // replace with your custom image name if any
                            .foregroundColor(.purple)
                    }
                    .padding(.trailing)
                }
                ScrollView {
                    VStack(alignment: .leading) {
                        ForEach(radioStationsData.radioStations, id: \.self) { station in
                            Button(action: {
                                radioStationsData.selectedStation = station
                                radioStationsData.showingActionSheet = true
//                                fetchAndDisplayTermsAndConditions(url: station.homepage!) { termsAndConditions in
//                                    // Display the terms and conditions to the user and ask for their approval.
//                                    // If they approve, then:
//                                    onDone(station)
//                                    presentationMode.wrappedValue.dismiss()
//                                }
//                                onDone(station)
//                                presentationMode.wrappedValue.dismiss()
                            }) {
                                HStack {
                                    if let urlString = station.favicon {
                                        AsyncImage(url: urlString)
                                            .frame(width: 60, height: 60) // Adjust the size as needed
                                    }
                                    HStack {
                                        VStack(alignment: .leading) {
                                            Text(station.name)
                                                .font(.headline)
                                            Text(station.country ?? "")
                                                .font(.subheadline)
                                                .foregroundColor(.secondary)
                                        }
                                    }
                                    .padding() // Padding around the text
                                    .background(RoundedRectangle(cornerRadius: 10)
                                        .fill(Color.adaptiveBlack.opacity(0.5)))
                                }
                            }
                        }
                        .padding(.horizontal, 10)
                    }
                }
            }
        }
        .actionSheet(isPresented: $radioStationsData.showingActionSheet) {
            ActionSheet(title: Text("Terms and Conditions\n\(radioStationsData.selectedStation?.name ?? "")"),
                        message: Text("By selecting this station, you agree to the station's terms and conditions. You can also visit the station's website for more information."),
                        buttons: [
                            .default(Text("Agree")) {
                                onDone(radioStationsData.selectedStation!)
                                presentationMode.wrappedValue.dismiss()
                            },
                            .default(Text("Go to station's site")) {
//                                if let url = URL(string: radioStationsData.selectedStation?.homepage ?? "") {
//                                    UIApplication.shared.open(url)
//                                }
                                showingWebView = true
                            },
                            .cancel(Text("Disagree"))
                        ])
        }
//        .alert(isPresented: $showingAlert) {
//            Alert(title: Text("Terms and Conditions"),
//                  message: Text("By selecting this station, you agree to the station's terms and conditions."),
//                  primaryButton: .default(Text("Agree")) {
//                onDone(selectedStation!)
//                presentationMode.wrappedValue.dismiss()
//            },
//              secondaryButton: .cancel(Text("Disagree")))
//        }
//        .navigationBarTitle(title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text(title)
                    .font(.headline)
            }
        }
        .environment(\.layoutDirection, .leftToRight)
        .onAppear {
            if localStations && !country.isEmpty
                || !genre.isEmpty {
                searchRadioStations(genre, country, state)
            }
        }
        .sheet(isPresented: $showingWebView) {
            if let selectedStation = radioStationsData.selectedStation,
               let homepage = selectedStation.homepage,
               let url = URL(string: homepage) {
                WebView(url: url, isError: $isError)
                    .onDisappear {
                        radioStationsData.showingActionSheet = true
                    }
                    .alert(isPresented: $isError) {
                        Alert(title: Text("Error"), message: Text("Failed to load webpage"), dismissButton: .default(Text("OK")))
                    }
            }
        }
//        .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
//            if radioStationsData.showingActionSheet {
//                // Re-present the alert or perform some other action.
//            }
//        }
    }

    func searchRadioStations(_ genre: String = "", _ country: String = "", _ state: String = "") {
        searching = true
        if !genre.isEmpty && !radioStationsData.searchQuery.contains(genre) {
            radioStationsData.searchQuery = genre + " " + radioStationsData.searchQuery
        }
        fetchRadioStations(genre: genre, name: radioStationsData.searchQuery, country: country, state: state) { stations in
            searching = false
            radioStationsData.radioStations = stations
            showNoStationFound = false
            if stations.count == 0 {
                showNoStationFound = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    showNoStationFound = false
                }
            }
        }
    }
    //    func searchRadioStations(_ genre: String = "", _ country: String = "", _ state: String = "") {
    //        searching = true
    //        if !genre.isEmpty && !searchQuery.contains(genre) {
    //            searchQuery = genre + " " + searchQuery
    //        }
    //        fetchRadioStations(genre: genre, name: searchQuery, country: country, state: state) { stations in
    //            searching = false
    //            radioStations = stations
    //            showNoStationFound = false
    //            if stations.count == 0 {
    //                showNoStationFound = true
    //                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
    //                    showNoStationFound = false
    //                }
    //            }
    //        }
    //    }
}

