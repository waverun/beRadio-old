//
//  Full programs view.swift
//  beRadio
//
//  Created by Shay  on 19/03/2023.
//

import Foundation
import SwiftUI
import CoreData

struct ProgramNavLink: View {

    var label: String
    var link: String
    var imageUrl: String?
    var color : UIColor = .gray

    @Binding private var audioUrl: URL
    @Binding private var imageSrc: String?
    @Binding private var heading: String
    @Binding private var isLive: Bool

    init(label: String, link: String, imageUrl: String? = nil, color: UIColor = .gray, audioUrl: Binding<URL>, imageSrc: Binding<String?>, heading: Binding<String>, isLive: Binding<Bool>) {
        self.label = label
        self.link = link
        self.imageUrl = imageUrl
        self.color = color
        _audioUrl = audioUrl
        _imageSrc = imageSrc
        _heading = heading
        _isLive = isLive
    }
    
    var body: some View {
        NavigationLink(destination: AudioPlayerView(url: $audioUrl, image: imageSrc, date: $heading, isLive: $isLive, onAppearAction: {
            fetchAudioUrl(link: link) { url in
                DispatchQueue.main.async {
                    if let url = url {
                        audioUrl = url
                    }
                    if let imageUrl = imageUrl {
                        imageSrc = "https://103fm.maariv.co.il" + imageUrl
                    }
                    heading = label
                    isLive = false
                }
            }
        })) {
            HStack {
                if let imageUrl = imageUrl {
                    AsyncImage(url: "https://103fm.maariv.co.il" + imageUrl)
                        .frame(width: 60, height: 60) // Adjust the size as needed
                }
                Text(label)
            }
            .onAppear {
            }
        }
    }
}

struct fullProgramsView: View {
    @State private var showSafariView: Bool = false
    @State private var selectedURL: URL?
    
    @State private var programs: [ExtractedData] = []
    @State private var title = ""
    
    @State private var showAudioPlayerView: Bool = false
    static private var selectedAudioUrl: URL?
    static private var selectedAudioImage: String?
    static private var selectedAudioDate: String?

    private static let audioPlayer = AudioPlayer(isLive: false)

    @State private var audioUrl: URL = URL(string: "https://example.com/audio.mp3")!
    @State private var imageSrc: String? = "https://example.com/image.jpg"
    @State private var heading: String = "Some Heading"
    @State private var isLive: Bool = false

    let link: String
    
    var body: some View {
        VStack {
            if programs.isEmpty {
                Text("Loading...").onAppear {
                    LinkProcessor.processLink(link) { (processedTitle, extractedPrograms) in
                        title = processedTitle
                        programs = extractedPrograms
                    }
                }
            } else {
                List {
                    ForEach (programs) { program in
                            ProgramNavLink(label: program.date, link: "https://103fm.maariv.co.il" + program.link, imageUrl: program.image, audioUrl: $audioUrl, imageSrc: $imageSrc, heading: $heading, isLive: $isLive)
//                        { link in
//                                fetchAudioUrl(link: link) { url in
//                                    fullProgramsView.selectedAudioUrl = url
//                                    fullProgramsView.selectedAudioImage = program.image
//                                    fullProgramsView.selectedAudioDate = program.date
//                                    showAudioPlayerView.toggle()
//                                }
//                            }
                            .font(.title)
                            .foregroundColor(program.date.relativeColor())
                    }
                    .onDelete(perform: deleteProgram)
                }
                .sheet(isPresented: $showAudioPlayerView) {
                    VStack {
                        if let url = fullProgramsView.selectedAudioUrl,
                           let image = "https://103fm.maariv.co.il" + (fullProgramsView.selectedAudioImage ?? ""),
                           let date = title + "\n" + (fullProgramsView.selectedAudioDate ?? "") {
                            AudioPlayerView(url: $audioUrl, image: imageSrc, date: $heading, isLive: $isLive)
                                .onAppear {
                                    DispatchQueue.main.async {
                                        audioUrl = url
                                        imageSrc = image
                                        heading = date
                                        isLive = true
                                    }
                                }
                        } else {
                            Text("No URL selected")
                        }
                    }
                }
                .sheet(isPresented: $showSafariView) {
                    if let url = selectedURL {
                        SafariView(url: url)
                    } else {
                        Text("No URL selected")
                    }
                }
                .onChange(of: selectedURL) { newValue in
                    showSafariView = newValue != nil
                }
                .toolbar {
    #if os(iOS)
                    ToolbarItem(placement: .navigationBarTrailing) {
                        EditButton()
                    }
    #endif
                }
            }
        }.navigationBarTitle(title, displayMode: .inline)
    }
    
    private func deleteProgram(at offsets: IndexSet) {
        programs.remove(atOffsets: offsets)
    }
    
    func didSelectURL(_ link: String) {
        if let url = URL(string: "https://103fm.maariv.co.il" + link) {
            DispatchQueue.main.async {
                selectedURL = url
                showSafariView = true
            }
        }
    }
}
