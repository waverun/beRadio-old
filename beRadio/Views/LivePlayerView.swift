//import SwiftUI
//import AVFoundation
//
//struct LivePlayerView: View {
//    @ObservedObject private var audioPlayer: LiveAudioPlayer
//    
//    @StateObject private var routeChangeHandler = RouteChangeHandler()
//    
//    private let audioUrl: URL
//    private let imageSrc: String
//    private let heading: String
//    
//    init(url: URL, image: String, date: String) {
//        self.audioPlayer = LiveAudioPlayer()
//        self.audioUrl = URL(string: "https://cdn.cybercdn.live/103FM/Live/icecast.audio")!
//        self.imageSrc = image
//        self.heading = date
//    }
//    
//    var body: some View {
//        GeometryReader { geometry in
//            HStack {
//                Spacer()
//                VStack {
//                    VStack {
//                        Spacer()
//                            .frame(height: 50) // Adjust the height value as needed
//                        
//                        Text(heading)
//                            .font(.system(size: 24)) // Adjust the size value as needed
//                            .bold()
//                        
//                        AsyncImage(url: "https://103fm.maariv.co.il" + imageSrc)
//                            .frame(width: 240, height: 240)
//                        
//                        HStack {
//                            Text("\(audioPlayer.totalDurationString)")
//                                .foregroundColor(.primary)
//                            
//                            Button(action: {
//                                audioPlayer.rewind()
//                            }) {
//                                Image(systemName: "gobackward.15")
//                                    .resizable()
//                                    .aspectRatio(contentMode: .fit)
//                                    .frame(width: 40, height: 40)
//                            }
//                            
//                            Button(action: {
//                                //                                audioPlayer.isPlaying ? audioPlayer.pause() : audioPlayer.play(url: audioUrl)
//                                audioPlayer.isPlaying ? audioPlayer.pause() : audioPlayer.play()
//                            }) {
//                                Image(systemName: audioPlayer.isPlaying ? "pause.circle.fill" : "play.circle.fill")
//                                    .resizable()
//                                    .aspectRatio(contentMode: .fit)
//                                    .frame(width: 50, height: 50)
//                            }
//                            
//                            Button(action: {
//                                audioPlayer.forward()
//                            }) {
//                                Image(systemName: "goforward.15")
//                                    .resizable()
//                                    .aspectRatio(contentMode: .fit)
//                                    .frame(width: 40, height: 40)
//                            }
//                            
//                            Text("\(audioPlayer.currentProgressString)")
//                                .foregroundColor(.primary)
//                        }
//                    }
//                    
//                    let availableSpace = geometry.size.height - geometry.safeAreaInsets.bottom - geometry.size.width / 2
//                    Spacer()
//                        .frame(height: availableSpace / 2)
//                    
//                    Button(action: {
//                        selectAudioOutput()
//                    }) {
//                        Image(systemName: "airplayaudio")
//                            .resizable()
//                            .aspectRatio(contentMode: .fit)
//                            .frame(width: 24, height: 24)
//                    }
//                    .padding()
//                    .background(Color.blue)
//                    .foregroundColor(.white)
//                    .cornerRadius(8)
//                    
//                    Spacer()
//                }
//                Spacer()
//            }
//            .edgesIgnoringSafeArea(.bottom)
//            .onDisappear {
//                audioPlayer.pause()
//                audioPlayer.streamBuffer?.deleteAllChunks()
//            }
//        }
//    }
//}
