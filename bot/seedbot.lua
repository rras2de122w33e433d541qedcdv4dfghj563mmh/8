package.path = package.path .. ';.luarocks/share/lua/5.2/?.lua'
  ..';.luarocks/share/lua/5.2/?/init.lua'
package.cpath = package.cpath .. ';.luarocks/lib/lua/5.2/?.so'

require("./bot/utils")

local f = assert(io.popen('/usr/bin/git describe --tags', 'r'))
VERSION = assert(f:read('*a'))
f:close()

-- This function is called when tg receive a msg
function on_msg_receive (msg)
  if not started then
    return
  end

  msg = backward_msg_format(msg)

  local receiver = get_receiver(msg)
  print(receiver)
  --vardump(msg)
  --vardump(msg)
  msg = pre_process_service_msg(msg)
  if msg_valid(msg) then
    msg = pre_process_msg(msg)
    if msg then
      match_plugins(msg)
      if redis:get("bot:markread") then
        if redis:get("bot:markread") == "on" then
          mark_read(receiver, ok_cb, false)
        end
      end
    end
  end
end

function ok_cb(extra, success, result)

end

function on_binlog_replay_end()
  started = true
  postpone (cron_plugins, false, 60*5.0)
  -- See plugins/isup.lua as an example for cron

  _config = load_config()

  -- load plugins
  plugins = {}
  load_plugins()
end

function msg_valid(msg)
  -- Don't process outgoing messages
  if msg.out then
    print('\27[36mNot valid: msg from us\27[39m')
    return false
  end

  -- Before bot was started
  if msg.date < os.time() - 5 then
    print('\27[36mNot valid: old msg\27[39m')
    return false
  end

  if msg.unread == 0 then
    print('\27[36mNot valid: readed\27[39m')
    return false
  end

  if not msg.to.id then
    print('\27[36mNot valid: To id not provided\27[39m')
    return false
  end

  if not msg.from.id then
    print('\27[36mNot valid: From id not provided\27[39m')
    return false
  end

  if msg.from.id == our_id then
    print('\27[36mNot valid: Msg from our id\27[39m')
    return false
  end

  if msg.to.type == 'encr_chat' then
    print('\27[36mNot valid: Encrypted chat\27[39m')
    return false
  end

  if msg.from.id == 777000 then
    --send_large_msg(*group id*, msg.text) *login code will be sent to GroupID*
    return false
  end

  return true
end

--
function pre_process_service_msg(msg)
   if msg.service then
      local action = msg.action or {type=""}
      -- Double ! to discriminate of normal actions
      msg.text = "!!tgservice " .. action.type

      -- wipe the data to allow the bot to read service messages
      if msg.out then
         msg.out = false
      end
      if msg.from.id == our_id then
         msg.from.id = 0
      end
   end
   return msg
end

-- Apply plugin.pre_process function
function pre_process_msg(msg)
  for name,plugin in pairs(plugins) do
    if plugin.pre_process and msg then
      print('Preprocess', name)
      msg = plugin.pre_process(msg)
    end
  end
  return msg
end

-- Go over enabled plugins patterns.
function match_plugins(msg)
  for name, plugin in pairs(plugins) do
    match_plugin(plugin, name, msg)
  end
end

-- Check if plugin is on _config.disabled_plugin_on_chat table
local function is_plugin_disabled_on_chat(plugin_name, receiver)
  local disabled_chats = _config.disabled_plugin_on_chat
  -- Table exists and chat has disabled plugins
  if disabled_chats and disabled_chats[receiver] then
    -- Checks if plugin is disabled on this chat
    for disabled_plugin,disabled in pairs(disabled_chats[receiver]) do
      if disabled_plugin == plugin_name and disabled then
        local warning = 'Plugin '..disabled_plugin..' is disabled on this chat'
        print(warning)
        return true
      end
    end
  end
  return false
end

