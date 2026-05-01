import SwiftUI
import MediaPlayer

struct MusicView: View {
    let windowState: WindowState
    @State private var songs: [MPMediaItem] = []
    @State private var authorized = false
    @State private var nowPlaying: MPMediaItem?
    @State private var isPlaying = false

    private let player = MPMusicPlayerController.systemMusicPlayer

    var body: some View {
        HStack(spacing: 0) {
            // Sidebar
            VStack(alignment: .leading, spacing: 0) {
                Text("Library")
                    .font(MacFonts.sidebarHeader)
                    .foregroundStyle(MacColors.tertiaryText)
                    .padding(.horizontal, 10)
                    .padding(.top, 6)
                    .padding(.bottom, 2)

                ForEach(["Songs", "Albums", "Artists", "Playlists"], id: \.self) { item in
                    HStack(spacing: 6) {
                        Image(systemName: iconFor(item))
                            .font(.system(size: 10))
                            .foregroundStyle(.red)
                            .frame(width: 14)
                        Text(item).font(MacFonts.sidebar)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 3)
                }
                Spacer()

                // Now playing mini bar at bottom of sidebar
                if let song = nowPlaying {
                    Divider()
                    HStack(spacing: 6) {
                        RoundedRectangle(cornerRadius: 3)
                            .fill(Color.red.opacity(0.3))
                            .frame(width: 24, height: 24)
                            .overlay(Image(systemName: "music.note").font(.system(size: 10)).foregroundStyle(.red))
                        VStack(alignment: .leading, spacing: 0) {
                            Text(song.title ?? "Unknown").font(.system(size: 9, weight: .medium)).lineLimit(1)
                            Text(song.artist ?? "").font(.system(size: 8)).foregroundStyle(.secondary).lineLimit(1)
                        }
                    }
                    .padding(.horizontal, 6)
                    .padding(.vertical, 4)
                }
            }
            .frame(width: 110)
            .background(MacColors.sidebarBackground)

            Divider()

            // Content
            VStack(spacing: 0) {
                // Playback controls (compact)
                if nowPlaying != nil {
                    HStack(spacing: 14) {
                        Button { player.skipToPreviousItem() } label: {
                            Image(systemName: "backward.fill").font(.system(size: 10))
                        }
                        Button { togglePlayPause() } label: {
                            Image(systemName: isPlaying ? "pause.fill" : "play.fill").font(.system(size: 12))
                        }
                        Button { player.skipToNextItem() } label: {
                            Image(systemName: "forward.fill").font(.system(size: 10))
                        }
                        Spacer()
                    }
                    .buttonStyle(.plain)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color(white: 0.97))
                    Divider()
                }

                if !authorized {
                    VStack(spacing: 8) {
                        Image(systemName: "music.note").font(.system(size: 28)).foregroundStyle(.secondary)
                        Text("Allow access to your music").font(.system(size: 11))
                        Button("Allow") { requestAccess() }.buttonStyle(.borderedProminent).controlSize(.small)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    songList
                }
            }
        }
        .onAppear {
            windowState.title = "Music"
            requestAccess()
        }
    }

    private var songList: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                HStack {
                    Text("#").frame(width: 20)
                    Text("Title").frame(maxWidth: .infinity, alignment: .leading)
                    Text("Artist").frame(width: 80, alignment: .leading)
                    Text("Time").frame(width: 40, alignment: .trailing)
                }
                .font(.system(size: 9, weight: .medium))
                .foregroundStyle(MacColors.tertiaryText)
                .padding(.horizontal, 8).padding(.vertical, 3)

                Divider()

                ForEach(Array(songs.enumerated()), id: \.element.persistentID) { index, song in
                    Button { playSong(song) } label: {
                        HStack {
                            Text("\(index + 1)").frame(width: 20).foregroundStyle(.secondary)
                            Text(song.title ?? "Unknown").frame(maxWidth: .infinity, alignment: .leading).lineLimit(1)
                            Text(song.artist ?? "").frame(width: 80, alignment: .leading).lineLimit(1).foregroundStyle(.secondary)
                            Text(formatDuration(song.playbackDuration)).frame(width: 40, alignment: .trailing).foregroundStyle(.secondary)
                        }
                        .font(MacFonts.body)
                        .padding(.horizontal, 8).padding(.vertical, 2)
                        .background(nowPlaying?.persistentID == song.persistentID ? Color.red.opacity(0.08) : .clear)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private func iconFor(_ item: String) -> String {
        switch item {
        case "Songs": return "music.note"
        case "Albums": return "square.stack"
        case "Artists": return "music.mic"
        case "Playlists": return "music.note.list"
        default: return "music.note"
        }
    }

    private func requestAccess() {
        MPMediaLibrary.requestAuthorization { status in
            DispatchQueue.main.async {
                authorized = status == .authorized
                if authorized { loadSongs() }
            }
        }
    }

    private func loadSongs() {
        let query = MPMediaQuery.songs()
        songs = Array((query.items ?? []).prefix(100))
    }

    private func playSong(_ song: MPMediaItem) {
        nowPlaying = song
        player.setQueue(with: MPMediaItemCollection(items: [song]))
        player.play()
        isPlaying = true
    }

    private func togglePlayPause() {
        if isPlaying { player.pause() } else { player.play() }
        isPlaying.toggle()
    }

    private func formatDuration(_ d: TimeInterval) -> String {
        String(format: "%d:%02d", Int(d) / 60, Int(d) % 60)
    }
}
