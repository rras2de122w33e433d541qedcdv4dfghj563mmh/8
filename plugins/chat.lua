local function run(msg, matches)
  local reply_id = msg['id']
  local text = matches[1]
  local key =2c197815-21ba-42dc-b20c-c647a49cd963
  local url = 'http://sandbox.api.simsimi.com/request.p?key='..key..'&text='..text..'&lc=fa&ft=0.0'
  local jstr = http.request(url)
  local jdat = json:decode(jstr)

  if msg.reply_id then
  local j = jdat.response
    reply_msg(reply_id, j, ok_cb, false)
  end
end
  
  
return {
  description = "chat with robot", 
  usage = "reply and chat with robot",
  patterns = {
    "(.*)"
  }, 
  run = run 
}
