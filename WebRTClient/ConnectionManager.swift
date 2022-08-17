//
//  ConnectionManager.swift
//  WebRTClient
//
import Foundation
import LiveKit

public class ConnectionManager {
    let myRoom = Room()
    let roomOptions = RoomOptions(
        adaptiveStream: true,
        dynacast: true
    )
    var i = Int(0)
    func connect(url:String, token:String) -> Bool {
        if self.connectionState() == "Connected" {
            myRoom.disconnect()
            return false
        }
        myRoom.connect(url, token, roomOptions:self.roomOptions)
        while self.connectionState() != "Connected" {
            if i>20 {
                break
            }
            usleep(500000)
            i+=1
        }
        i=0
        if self.connectionState() != "Connected" {
            return false
        }
        self.myRoom.localParticipant?.setMicrophone(enabled: true)
        return true
    }
    func toggleMic() -> Bool {
        if self.connectionState() == "Connected" {
            let myTrack = myRoom.localParticipant!.localAudioTracks
            if(myTrack[0].muted) {
                myTrack[0].unmute()
            } else {
                myTrack[0].mute()
            }
            return true
        }
        return false
    }
    func connectionState() -> String {
        switch myRoom.connectionState {
        case .disconnected:
            return "Disconnected"
        case .connecting:
            return "Connecting"
        case .reconnecting:
            return "Reconnecting"
        case .connected:
            return "Connected"
        }
    }
    func connectedTo() -> String {
        if connectionState() == "Connected" {
            // unwrapping unsafely here is ok, as this will never execute when myRoom.name.description may be nil
            return "Connected to " + myRoom.description.debugDescription
        }
        return "Idle"
    }
}