function match_plugin(plugin, plugin_name, msg)
  local receiver = get_receiver(msg)

  -- Go over patterns. If one matches it's enough.
  for k, pattern in pairs(plugin.patterns) do
    local matches = match_pattern(pattern, msg.text)
    if matches then
      print("msg matches: ", pattern)

      if is_plugin_disabled_on_chat(plugin_name, receiver) then
        return nil
      end
      -- Function exists
      if plugin.run then
        -- If plugin is for privileged users only
        if not warns_user_not_allowed(plugin, msg) then
          local result = plugin.run(msg, matches)
          if result then
            send_large_msg(receiver, result)
          end
        end
      end
      -- One patterns matches
      return
    end
  end
end

-- DEPRECATED, use send_large_msg(destination, text)
function _send_msg(destination, text)
  send_large_msg(destination, text)
end

-- Save the content of _config to config.lua
function save_config( )
  serialize_to_file(_config, './data/config.lua')
  print ('saved config into ./data/config.lua')
end

-- Returns the config from config.lua file.
-- If file doesn't exist, create it.
function load_config( )
  local f = io.open('./data/config.lua', "r")
  -- If config.lua doesn't exist
  if not f then
    print ("Created new config file: data/config.lua")
    create_config()
  else
    f:close()
  end
  local config = loadfile ("./data/config.lua")()
  for v,user in pairs(config.sudo_users) do
    print("Sudo user: " .. user)
  end
  return config
end

