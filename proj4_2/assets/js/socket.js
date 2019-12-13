// NOTE: The contents of this file will only be executed if
// you uncomment its entry in "assets/js/app.js".

// To use Phoenix channels, the first step is to import Socket,
// and connect at the socket path in "lib/web/endpoint.ex".
//
// Pass the token on params as below. Or remove it
// from the params if you are not using authentication.


// When you connect, you'll often need to authenticate the client.
// For example, imagine you have an authentication plug, `MyAuth`,
// which authenticates the session and assigns a `:current_user`.
// If the current user exists you can assign the user's token in
// the connection for use in the layout.
//
// In your "lib/web/router.ex":
//
//     pipeline :browser do
//       ...
//       plug MyAuth
//       plug :put_user_token
//     end
//
//     defp put_user_token(conn, _) do
//       if current_user = conn.assigns[:current_user] do
//         token = Phoenix.Token.sign(conn, "user socket", current_user.id)
//         assign(conn, :user_token, token)
//       else
//         conn
//       end
//     end
//
// Now you need to pass this token to JavaScript. You can do so
// inside a script tag in "lib/web/templates/layout/app.html.eex":
//
//     <script>window.userToken = "<%= assigns[:user_token] %>";</script>
//
// You will need to verify the user token in the "connect/3" function
// in "lib/web/channels/user_socket.ex":
//
//     def connect(%{"token" => token}, socket, _connect_info) do
//       # max_age: 1209600 is equivalent to two weeks in seconds
//       case Phoenix.Token.verify(socket, "user socket", token, max_age: 1209600) do
//         {:ok, user_id} ->
//           {:ok, assign(socket, :user, user_id)}
//         {:error, reason} ->
//           :error
//       end
//     end
//
// Finally, connect to the socket:


// Now that you are connected, you can join channels with a topic:


import {Socket} from "phoenix"

let socket = null

console.log("app.js")


