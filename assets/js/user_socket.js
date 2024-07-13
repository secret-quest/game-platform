import {Socket, Presence} from "phoenix"

let socket = new Socket("/socket", {params: {token: window.userToken}})

let channel = socket.channel("tower:lobby", {address: window.location.search.split("=")[1]})

let presence = new Presence(channel)

function renderOnlineUsers(presence) {
  console.log(presence.list((address, {metas: meta}) => {console.log(address)}))
}
socket.connect()

presence.onSync(() => renderOnlineUsers(presence))

channel.join()
.receive("ok", resp => { console.log("Joined successfully", resp) })
.receive("error", resp => { console.log("Unable to join", resp) })

export default socket