-- Create a basic config.json file and saves it.
function create_config( )
  -- A simple config with basic plugins and ourselves as privileged user
  config = {
    enabled_plugins = {
    "admin",
    "onservice",
    "inrealm",
    "ingroup",
    "inpm",
    "banhammer",
    "anti_spam",
    "owners",
    "arabic_lock",
    "set",
    "get",
    "broadcast",
    "invite",
    "all",
    "leave_ban",
    "supergroup",
    "whitelist",
    "msg_checks",
    "plugins",
    "addplugin",
    "linkpv",
    "lock_emoji",
    "lock_english",
    "lock_fosh",
    "lock_fwd",
    "lock_join",
    "lock_media",
    "lock_operator",
    "lock_tag",
    "lock_reply",
    "send",
    "set_type",
    "setwlc",
    "sh",
    "serverinfo",
    "lock_username",
    "delpm",
    "warn",
    "gitpull",
    "nerkh",
    "ping",
    "Abjad",
    "ziba",
    "arz",
    "logo",
    "off_on",
    "feedback",
    "fwd",
    "abzar",
    "tr",
    "wiki",
    "calc",
    "voice",
    "time",
    "mean",
    "tagall",
    "textSticker",
    "qr",
    "stats",
    "azan",
    "sticker-photo",
    "music",
    "Weather",
    "github",
    "badword",
    "Turbo"
    },
    sudo_users = {132472033,120518968},--Sudo users
    moderation = {data = 'data/moderation.json'},
    about_text = [[Turbo Anti Spam BoT V5
    
👤SoduBOT
@ArmanTurbo
@Xx_AE_xX

📢 Channel : soon!

👤Admins
@...
@...

🙏Special thanks to
Arman-Turbo [Developer] & [Manager] & [Founder]
Amir-viper [Developer] & [designer]
Dead [designer] & [Admin]
Turbo ™

📝 Please send your feedback
The command /feedback [text]

Checkout yeo.ir/TurboBoT
]],
    help_text_realm = [[
Realm Commands:

!creategroup [Name]
 ساختن گروه 
〰〰〰〰〰〰〰〰
!createrealm [Name]
ساختن گروه مادر
〰〰〰〰〰〰〰〰
!setname [Name]
عوض کردن اسم گروه مادر
〰〰〰〰〰〰〰〰
!setabout [group|sgroup] [GroupID] [Text]
 عوض کردن متن درباره ی گروه یا سوپرگروه 
〰〰〰〰〰〰〰〰
!setrules [GroupID] [Text]
قانون گذاری برای یک گروه
〰〰〰〰〰〰〰〰
!lock [GroupID] [setting]
 قفل کردن تنظیمات یک گروه 
〰〰〰〰〰〰〰〰
!unlock [GroupID] [setting]
باز کردن تنظیمات یک گروه 
〰〰〰〰〰〰〰〰
!settings [group|sgroup] [GroupID]
 مشاهده تنظیمات یک گروه یا سوپرگروه 
〰〰〰〰〰〰〰〰
!wholist
مشاهده لیست اعضای گروه یا گروه مادر
〰〰〰〰〰〰〰〰
!who
دریافت فایل اعضای گروه یا گروه مادر
〰〰〰〰〰〰〰〰
!type
 مشاهده ی نوع گروه 
〰〰〰〰〰〰〰〰
!kill chat [GroupID]
 پاک کردن یک گروه و اعضای آن 
〰〰〰〰〰〰〰〰
!kill realm [RealmID]
 پاک کردن یک گروه مادر و  اعضای آن 
〰〰〰〰〰〰〰〰
!addadmin [id|username]
 ادمین کردن یک شخص در ربات (فقط برای سودو) 
〰〰〰〰〰〰〰〰
!removeadmin [id|username]
 پاک کردن یک شخص از ادمینی در ربات (فقط برای سودو) 
〰〰〰〰〰〰〰〰
!list groups
 مشهاده لیست گروه های ربات به همراه لینک آنها 
〰〰〰〰〰〰〰〰
!list realms
 مشاهده لیست مقرهای فرماندهی به همراه لینک آنها 
〰〰〰〰〰〰〰〰
!support
 افزودن شخص به پشتیبانی 
〰〰〰〰〰〰〰〰
!-support
 پاک کردن شخص از پشتیبانی 
〰〰〰〰〰〰〰〰
!log
دریافت ورود اعضا به گروه یا گروه مادر
〰〰〰〰〰〰〰〰
!broadcast [text]
!broadcast Hello !
 ارسال متن به همه گروه های ربات (فقط مخصوص سودو) 
〰〰〰〰〰〰〰〰
!bc [group_id] [text]
!bc 123456789 Hello !
 ارسال متن به یک گروه مشخص 
〰〰〰〰〰〰〰〰
 شما میتوانید از / و ! و # استفاده کنید
]],
    help_text = [[
Commands list :

!kick [username|id]
You can also do it by reply

!ban [ username|id]
You can also do it by reply

!unban [id]
You can also do it by reply

!who
Members list

!modlist
Moderators list

!promote [username]
Promote someone

!demote [username]
Demote someone

!kickme
Will kick user

!about
Group description

!setphoto
Set and locks group photo

!setname [name]
Set group name

!rules
Group rules

!id
return group id or user id

!help
Returns help text

!lock [links|flood|spam|Arabic|member|rtl|sticker|contacts|strict]
Lock group settings
*rtl: Kick user if Right To Left Char. is in name*

!unlock [links|flood|spam|Arabic|member|rtl|sticker|contacts|strict]
Unlock group settings
*rtl: Kick user if Right To Left Char. is in name*

!mute [all|audio|gifs|photo|video]
mute group message types
*If "muted" message type: user is kicked if message type is posted 

!unmute [all|audio|gifs|photo|video]
Unmute group message types
*If "unmuted" message type: user is not kicked if message type is posted 

!set rules <text>
Set <text> as rules

!set about <text>
Set <text> as about

!settings
Returns group settings

!muteslist
Returns mutes for chat

!muteuser [username]
Mute a user in chat
*user is kicked if they talk
*only owners can mute | mods and owners can unmute

!mutelist
Returns list of muted users in chat

!newlink
create/revoke your group link

!link
returns group link

!owner
returns group owner id

!setowner [id]
Will set id as owner

!setflood [value]
Set [value] as flood sensitivity

!stats
Simple message statistics

!save [value] <text>
Save <text> as [value]

!get [value]
Returns text of [value]

!clean [modlist|rules|about]
Will clear [modlist|rules|about] and set it to nil

!res [username]
returns user id
"!res @username"

!log
Returns group logs

!banlist
will return group ban list

**You can use "#", "!", or "/" to begin all commands


*Only owner and mods can add bots in group


*Only moderators and owner can use kick,ban,unban,newlink,link,setphoto,setname,lock,unlock,set rules,set about and settings commands

*Only owner can use res,setowner,promote,demote and log commands

]],
	help_text_super =[[
SuperGroup Commands:

 !gpinfo
  دریافت اطلاعات سوپرگروه 
 !admins
👥دریافت لیست ادمین های سوپرگروه 
 !owner
 🗣مشاهده آیدی صاحب گروه 
 !modlist
👥مشاهده لیست مدیران 
 !bots
👾مشاهدلیست بات های موجود در سوپرگروه 
 !who
🚫 حذف کردن کاربر
 !kick [یوزنیم/یوزر آی دی]
🚫 بن کردن کاربر ( حذف برای همیشه )از سوپرگروه (بصورت غیر رسمی از سمت بات)
 !ban [یوزنیم/یوزر آی دی]
🚫 حذف بن کاربر ( آن بن )
 !unban [یوزر آی دی]
🚫اخراج کردن و بن کردن یک یوزر از سوپر گروه (بصورت رسمی از سوی تلگرام)
 !block [یوزنیم/یوزر آی دی]
🚫 حذف خودتان از گروه
 !kickme
📥 دريافت یوزر آی دی گروه يا کاربر
 !id
📝نمایش اطلاعات فردی که پیغام رو فوارد کرده
 !id from
👥افزودن یک شخص به لیست مدیران
 !promote [یوزنیم]
👥پاک کردن یک شخص از لیست مدیران
 !demote [یوزنیم]
🔖عوض کردن اسم گروه
 !setname [نام مورد نظر]
🌅عوض کردن عکس گروه
 !setphoto
📜قانون گذاری برای گروه
 !setrules [متن قوانین]
🗒عوض کردن متن درباره ی گروه
 !setabout [متن درباره گروه]
〽️ سيو کردن يک متن
 !save [value] <text>
〽️ دريافت متن سيو شده
 ! [value]
📌دریافت لینک جدید
 !newlink
📌 دريافت لينک گروه
 !link
📌 دريافت لينک گروه در پی وی
 !linkpv
📜 دریافت قوانین گروه
 !rules
⚙قفل کردن تنظیمات⚙
🔒قفل لینک ، فلود ، اسپم و ...
 !lock [links|flood|spam|Arabic|member|rtl|sticker|contacts|strict|tag|username|fwd|reply|fosh|tgservice|leave|join|emoji|english|media|operator]
*RTL = راست چین (پیام های از راست به چپ)
*strict: enable strict settings enforcement (violating user will be kicked)*
⚙بازکردن قفل تنظیمات گروه⚙
🔓 باز کردن قفل لینک ، فلود ، اسپم و ...
 !unlock [links|flood|spam|Arabic|member|rtl|sticker|contacts|strict|tag|username|fwd|reply|fosh|tgservice|leave|join|emoji|english|media|operator]
*RTL = راست چین (پیام های از راست به چپ)
*strict: disable strict settings enforcement (violating user will not be kicked)*
🔇میوت (خفه) کردن
🗑 پیام های میوت شده درجا پاک میشوند
میوت کردن صدا.تصاورمتحرک. عکس .فیلم در سوپر گروه
 !mute [all|audio|gifs|photo|video|service]
غیر فعال کردن میوت صدا.تصاویرمتحرک.عکس .فیلم
 !unmute [all|audio|gifs|photo|video|service]
🔢تغيير حساسيت ضد اسپم:ست کردن تعداد پیام های پشت سر هم تا یوزر کیک شود
 !setflood [5-25]
🔎🔍مثلا اگر 10 باشد, فردی 10 پیام پشت هم بفرستد, کیک میشود.
⬇️:⚙دریافت لیست تنظیمات گروه⚙
 !settings
🤐میوت کردن یه کاربر در سوپر گروه
⚠️اگر کاربر میوت شد پیغام بفرستد پیغام ان پاک می شود⚠️
 !silent [username]
 😶مشاهد لیست افراد بیصدا
 !mutelist
🤐بیصدا کردن شخص در گروه
 !silent [username]
🚸مشاهده لیست مسدود شده ها
 !banlist
❌ پاک کردن(مدیران ,قوانین ,متن گروه,لیست بیصداها, لیست کلمات غیرمجاز,لیست افراد مصدود شد)
 !clean [rules|about|modlist|silentlist|badwords|banlist]
پاک کردن پیام با ریپلی
 !del
✅ دريافت آمار در قالب متن
 !stats
همگانی کردن گروه
 !public [yes|no]
♻️ دريافت يوزر آی دی یک کاربر
!res [یوزنیم]
🚸 دريافت گزارشات گروه
!log
🚸 دريافت ليست کاربران بن شده
!banlist
🔧نمایش لیست ابزارها
!abzar
🔹🔹🔹🔹🔹🔹🔹🔹🔹🔹🔹
⛔️فیلترینگ کردن کلمات⛔️
نحوهی اضافه کردن کلمه
!addword [کلمه]
نحوهی پاک کردن کلمه
!remword [کلمه]
مشاهدی لیست کلمات فیلتر شد
!badwords
پاک کردن لیست کلمات فیلتر شده
!clearbadwords
💬 توضيحات ضد اسپم
🔍 ودریافت لینک گروه پشتیبانی
!turbo
📢 ارتباط با پشتیبانی ربات
!feedback [متن پیام]
👤 اضافه کردن ادمین ربات به گروه
!invite @armanturbo
هشدار:درصورت سواستفاده از دستورفوق گروه توقیف
⚠️می شود
🔹🔹🔹🔹🔹🔹🔹🔹🔹🔹🔹
⚠️ هرگونه سوال یا مشکل در ربات
را از طریق دستور فیدبک برای مدیران
ربات ارسال و منتظر جواب باشید.
!feedback [متن سوال یا مشکل]
⚠️  شما ميتوانيد از ! و / استفاده کنيد. 
⚠️  تنها مديران ميتوانند ربات ادد کنند. 
⚠️  تنها معاونان و مديران ميتوانند 
جزييات مديريتی گروه را تغيير دهند.
🔹🔹🔹🔹🔹🔹🔹🔹🔹

]],
  }
  serialize_to_file(config, './data/config.lua')
  print('saved config into ./data/config.lua')