if (document.getElementById("username_head")) {
  let tweetsList = []
  let myUserName = document.getElementById("username_head").innerText

  socket = new Socket("/socket", {params: {token: window.userToken}})
  socket.connect({user_id: myUserName})

  
  let myChannel = socket.channel("room:" + myUserName, {})    
  myChannel.join()
    .receive("ok", resp => { console.log("Joined mychannel successfully", resp) })
    .receive("error", resp => { console.log("Unable to join", resp) })

  // this channel use for private communication with client server
  let serverChannel = socket.channel("room:server:" + myUserName, {})    
  serverChannel.join()
    .receive("ok", resp => { console.log("Joined server channel successfully", resp) })
    .receive("error", resp => { console.log("Unable to join", resp) })

  //send register message to server
  serverChannel.push("register", {username: myUserName})

  serverChannel.push("join_subscribers_channel", {username: myUserName})


  let chatInput = document.querySelector("#chat-input")
  let messagesContainer = document.querySelector("#messages")
  // let sendTweetBtn = document.getElementById("send_tweet_btn")
  let subscribeInput = document.getElementById("subscribe_input")
  let subscribeBtn = document.getElementById("subscribe_btn")
  let searchInput = document.getElementById("search_input")
  let searchHashTagBtn = document.getElementById("search_hashtag_btn")
  let searchMentionBtn = document.getElementById("search_mention_btn")
  let searchSubscriberTweetBtn = document.getElementById("search_subscriber_tweet_btn")

  subscribeBtn.addEventListener("click", event => {
    if (subscribeInput.value != "") {

      //notify server to subscribe
      serverChannel.push("subscribe", {username: myUserName, subscribeToName: subscribeInput.value})

      let channelTmp = socket.channel("room:" + subscribeInput.value, {})
      channelTmp.join()
        .receive("ok", resp => { console.log("Joined" + subscribeInput.value + "successfully", resp) })
        .receive("error", resp => { console.log("Unable to join", resp) })
      
      channelTmp.on("broadcast_tweet", searchResultCallback)
      subscribeInput.value = ""
    }
  })

  chatInput.addEventListener("keypress", event => {
    if(event.keyCode === 13 && chatInput.value != ""){
      serverChannel.push("tweet", {username: myUserName, content: chatInput.value})
      myChannel.push("broadcast_tweet", {username: myUserName, content: chatInput.value})
      chatInput.value = ""
    }
  })

  searchHashTagBtn.addEventListener("click", event => {
    if(searchInput.value != ""){
      serverChannel.push("search_hashtag", {username: myUserName, hashtag: searchInput.value})
      searchInput.value = ""
    }
  })

  searchMentionBtn.addEventListener("click", event => {
    serverChannel.push("search_mention", {username: myUserName})
  })

  searchSubscriberTweetBtn.addEventListener("click", event => {
    serverChannel.push("search_subscriber_tweet", {username: myUserName})
  })

  // messageItem.innerText = `[${Date()}] ${payload.content}`

  myChannel.on("broadcast_tweet", searchResultCallback)

  serverChannel.on("subscribers", payload => {
    console.log("get subscribers success")
    let subscribers = payload["content"]
    subscribers.forEach(element => {
      let channelTmp = socket.channel("room:" + element, {})
      channelTmp.join()
        .receive("ok", resp => { console.log("Joined" + subscribeInput.value + "successfully", resp) })
        .receive("error", resp => { console.log("Unable to join", resp) })
      channelTmp.on("broadcast_tweet", searchResultCallback)
    })
  })

  serverChannel.on("register_successfully", payload => {
    console.log("register success")
    let messageItem = document.createElement("li")
    messageItem.innerText = "System: Login successfully"
    // messagesContainer.appendChild(messageItem)
    messagesContainer.prepend(messageItem)
  })

  serverChannel.on("subscribe_successfully", payload => {
    console.log("subscribe success")
    let messageItem = document.createElement("li")
    messageItem.innerText = "System: Subscribe successfully"
    // messagesContainer.appendChild(messageItem)
    messagesContainer.prepend(messageItem)
  })

  serverChannel.on("queryHashTagTweet_result", searchResultCallback)

  serverChannel.on("queryMentionTweet_result", searchResultCallback)

  serverChannel.on("querySubscriberTweet_result", searchResultCallback)

  function searchResultCallback(payload) {
    console.log("search result")
    let tweets = payload.content
    if (tweets.length == 0) {
      let messageItem = document.createElement("li")
      messageItem.innerText = "System: No results"
      // messagesContainer.appendChild(messageItem)
      messagesContainer.prepend(messageItem)
    } else {
      let tableItem = document.createElement("table")
      tableItem.style.tableLayout = "fixed"
      let headerTr = document.createElement("tr")
      let headerTh1 = document.createElement("th")
      headerTh1.width = "20%"
      let headerTh2 = document.createElement("th")
      headerTh2.width = "50%"
      let headerTh3 = document.createElement("th")
      headerTh3.width = "30%"
      headerTh1.innerText = "Author"
      headerTh2.innerText = "Content"
      headerTh3.innerText = "Process"
      headerTr.appendChild(headerTh1)
      headerTr.appendChild(headerTh2)
      headerTr.appendChild(headerTh3)
      tableItem.appendChild(headerTr)
      //messagesContainer.appendChild(tableItem)
      messagesContainer.prepend(tableItem)
      
      tweets.reverse().forEach(element => {
        let headerTr = document.createElement("tr")
        let headerTh1 = document.createElement("td")
        headerTh1.style = "word-wrap:break-word;word-break:break-all;"
        let headerTh2 = document.createElement("td")
        headerTh2.style = "word-wrap:break-word;word-break:break-all;"
        let headerTh3 = document.createElement("td")
        headerTh3.style = "word-wrap:break-word;word-break:break-all;"

        headerTr.appendChild(headerTh1)
        headerTr.appendChild(headerTh2)
        headerTr.appendChild(headerTh3)
        headerTh1.innerText = element["name"]
        headerTh2.innerText = element["content"]

        let buttonItem = document.createElement("button")
        buttonItem.innerText = "retweet"
        buttonItem.id = tweetsList.length + ""
        buttonItem.onclick = function () {
          let retweetItem = tweetsList[parseInt(this.id)]
          serverChannel.push("retweet", {username: myUserName, content: retweetItem})
          myChannel.push("broadcast_tweet", {username: myUserName, content: retweetItem["content"]})
        }
        headerTh3.appendChild(buttonItem)
        tweetsList.push(element)
        tableItem.appendChild(headerTr)
      });
    }
  }
}
export default socket
