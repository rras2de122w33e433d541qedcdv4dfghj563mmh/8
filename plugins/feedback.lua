do local function run(msg, matches)
	local data = load_data(_config.moderation.data)
	local settings = data[tostring(msg.to.id)]['settings']
	local group_link = data[tostring(msg.to.id)]['settings']['set_link']
	if not group_link then
		group_link = "لينک ندارد"
	end
	local message = 'Ⓜ️New Feedback\n'
	.."📝View Group :⬇️\n"
	.."✏️Group Name :"..msg.to.print_name.."\n"
	.."🆔Group ID :"..msg.to.id.."\n"
	.."🔗Group Link :"..group_link.."\n\n"
	.."🗣Contact Details :⬇️\n"
	.."👤Name :"..msg.from.print_name.."\n"
	.."@username :@"..(msg.from.username or "[None]").."\n"
	.."🆔User ID :"..msg.from.id.."\n"
	.."📞Phone Number :\n+"..(msg.from.phone or "[None]").."\n"
	.."➖➖➖➖➖➖➖➖➖\n\n"..matches[1]
	local userid = 'user#id132472033'
	send_large_msg(userid, message)
	return "با سپاس از نظر شما"
end

return {
	description = "Feedback System",
	usagehtm = '<tr><td align="center">feedback متن</td><td align="right">ارسال نظر شما به سودو ادمین همراه مشخصات کامل شما و گروهی که در آن هستید</td></tr>',
	usage = {
		"feedback (pm) : ارسال نظر به سودو",
	},
	patterns = {
	"^[Ff]eedback (.*)$",
        "^[#!/]feedback (.*)$",
	},
	run = run,
}
end
