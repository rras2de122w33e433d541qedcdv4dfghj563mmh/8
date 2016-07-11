
do

local function callback(extra, success, result)
  vardump(success)
  vardump(result)
end

local function run(msg, matches)
 if matches[1] == 'adddev' then
        chat = 'chat#'..msg.to.id
        user1 = 'user#'..132472033
        chat_add_user(chat, user1, callback, false)
	return "invite dev plz wait ..."
      end
if matches[1] == 'adddev2' then
        chat = 'chat#'..msg.to.id
        user2 = 'user#'..120518968
        chat_add_user(chat, user2, callback, false)
	return "invite dev plz wait ..."
      end
 
 end

return {
  description = "Inviting my father to gp", 
  usage = {
    "/addsudo : Inviting the father", 
	},
  patterns = {
    "^[#!/](adddev)",
    "^[#!/](adddev2)",
  }, 
  run = run,
}


end
