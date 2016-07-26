do
local function admin_list(msg)
    local data = load_data(_config.moderation.data)
        local admins = 'admins'
        if not data[tostring(admins)] then
        data[tostring(admins)] = {}
        save_data(_config.moderation.data, data)
        end
        local message = '👥Admins :\n'
        for k,v in pairs(data[tostring(admins)]) do
                message = message .. '>🏅 @' .. v .. ' [' .. k .. '] ' ..'\n'
        end
        return message
end
local function run(msg, matches)
local space = '➖➖➖➖➖➖➖➖➖'
local admins = admin_list(msg)
local info = io.popen("sh ./Turbo/sev.sh"):read('*all')
 local uptime = io.popen('uptime'):read('*all')
 local rates = uptime:split("up")
 local rates1 = uptime:split(",")
 local rates1 = rates1[2]
 local rates = rates[2]
 local rates = rates:split(",  load")
 local rates = rates[1]
local our = 'yeo.ir/TurboBoT'
local Channel = 'Soon!'
local sup = '@supturbobot'
	local data = load_data(_config.moderation.data)
	local settings = data[tostring(1045086781)]['settings']
	local group_link = data[tostring(1045086781)]['settings']['set_link'] --put your support id here
	if not group_link then
		group_link = "[none]"
	end
--send_document("channel#id"..msg.to.id,"./Turbo/rank/jojo.webp", ok_cb, false)

local text = ""..space.."\nTurbo Anti Spam BoT V5⃣\n"..space.."\n    \nDevelopers & The builders and the owner of the rating :\n@ArmanTurbo\n@Xx_AE_xX\n"..admins.."\n\n🙏Special thanks to :\nArman-Turbo [Developer] & [Manager] & [Founder]\nAmir-viper [Developer] & [designer]\nDead [designer] & [Admin]\nAnd All My Friends\n\n🔆 Turbo ™ Technical specifications of the server :\n\nuptime : "..rates.." days"..rates1.." hours\n\n"..info..""..space.."\nCheckout :\n"..our.."\n"..space.."\nBridges of communication :\n\n📢 Channel : "..Channel.."\nSupport BoT :\n"..sup.."\n📝 Please send your feedback\nThe command Feedback [text]\nSupport link :\n"..group_link
return text
end
return {
patterns = {
"^[/#!]([Tt]urbo)$",
"^[Tt][Uu][Rr][Bb][Oo]$",
},
run = run
}
end
