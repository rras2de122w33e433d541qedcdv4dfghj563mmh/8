local function run(msg, matches)
    if is_momod(msg) then
        return
    end
    local data = load_data(_config.moderation.data)
    if data[tostring(msg.to.id)] then
        if data[tostring(msg.to.id)]['settings'] then
            if data[tostring(msg.to.id)]['settings']['fosh'] then
                lock_fosh = data[tostring(msg.to.id)]['settings']['fosh']
            end
        end
    end
    local chat = get_receiver(msg)
    local user = "user#id"..msg.from.id
    if lock_fosh == "yes" then
       delete_msg(msg.id, ok_cb, true)
    end
end
 
return {
  patterns = {
 "(ک*س)$",
    "کیر",
 "کص",
 "کــــــــــیر",
 "کــــــــــــــــــــــــــــــیر",
 "کـیـــــــــــــــــــــــــــــــــــــــــــــــــــر",
    "ک×یر",
 "ک÷یر",
 "ک*ص",
 "کــــــــــیرر",
    "kir",
 "kos",
 "گوساله",
"کونی",
"کیری",
"کص لیس",
"کسکش",
"کس کش",
"کونده",
"جنده",
"کس ننه",
"گاییدم",
"نگاییدم",
"بگا",
"گاییدن",
"دیوث",
"ننه الکسیس",
"ننه زنا",
"ننه کیر دزد",
"زنازاده",
"مادر به خطا",
"کسمخ",
"کسخل",
"کسمغز",
"ننه خراب",
"کیرم دهنت",
"کیرم دهنتون",
"حروم زاده",
"فاک",
"فاک یو",
"قرومصاق",
"بی غیرت",
"کس ننت",
"جق",
"جقی",
"جق زن",
"شومبول",
"چوچول",
"چوچوله",
"دودول",
"ننه چس",
"چسی",
"چس ممبر",
"اوبی",
"قحبه",
"بسیک",
"سیکتر",
"سیک",
"خوارکسته",
"خوارکسده",
 "gosale",
 "gusale",
 "Kos",
 "kos"
  },
  run = run
}