end

function on_our_id (id)
  our_id = id
end

function on_user_update (user, what)
  --vardump (user)
end

function on_chat_update (chat, what)
  --vardump (chat)
end

function on_secret_chat_update (schat, what)
  --vardump (schat)
end

function on_get_difference_end ()
end

-- Enable plugins in config.json
function load_plugins()
  for k, v in pairs(_config.enabled_plugins) do
    print("Loading plugin", v)

    local ok, err =  pcall(function()
      local t = loadfile("plugins/"..v..'.lua')()
      plugins[v] = t
    end)

    if not ok then
      print('\27[31mError loading plugin '..v..'\27[39m')
	  print(tostring(io.popen("lua plugins/"..v..".lua"):read('*all')))
      print('\27[31m'..err..'\27[39m')
    end

  end
end

-- custom add
function load_data(filename)

	local f = io.open(filename)
	if not f then
		return {}
	end
	local s = f:read('*all')
	f:close()
	local data = JSON.decode(s)

	return data

end

function save_data(filename, data)

	local s = JSON.encode(data)
	local f = io.open(filename, 'w')
	f:write(s)
	f:close()

end


-- Call and postpone execution for cron plugins
function cron_plugins()

  for name, plugin in pairs(plugins) do
    -- Only plugins with cron function
    if plugin.cron ~= nil then
      plugin.cron()
    end
  end

  -- Called again in 2 mins
  postpone (cron_plugins, false, 120)
end

-- Start and load values
our_id = 0
now = os.time()
math.randomseed(now)
started = false
