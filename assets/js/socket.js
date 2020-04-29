// NOTE: The contents of this file will only be executed if
// you uncomment its entry in "assets/js/app.js".

// To use Phoenix channels, the first step is to import Socket,
// and connect at the socket path in "lib/web/endpoint.ex".
//
// Pass the token on params as below. Or remove it
// from the params if you are not using authentication.
import {
  Socket,
  Presence
} from "phoenix"

let socket = new Socket("/socket", {
  params: {
    token: window.userToken
  }
})

let roomId = window.roomId;
let presences = {};
socket.connect()

// Now that you are connected, you can join channels with a topic:
if (roomId) {
  const timeout = 1500;
  var typingtimer;
  let userTyping = false;
  let channel = socket.channel(`room:${roomId}`, {})
  channel.join()
    .receive("ok", resp => {
      console.log("Joined successfully", resp);
      resp.messages.reverse().map(msg => displayMessage(msg, false));
    })
    .receive("error", resp => {
      console.log("Unable to join", resp)
    })
  channel.on(`room:${roomId}:new_message`, (message) => {
    console.log(message);
    displayMessage(message, true);
  })
  channel.on("presence_state", state => {
    presences = Presence.syncState(presences, state);
    displayUsers(presences);
  })
  channel.on("presence_diff", diff => {
    presences = Presence.syncDiff(presences, diff);
    displayUsers(presences);
  })
  document.querySelector('#message-form').addEventListener('submit', (e) => {
    e.preventDefault();
    let input = e.target.querySelector('#message-body');

    channel.push('message:add', {
      message: input.value
    });

    input.value = "";
  })

  document.querySelector("#message-body").addEventListener('keydown', () => {
    userStartsTyping();
    clearTimeout(typingtimer);
  })
  document.querySelector("#message-body").addEventListener('keyup', () => {
    clearTimeout(typingtimer);
    typingtimer = setTimeout(userStopTyping, timeout);
  })

  const userStartsTyping = () => {
    if (userTyping) {
      return;
    }
    userTyping = true;
    channel.push('user:typing', {
      typing: true,
      token: window.userToken
    });
  }

  const userStopTyping = () => {
    clearTimeout(typingtimer);
    userTyping = false;
    channel.push('user:typing', {
      typing: false,
      token: null
    })
  }
  const displayMessage = (msg, anim) => {
    var temp = document.createElement("li");
    let names = " text-left message";
    if(anim){
       names = " text-left message fadeInUp animated";
    }
    
    let arr = names.split(" ");
    for (var name of arr) {
      temp.classList += " " + name;
    }
    temp.innerHTML = `<strong>${msg.user.username}</strong> | ${msg.body}`

    var list = document.querySelector("#display");
    list.insertBefore(temp, list.childNodes[0]);
  }

  const displayUsers = (presences) => {
    let numUsers = 0;
    let typingTemplate = '';
    let typing_li = document.createElement("span");
    typing_li.setAttribute("id", "isTyping");
    let usersOnline = Presence.list(presences, (_id, {
      metas: [
        user, ...rest
      ]
    }) => {
      numUsers++;
      if (user.typing && user.typing_token != window.userToken) {
        typingTemplate = `<strong class="font-semibold">${user.username}</strong> is typing...`;
      }
      return `
        <div id="user-${user.user_id}" class="my-2 text-left"><strong class="text-indigo-600">${user.username}</strong></div>
      `
    }).join("")

    typing_li.innerHTML = typingTemplate;

    document.querySelector('#user-count').innerHTML = ": " + numUsers;
    document.querySelector('#user-names').innerHTML = usersOnline;
    let list = document.querySelector('#user-typing');
    if (typingTemplate != '') {
      list.insertBefore(typing_li, list.childNodes[0]);
    } else if (!userTyping && document.querySelector('#isTyping')) {
      document.querySelector('#isTyping').remove();
    }

  }
}


export default socket