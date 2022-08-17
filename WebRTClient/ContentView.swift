//
//  ContentView.swift
//  WebRTClient
//
import SwiftUI
import Network

struct ContentView: View {
    @State var manager = ConnectionManager()
    @State private var url: String = "wss://livekit.lovejoy.digital:443"
    @State private var token: String = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE2NTU5NDk3NzAsImlzcyI6IkFQSXAyRUVKbkxHZVVjRiIsIm5iZiI6MTY1MzM1Nzc3MCwic3ViIjoidGVzdC1kZXZpY2UtMSIsInZpZGVvIjp7InJvb20iOiJwcm9qZWN0IHRlc3Qgcm9vbSIsInJvb21Kb2luIjp0cnVlfX0.UaSTdsm2XTDwUHlxNJqGQK7GExw9b_FMYYsrCqlrrUE"
    @State var connectButtonText = "connect"
    @State var connectButtonColor = Color.green
    @State public var micButtonColor = Color.gray
    @State public var micButtonStatus = false
    let monitor = NWPathMonitor()
    let queue = DispatchQueue(label: "Monitor")
    @State var monitoring = Bool(false)
    @State var labelText = String("Idle")
    
    func checkNetwork() {
        monitoring = true
        monitor.pathUpdateHandler = { path in
            if path.status == .satisfied {
                if connectButtonText == "disconnect" && manager.connectionState() == "Disconnected" {
                    connectButtonText = "connect"
                    micButtonColor = Color.gray
                    manager = ConnectionManager()
                }
            }
        }
        monitor.start(queue: queue)
    }
    
    var body: some View {
        VStack(spacing: 10) {
            Text("To connect, please enter a server URL and a token, then press the \"connect\" button")
            TextField("URL", text: $url).textFieldStyle(RoundedBorderTextFieldStyle())
            TextField("Token", text: $token).textFieldStyle(RoundedBorderTextFieldStyle())
            HStack(spacing: 10) {
                Button(self.connectButtonText) {
                    if (!monitoring) {
                        checkNetwork()
                    }
                    if (manager.connect(url:self.url, token:self.token)) {
                        connectButtonText = "disconnect"
                        micButtonColor = Color.green
                        micButtonStatus = true
                        labelText = manager.connectedTo()
                    } else {
                        connectButtonText = "connect"
                        micButtonColor = Color.gray
                        micButtonStatus = false
                        labelText = "Idle"
                    }
                }
                .frame(width:100)
                .padding(10)
                .background(connectButtonColor)
                .clipShape(Capsule())
                
                Button("microphone") {
                    if manager.toggleMic() {
                        if (micButtonColor == Color.red) {
                            micButtonColor = Color.green
                        } else {
                            micButtonColor = Color.red
                        }
                    }
                }
                .frame(width:100)
                .disabled(!micButtonStatus)
                .padding(10)
                .background(micButtonColor)
                .clipShape(Capsule())
            }
            Label(labelText, systemImage: "paperplane.circle.fill")
        }
        .padding(20)
    }
}
