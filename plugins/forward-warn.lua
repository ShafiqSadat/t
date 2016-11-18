local function pre_process(msg) 
  local alirezapt = msg['id']
  local user = msg.from.id
  local chat = msg.to.id
  local hash = 'mate:'..chat..':'..user
  if msg.fwd_from and not is_momod(msg) then
    if redis:get(hash) and msg.fwd_from and not is_momod(msg) then 
      delete_msg(msg.id, ok_cb, false) 
      redis:del(hash) 
      kick_user(user, chat)
    else
      local text = "کاربر ["..msg.from.first_name.."] از فوروارد کردن مطالب خودداری کنید\nدر صورت تکرار از گروه حذف خواهید شد" 
      reply_msg(alirezapt, text, ok_cb, true) 
      redis:set(hash, true)
    end
  end
  return  msg
end
       

local function run(msg, matches) 
  local alirezapt = msg['id'] 
  if matches[1] == 'forward warn' then
    if is_momod(msg) then 
      local hash = 'mate:'..msg.to.id 
      redis:set(hash, true) 
      local text = ' انجام شد\nاخطار برای فوروارد مطالب فعال شد'
      reply_msg(alirezapt, text, ok_cb, true) 
    else 
      local text = 'شما مجاز نیستید ' 
      reply_msg(alirezapt, text, ok_cb, true) 
    end
  end
  if matches[1] == 'forward ok' then
    if is_momod(msg) then 
      local hash = 'mate:'..msg.to.id 
      redis:del(hash) 
      local text = ' انجام شد\nفوروارد کردن مطالب مجاز شد'
      reply_msg(alirezapt, text, ok_cb, true) 
    else
      local text = 'شما مجاز نیستید ' 
      reply_msg(alirezapt, text, ok_cb, true) 
    end 
  end 
end
return { 
    patterns = {
"^[#!/](forward warn)$",
"^[#!/](forward ok)$"
 
    }, 
     
run = run, 
    pre_process = pre_process 
}