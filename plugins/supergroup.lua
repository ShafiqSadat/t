--Begin supergrpup.lua
--Check members #Add supergroup
local function check_member_super(cb_extra, success, result)
  local receiver = cb_extra.receiver
  local data = cb_extra.data
  local msg = cb_extra.msg
  if success == 0 then
	send_large_msg(receiver, "Promote me to admin first!")
  end
  for k,v in pairs(result) do
    local member_id = v.peer_id
    if member_id ~= our_id then
      -- SuperGroup configuration
      data[tostring(msg.to.id)] = {
        group_type = 'SuperGroup',
		long_id = msg.to.peer_id,
		moderators = {},
        set_owner = member_id ,
        settings = {
          set_name = string.gsub(msg.to.title, '_', ' '),
		  lock_arabic = 'no',
		  lock_link = "no",
          flood = 'yes',
		  lock_spam = 'yes',
		  lock_sticker = 'no',
		  member = 'no',
		  public = 'no',
		  lock_rtl = 'no',
		  lock_tgservice = 'yes',
		  lock_contacts = 'no',
		  strict = 'no'
        }
      }
      save_data(_config.moderation.data, data)
      local groups = 'groups'
      if not data[tostring(groups)] then
        data[tostring(groups)] = {}
        save_data(_config.moderation.data, data)
      end
      data[tostring(groups)][tostring(msg.to.id)] = msg.to.id
      save_data(_config.moderation.data, data)
	  local text = '<b>SuperGroup\n|'..string.gsub(msg.to.print_name, '_', ' ')..'| has been added\nOrder By</b><b>|'..msg.from.id..'|</b>'
       return reply_msg(msg.id, text, ok_cb, false)
    end
  end
end

--Check Members #rem supergroup
local function check_member_superrem(cb_extra, success, result)
  local receiver = cb_extra.receiver
  local data = cb_extra.data
  local msg = cb_extra.msg
  for k,v in pairs(result) do
    local member_id = v.id
    if member_id ~= our_id then
	  -- Group configuration removal
      data[tostring(msg.to.id)] = nil
      save_data(_config.moderation.data, data)
      local groups = 'groups'
      if not data[tostring(groups)] then
        data[tostring(groups)] = nil
        save_data(_config.moderation.data, data)
      end
      data[tostring(groups)][tostring(msg.to.id)] = nil
      save_data(_config.moderation.data, data)
	  local text = '<b>SuperGroup|'..string.gsub(msg.to.print_name, '_', ' ')..'| has been removed\norder By</b><b>|'..msg.from.id..'|</b>'
      return reply_msg(msg.id, text, ok_cb, false)
    end
  end
end

--Function to Add supergroup
local function superadd(msg)
	local data = load_data(_config.moderation.data)
	local receiver = get_receiver(msg)
    channel_get_users(receiver, check_member_super,{receiver = receiver, data = data, msg = msg})
end

--Function to remove supergroup
local function superrem(msg)
	local data = load_data(_config.moderation.data)
    local receiver = get_receiver(msg)
    channel_get_users(receiver, check_member_superrem,{receiver = receiver, data = data, msg = msg})
end

--Get and output admins and bots in supergroup
local function callback(cb_extra, success, result)
local i = 1
local chat_name = string.gsub(cb_extra.msg.to.print_name, "_", " ")
local member_type = cb_extra.member_type
local text = member_type.." for "..chat_name..":\n"
for k,v in pairsByKeys(result) do
if not v.first_name then
	name = " "
else
	vname = v.first_name:gsub("‮", "")
	name = vname:gsub("_", " ")
	end
		text = text.."\n"..i.." - "..name.."["..v.peer_id.."]"
		i = i + 1
	end
    send_large_msg(cb_extra.receiver, text)
end

local function callback_clean_bots (extra, success, result)
	local msg = extra.msg
	local receiver = 'channel#id'..msg.to.id
	local channel_id = msg.to.id
	for k,v in pairs(result) do
		local bot_id = v.peer_id
		kick_user(bot_id,channel_id)
	end
end

--Get and output info about supergroup
local function callback_info(cb_extra, success, result)
local title ="<b> 💭Info for SuperGroup</b>: <b>["..result.title.."]</b>\n\n"
local admin_num = "<b> 💭Admin count</b>: <b>"..result.admins_count.."</b>\n"
local user_num = "<b> 💭User count</b>: <b>"..result.participants_count.."</b>\n"
local kicked_num = "<b> 💭Kicked user count</b>: <b>"..result.kicked_count.."</b>\n"
local channel_id = "<b> 💭ID</b>: <b>"..result.peer_id.."</b>\n"
if result.username then
	channel_username = "Username: @"..result.username
else
	channel_username = ""
end
local text = title..admin_num..user_num..kicked_num..channel_id..channel_username
    send_large_msg(cb_extra.receiver, text)
end

--Get and output members of supergroup
local function callback_who(cb_extra, success, result)
local text = "Members for "..cb_extra.receiver
local i = 1
for k,v in pairsByKeys(result) do
if not v.print_name then
	name = " "
else
	vname = v.print_name:gsub("‮", "")
	name = vname:gsub("_", " ")
end
	if v.username then
		username = " @"..v.username
	else
		username = ""
	end
	text = text.."\n"..i.." - "..name.." "..username.." [ "..v.peer_id.." ]\n"
	--text = text.."\n"..username
	i = i + 1
end
    local file = io.open("./groups/lists/supergroups/"..cb_extra.receiver..".txt", "w")
    file:write(text)
    file:flush()
    file:close()
    send_document(cb_extra.receiver,"./groups/lists/supergroups/"..cb_extra.receiver..".txt", ok_cb, false)
	post_msg(cb_extra.receiver, text, ok_cb, false)
end

--Get and output list of kicked users for supergroup
local function callback_kicked(cb_extra, success, result)
--vardump(result)
local text = "Kicked Members for SuperGroup "..cb_extra.receiver.."\n\n"
local i = 1
for k,v in pairsByKeys(result) do
if not v.print_name then
	name = " "
else
	vname = v.print_name:gsub("‮", "")
	name = vname:gsub("_", " ")
end
	if v.username then
		name = name.." @"..v.username
	end
	text = text.."\n"..i.." - "..name.." [ "..v.peer_id.." ]\n"
	i = i + 1
end
    local file = io.open("./groups/lists/supergroups/kicked/"..cb_extra.receiver..".txt", "w")
    file:write(text)
    file:flush()
    file:close()
    send_document(cb_extra.receiver,"./groups/lists/supergroups/kicked/"..cb_extra.receiver..".txt", ok_cb, false)
	--send_large_msg(cb_extra.receiver, text)
end

--Begin supergroup locks

-- Lock Media
local function lock_group_media(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_media_lock = data[tostring(target)]['settings']['media']
  if group_media_lock == 'yes' then
    return reply_msg(msg.id,'<b> 💭  Media is already locked\nOrder By</b><b>|'..msg.from.print_name..'|</b>\n🗯<b>GroupName|</b><b>'..msg.to.title..'|</b>', ok_cb, false)
  end
    data[tostring(target)]['settings']['media'] = 'yes'
    save_data(_config.moderation.data, data)
    return reply_msg(msg.id,'<b> 💭  Media has been locked\nOrder By</b><b>|'..msg.from.print_name..'| </b> \n🗯<b>GroupName|</b><b>'..msg.to.title..'|</b>', ok_cb, false)
  end

local function unlock_group_media(msg, data, target)
  if not is_momod(msg) then
    return 
  end
  local group_media_lock = data[tostring(target)]['settings']['media']
  if group_media_lock == 'no' then
  return reply_msg(msg.id,'<b> 💭  Meida is not locked \nOrder By</b><b>|'..msg.from.print_name..'|</b> \n🗯<b>GroupName|</b><b>'..msg.to.title..'|</b>', ok_cb, false)
  end
    data[tostring(target)]['settings']['media'] = 'no'
    save_data(_config.moderation.data, data)
    return reply_msg(msg.id,'<b> 💭  Media has been unlocked\nOrder By</b><b>|'..msg.from.print_name..'| </b> \n🗯<b>GroupName|</b><b>'..msg.to.title..'|</b>', ok_cb, false)
  end
  


-- Lock Join
local function lock_group_join(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_join_lock = data[tostring(target)]['settings']['join']
  if group_join_lock == 'yes' then
    return reply_msg(msg.id,'<b> 💭  Join is already locked\nOrder By</b><b>|'..msg.from.print_name..'|</b>\n🗯<b>GroupName|</b><b>'..msg.to.title..'|</b>', ok_cb, false)
  end
    data[tostring(target)]['settings']['join'] = 'yes'
    save_data(_config.moderation.data, data)
    return reply_msg(msg.id,'<b> 💭  Join has been locked\nOrder By</b><b>|'..msg.from.print_name..'| </b> \n🗯<b>GroupName|</b><b>'..msg.to.title..'|</b>', ok_cb, false)
  end

local function unlock_group_join(msg, data, target)
  if not is_momod(msg) then
    return 
  end
  local group_join_lock = data[tostring(target)]['settings']['join']
  if group_join_lock == 'no' then
  return reply_msg(msg.id,'<b> 💭  Join is not locked \nOrder By</b><b>|'..msg.from.print_name..'|</b> \n🗯<b>GroupName|</b><b>'..msg.to.title..'|</b>', ok_cb, false)
  end
    data[tostring(target)]['settings']['join'] = 'no'
    save_data(_config.moderation.data, data)
    return reply_msg(msg.id,'<b> 💭  Join has been unlocked\nOrder By</b><b>|'..msg.from.print_name..'| </b> \n🗯<b>GroupName|</b><b>'..msg.to.title..'|</b>', ok_cb, false)
  end
  


-- Lock Number
local function lock_group_number(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_number_lock = data[tostring(target)]['settings']['number']
  if group_number_lock == 'yes' then
    return reply_msg(msg.id,'<b> 💭  Number is already locked\nOrder By</b><b>|'..msg.from.print_name..'|</b>\n🗯<b>GroupName|</b><b>'..msg.to.title..'|</b>', ok_cb, false)
  end
    data[tostring(target)]['settings']['number'] = 'yes'
    save_data(_config.moderation.data, data)
    return reply_msg(msg.id,'<b> 💭  Number has been locked\nOrder By</b><b>|'..msg.from.print_name..'| </b> \n🗯<b>GroupName|</b><b>'..msg.to.title..'|</b>', ok_cb, false)
  end

local function unlock_group_number(msg, data, target)
  if not is_momod(msg) then
    return 
  end
  local group_number_lock = data[tostring(target)]['settings']['number']
  if group_number_lock == 'no' then
  return reply_msg(msg.id,'<b> 💭  Number is not locked \nOrder By</b><b>|'..msg.from.print_name..'|</b> \n🗯<b>GroupName|</b><b>'..msg.to.title..'|</b>', ok_cb, false)
  end
    data[tostring(target)]['settings']['number'] = 'no'
    save_data(_config.moderation.data, data)
    return reply_msg(msg.id,'<b> 💭  Number has been unlocked\nOrder By</b><b>|'..msg.from.print_name..'| </b> \n🗯<b>GroupName|</b><b>'..msg.to.title..'|</b>', ok_cb, false)
  end
  

-- Lock Inline  
local function lock_group_inline(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_inline_lock = data[tostring(target)]['settings']['inline']
  if group_inline_lock == 'yes' then
    return reply_msg(msg.id,'<b> 💭  Inline is already locked\nOrder By</b><b>|'..msg.from.print_name..'|</b>\n🗯<b>GroupName|</b><b>'..msg.to.title..'|</b>', ok_cb, false)
  end
    data[tostring(target)]['settings']['inline'] = 'yes'
    save_data(_config.moderation.data, data)
    return reply_msg(msg.id,'<b> 💭  Inline has been locked\nOrder By</b><b>|'..msg.from.print_name..'| </b>\n🗯<b>GroupName|</b><b>'..msg.to.title..'|</b>', ok_cb, false)
  end

local function unlock_group_inline(msg, data, target)
  if not is_momod(msg) then
    return 
  end
  local group_inline_lock = data[tostring(target)]['settings']['inline']
  if group_inline_lock == 'no' then
  return reply_msg(msg.id,'<b> 💭  Inline is not locked\nOrder By</b><b>|'..msg.from.print_name..'|</b>\n🗯<b>GroupName|</b><b>'..msg.to.title..'|</b>', ok_cb, false)
  end
    data[tostring(target)]['settings']['inline'] = 'no'
    save_data(_config.moderation.data, data)
    return reply_msg(msg.id,'<b> 💭  Inline has been unlocked\nOrder By</b><b>|'..msg.from.print_name..'| </b>\n🗯<b>GroupName|</b><b>'..msg.to.title..'|</b>', ok_cb, false)
  end

  
-- Lock Fosh  
local function lock_group_fosh(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_fosh_lock = data[tostring(target)]['settings']['fosh']
  if group_fosh_lock == 'yes' then
    return reply_msg(msg.id,'<b> 💭  Fosh is already locked\nOrder By</b><b>|'..msg.from.print_name..'|</b>\n🗯<b>GroupName|</b><b>'..msg.to.title..'|</b>', ok_cb, false)
  end
    data[tostring(target)]['settings']['fosh'] = 'yes'
    save_data(_config.moderation.data, data)
    return reply_msg(msg.id,'<b> 💭  Fosh has been locked\nOrder By</b><b>|'..msg.from.print_name..'| </b>\n🗯<b>GroupName|</b><b>'..msg.to.title..'|</b>', ok_cb, false)
  end

local function unlock_group_fosh(msg, data, target)
  if not is_momod(msg) then
    return 
  end
  local group_fosh_lock = data[tostring(target)]['settings']['fosh']
  if group_fosh_lock == 'no' then
  return reply_msg(msg.id,'<b> 💭  Fosh is not locked\nOrder By</b><b>|'..msg.from.print_name..'|</b>\n🗯<b>GroupName|</b><b>'..msg.to.title..'|</b>', ok_cb, false)
  end
    data[tostring(target)]['settings']['fosh'] = 'no'
    save_data(_config.moderation.data, data)
    return reply_msg(msg.id,'<b> 💭  Fosh has been unlocked\nOrder By</b><b>|'..msg.from.print_name..'| </b>\n🗯<b>GroupName|</b><b>'..msg.to.title..'|</b>', ok_cb, false)
  end

 --Lock Tag
  
 local function lock_group_tag(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_tag_lock = data[tostring(target)]['settings']['tag']
  if group_tag_lock == 'yes' then
    return reply_msg(msg.id,'<b> 💭  Tag is already locked\nOrder By</b><b>|'..msg.from.print_name..'|</b>\n🗯<b>GroupName|</b><b>'..msg.to.title..'|</b>', ok_cb, false)
  end
    data[tostring(target)]['settings']['tag'] = 'yes'
    save_data(_config.moderation.data, data)
    return reply_msg(msg.id,'<b> 💭  Tag has been locked\nOrder By</b><b>|'..msg.from.print_name..'| </b>\n🗯<b>GroupName|</b><b>'..msg.to.title..'|</b>', ok_cb, false)
  end

local function unlock_group_tag(msg, data, target)
  if not is_momod(msg) then
    return 
  end
  local group_tag_lock = data[tostring(target)]['settings']['tag']
  if group_tag_lock == 'no' then
  return reply_msg(msg.id,'<b> 💭  Tag is not locked\nOrder By</b><b>|'..msg.from.print_name..'|</b> \n🗯<b>GroupName|</b><b>'..msg.to.title..'|</b>', ok_cb, false)
  end
    data[tostring(target)]['settings']['tag'] = 'no'
    save_data(_config.moderation.data, data)
    return reply_msg(msg.id,'<b> 💭  Tag has been unlocked\nOrder By</b><b>|'..msg.from.print_name..'|</b>\n🗯<b>GroupName|</b><b>'..msg.to.title..'|</b>', ok_cb, false)
  end

-- Lock Cmds
  
  
local function lock_group_cmd(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_cmd_lock = data[tostring(target)]['settings']['cmd']
  if group_cmd_lock == 'yes' then
    return reply_msg(msg.id,'<b> 💭  Cmd is already locked\nOrder By</b><b>|'..msg.from.print_name..'|</b>\n🗯<b>GroupName|</b><b>'..msg.to.title..'|</b>', ok_cb, false)
  end
    data[tostring(target)]['settings']['cmd'] = 'yes'
    save_data(_config.moderation.data, data)
    return reply_msg(msg.id,'<b> 💭  Cmd has been locked\nOrder By</b><b>|'..msg.from.print_name..'| </b>\n🗯<b>GroupName|</b><b>'..msg.to.title..'|</b>', ok_cb, false)
  end

local function unlock_group_cmd(msg, data, target)
  if not is_momod(msg) then
    return 
  end
  local group_cmd_lock = data[tostring(target)]['settings']['cmd']
  if group_cmd_lock == 'no' then
  return reply_msg(msg.id,'<b> 💭  cmd is not locked\nOrder By</b><b>|'..msg.from.print_name..'|</b>\n🗯<b>GroupName|</b><b>'..msg.to.title..'|</b>', ok_cb, false)
  end
    data[tostring(target)]['settings']['tag'] = 'no'
    save_data(_config.moderation.data, data)
    return reply_msg(msg.id,'<b> 💭  cmd has been unlocked\nOrder By</b><b>|'..msg.from.print_name..'|</b>\n🗯<b>GroupName|</b><b>'..msg.to.title..'|</b>', ok_cb, false)
  end


--Lock Emoji
  
local function lock_group_emoji(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_emoji_lock = data[tostring(target)]['settings']['lock_emoji']
  if group_emoji_lock == 'yes' then
  return reply_msg(msg.id,'<b> 💭  Emoji is already locked\nOrder By</b><b>|'..msg.from.print_name..'|</b> \n🗯<b>GroupName|</b><b>'..msg.to.title..'|</b>', ok_cb, false)
  end
    data[tostring(target)]['settings']['lock_emoji'] = 'yes'
    save_data(_config.moderation.data, data)
    return reply_msg(msg.id,'<b> 💭  Emoji has been locked\nOrder By</b><b>|'..msg.from.print_name..'|</b> \n🗯<b>GroupName|</b><b>'..msg.to.title..'|</b>', ok_cb, false)
  end

local function unlock_group_emoji(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_emoji_lock = data[tostring(target)]['settings']['lock_emoji']
  if group_emoji_lock == 'no' then
  return reply_msg(msg.id,'<b> 💭  Emoji is not locked\nOrder By</b><b>|'..msg.from.print_name..'|</b>\n🗯<b>GroupName|</b><b>'..msg.to.title..'|</b>', ok_cb, false)
  end
    data[tostring(target)]['settings']['lock_emoji'] = 'no'
    save_data(_config.moderation.data, data)
  return reply_msg(msg.id,'<b> 💭  Emoji has been unlocked\nOrder By</b><b>|'..msg.from.print_name..'|</b>\n🗯<b>GroupName|</b><b>'..msg.to.title..'|</b>', ok_cb, false)
  end

--Lock Bots
  
local function lock_group_bots(msg, data, target)
  if not is_momod(msg) then
    return 
  end
  local group_bots_lock = data[tostring(target)]['settings']['lock_bots']
  if group_bots_lock == 'yes' then
  return reply_msg(msg.id,' <b> 💭  Bots protection is already enabled\nOrder By</b><b>|'..msg.from.print_name..'|</b>\n🗯<b>GroupName|</b><b>'..msg.to.title..'|</b>', ok_cb, false)
  end
    data[tostring(target)]['settings']['lock_bots'] = 'yes'
    save_data(_config.moderation.data, data)
  return reply_msg(msg.id,'<b> 💭  Bots protection has been enabled\nOrder By</b><b>|'..msg.from.print_name..'|</b>\n🗯<b>GroupName|</b><b>'..msg.to.title..'|</b>', ok_cb, false)
  end

local function unlock_group_bots(msg, data, target)
  if not is_momod(msg) then
    return 
  end
  local group_bots_lock = data[tostring(target)]['settings']['lock_bots']
  if group_bots_lock == 'no' then
 return reply_msg(msg.id,'<b> 💭  Bots protection is already disabled\nOrder By</b><b>|'..msg.from.print_name..'| </b>\n🗯<b>GroupName|</b><b>'..msg.to.title..'|</b>', ok_cb, false)
  end
    data[tostring(target)]['settings']['lock_bots'] = 'no'
    save_data(_config.moderation.data, data)
    return reply_msg(msg.id,'<b> 💭  Bots protection has been disabled\nOrder By</b><b>|'..msg.from.print_name..'| </b>\n🗯<b>GroupName|</b><b>'..msg.to.title..'|</b>', ok_cb, false)
  end

  --Lock Username

local function lock_group_username(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_username_lock = data[tostring(target)]['settings']['username']
  if group_username_lock == 'yes' then
   return reply_msg(msg.id,'<b> 💭  Username is already locked\nOrder By</b><b>|'..msg.from.print_name..'|</b>\n🗯<b>GroupName|</b><b>'..msg.to.title..'|</b>', ok_cb, false)
  end
    data[tostring(target)]['settings']['username'] = 'yes'
    save_data(_config.moderation.data, data)
    return reply_msg(msg.id,'<b> 💭  Username has been locked\nOrder By</b><b>|'..msg.from.print_name..'|</b>\n🗯<b>GroupName|</b><b>'..msg.to.title..'|</b>', ok_cb, false)
  end

local function unlock_group_username(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_username_lock = data[tostring(target)]['settings']['username']
  if group_username_lock == 'no' then
    return reply_msg(msg.id,'<b> 💭  Username is not locked\nOrder By</b><b>|'..msg.from.print_name..'|</b>\n🗯<b>GroupName|</b><b>'..msg.to.title..'|</b>', ok_cb, false)
  end
    data[tostring(target)]['settings']['username'] = 'no'
    save_data(_config.moderation.data, data)
    return reply_msg(msg.id,'<b> 💭  Username has been unlocked\nOrder By</b><b>|'..msg.from.print_name..'|</b>\n🗯<b>GroupName|</b><b>'..msg.to.title..'|</b>', ok_cb, false)
  end

--Lock English
  
local function lock_group_english(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_english_lock = data[tostring(target)]['settings']['english']
  if group_english_lock == 'yes' then
   return reply_msg(msg.id,'<b> 💭  English is already locked\nOrder By</b><b>|'..msg.from.print_name..'|</b>\n🗯<b>GroupName|</b><b>'..msg.to.title..'|</b>', ok_cb, false)
  end
    data[tostring(target)]['settings']['english'] = 'yes'
    save_data(_config.moderation.data, data)
    return reply_msg(msg.id,'<b> 💭  English has been locked\nOrder By</b><b>|'..msg.from.print_name..'|</b>\n🗯<b>GroupName|</b><b>'..msg.to.title..'|</b>', ok_cb, false)
  end

local function unlock_group_english(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_english_lock = data[tostring(target)]['settings']['english']
  if group_english_lock == 'no' then
    return reply_msg(msg.id,'<b> 💭  English is not locked\nOrder By</b><b>|'..msg.from.print_name..'|</b>\n🗯<b>GroupName|</b><b>'..msg.to.title..'|</b>', ok_cb, false)
  end
    data[tostring(target)]['settings']['english'] = 'no'
    save_data(_config.moderation.data, data)
    return reply_msg(msg.id,'<b> 💭  English has been unlocked\nOrder By</b><b>|'..msg.from.print_name..'|</b>\n🗯<b>GroupName|</b><b>'..msg.to.title..'|</b>', ok_cb, false)
  end

--Lock Forward  
  
local function lock_group_fwd(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_fwd_lock = data[tostring(target)]['settings']['lock_fwd']
  if group_fosh_lock == 'yes' then
    return reply_msg(msg.id,'<b> 💭  Forward posting is already locked\nOrder By</b><b>|'..msg.from.print_name..'|</b\n🗯<b>GroupName|</b><b>'..msg.to.title..'|</b>', ok_cb, false)
  end
    data[tostring(target)]['settings']['lock_fwd'] = 'yes'
    save_data(_config.moderation.data, data)
    return reply_msg(msg.id,' <b> 💭  Forward has been locked\nOrder By</b><b>|'..msg.from.print_name..'|</b>\n🗯<b>GroupName|</b><b>'..msg.to.title..'|</b>', ok_cb, false)
  end

local function unlock_group_fwd(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_fwd_lock = data[tostring(target)]['settings']['lock_fwd']
  if group_fwd_lock == 'no' then
  return reply_msg(msg.id,' <b> 💭  Forward is not locked\nOrder By</b><b>|'..msg.from.print_name..'|</b>\n🗯<b>GroupName|</b><b>'..msg.to.title..'|</b>', ok_cb, false)
  end
    data[tostring(target)]['settings']['lock_fwd'] = 'no'
    save_data(_config.moderation.data, data)
    return reply_msg(msg.id,'<b> 💭  Forward has been unlocked\nOrder By</b><b>|'..msg.from.print_name..'|</b>\n🗯<b>GroupName|</b><b>'..msg.to.title..'|</b>', ok_cb, false)
  end

--Lock Links 
 
local function lock_group_links(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_link_lock = data[tostring(target)]['settings']['lock_link']
  if group_link_lock == 'yes' then
    return reply_msg(msg.id,'<b> 💭  Link posting is already locked\nOrder By</b><b>|'..msg.from.print_name..'|</b>\n🗯<b>GroupName|</b><b>'..msg.to.title..'|</b>', ok_cb, false)
  else
    data[tostring(target)]['settings']['lock_link'] = 'yes'
    save_data(_config.moderation.data, data)
  return reply_msg(msg.id,'<b> 💭  Link posting has been locked\nOrder By</b><b>|'..msg.from.print_name..'|</b>\n🗯<b>GroupName|</b><b>'..msg.to.title..'|</b>', ok_cb, false)
  end
end

local function unlock_group_links(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_link_lock = data[tostring(target)]['settings']['lock_link']
  if group_link_lock == 'no' then
    return reply_msg(msg.id,'<b> 💭  Link posting is not locked\nOrder By</b><b>|'..msg.from.print_name..'|</b>\n🗯<b>GroupName|</b><b>'..msg.to.title..'|</b>', ok_cb, false)
  else
    data[tostring(target)]['settings']['lock_link'] = 'no'
    save_data(_config.moderation.data, data)
    return reply_msg(msg.id,'<b> 💭  Link posting has been unlocked\nOrder By</b><b>|'..msg.from.print_name..'|</b>\n🗯<b>GroupName|</b><b>'..msg.to.title..'|</b>', ok_cb, false)
  end
end

--Lock Spam

local function lock_group_spam(msg, data, target)
  if not is_momod(msg) then
    return
  end
  if not is_owner(msg) then
    return "<b>Owners only!</b>"
  end
  local group_spam_lock = data[tostring(target)]['settings']['lock_spam']
  if group_spam_lock == 'yes' then
    return reply_msg(msg.id,'<b>S 💭  uperGroup spam is already locked\nOrder By</b><b>|'..msg.from.print_name..'|</b>\n🗯<b>GroupName|</b><b>'..msg.to.title..'|</b>', ok_cb, false)
  else
    data[tostring(target)]['settings']['lock_spam'] = 'yes'
    save_data(_config.moderation.data, data)
    return reply_msg(msg.id,'<b> 💭  SuperGroup spam has been locked\nOrder By</b><b>|'..msg.from.print_name..'|</b>\n🗯<b>GroupName|</b><b>'..msg.to.title..'|</b>', ok_cb, false)
  end
end

local function unlock_group_spam(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_spam_lock = data[tostring(target)]['settings']['lock_spam']
  if group_spam_lock == 'no' then
    return reply_msg(msg.id,'<b> 💭  SuperGroup spam is not locked\nOrder By</b><b>|'..msg.from.print_name..'|</b>\n🗯<b>GroupName|</b><b>'..msg.to.title..'|</b>', ok_cb, false)
  else
    data[tostring(target)]['settings']['lock_spam'] = 'no'
    save_data(_config.moderation.data, data)
    return reply_msg(msg.id,'<b> 💭  SuperGroup spam has been unlocked\nOrder By</b><b>|'..msg.from.print_name..'|</b>\n🗯<b>GroupName|</b><b>'..msg.to.title..'|</b>', ok_cb, false)
  end
end

--Lock Flood

local function lock_group_flood(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_flood_lock = data[tostring(target)]['settings']['flood']
  if group_flood_lock == 'yes' then
    return reply_msg(msg.id,'<b> 💭  Flood is already locked\nOrder By</b><b>|'..msg.from.print_name..'|</b>\n🗯<b>GroupName|</b><b>'..msg.to.title..'|</b>', ok_cb, false)
  else
    data[tostring(target)]['settings']['flood'] = 'yes'
    save_data(_config.moderation.data, data)
    return reply_msg(msg.id,'<b> 💭  Flood has been locked\nOrder By</b><b>|'..msg.from.print_name..'|</b>\n🗯<b>GroupName|</b><b>'..msg.to.title..'|</b>', ok_cb, false)
  end
end

local function unlock_group_flood(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_flood_lock = data[tostring(target)]['settings']['flood']
  if group_flood_lock == 'no' then
    return reply_msg(msg.id,'<b>Flood is not locked\nOrder By</b><b>|'..msg.from.print_name..'|</b>\n🗯<b>GroupName|</b><b>'..msg.to.title..'|</b>', ok_cb, false)
  else
    data[tostring(target)]['settings']['flood'] = 'no'
    save_data(_config.moderation.data, data)
    return reply_msg(msg.id,'<b>Flood has been unlocked\nOrder By</b><b>|'..msg.from.print_name..'|</b>\n🗯<b>GroupName|</b><b>'..msg.to.title..'|</b>', ok_cb, false)
  end
end

--Lock Arabic

local function lock_group_arabic(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_arabic_lock = data[tostring(target)]['settings']['lock_arabic']
  if group_arabic_lock == 'yes' then
    return reply_msg(msg.id,'<b> 💭  Arabic is already locked\nOrder By</b><b>|'..msg.from.print_name..'|</b>\n🗯<b>GroupName|</b><b>'..msg.to.title..'|</b>', ok_cb, false)
  else
    data[tostring(target)]['settings']['lock_arabic'] = 'yes'
    save_data(_config.moderation.data, data)
    return reply_msg(msg.id,'<b> 💭  Arabic has been locked\nOrder By</b><b>|'..msg.from.print_name..'|</b>\n🗯<b>GroupName|</b><b>'..msg.to.title..'|</b>', ok_cb, false)
  end
end

local function unlock_group_arabic(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_arabic_lock = data[tostring(target)]['settings']['lock_arabic']
  if group_arabic_lock == 'no' then
    return reply_msg(msg.id,'<b> 💭  Arabic/Persian is already unlocked\nOrder By</b><b>|'..msg.from.print_name..'|</b>\n🗯<b>GroupName|</b><b>'..msg.to.title..'|</b>', ok_cb, false)
  else
    data[tostring(target)]['settings']['lock_arabic'] = 'no'
    save_data(_config.moderation.data, data)
    return reply_msg(msg.id,'<b> 💭  Arabic/Persian has been unlocked\nOrder By</b><b>|'..msg.from.print_name..'|</b>\n🗯<b>GroupName|</b><b>'..msg.to.title..'|</b>', ok_cb, false)
  end
end

--Lock Members

local function lock_group_membermod(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_member_lock = data[tostring(target)]['settings']['lock_member']
  if group_member_lock == 'yes' then
    return reply_msg(msg.id,'<b> 💭  SuperGroup members are already locked\nOrder By</b><b>|'..msg.from.print_name..'|</b>\n🗯<b>GroupName|</b><b>'..msg.to.title..'|</b>', ok_cb, false)
  else
    data[tostring(target)]['settings']['lock_member'] = 'yes'
    save_data(_config.moderation.data, data)
  end
  return reply_msg(msg.id,'<b> 💭  SuperGroup members has been locked\nOrder By</b><b>|'..msg.from.print_name..'|</b>\n🗯<b>GroupName|</b><b>'..msg.to.title..'|</b>', ok_cb, false)
end

local function unlock_group_membermod(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_member_lock = data[tostring(target)]['settings']['lock_member']
  if group_member_lock == 'no' then
    return reply_msg(msg.id,'<b> 💭  SuperGroup members are not locked\nOrder By</b><b>|'..msg.from.print_name..'|</b>\n🗯<b>GroupName|</b><b>'..msg.to.title..'|</b>', ok_cb, false)
  else
    data[tostring(target)]['settings']['lock_member'] = 'no'
    save_data(_config.moderation.data, data)
    return reply_msg(msg.id,'<b> 💭  SuperGroup members has been unlocked\nOrder By</b><b>|'..msg.from.print_name..'|</b>\n🗯<b>GroupName|</b><b>'..msg.to.title..'|</b>', ok_cb, false)
  end
end

--Lock Rtl

local function lock_group_rtl(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_rtl_lock = data[tostring(target)]['settings']['lock_rtl']
  if group_rtl_lock == 'yes' then
    return reply_msg(msg.id,'<b> 💭  RTL is already locked\nOrder By</b><b>|'..msg.from.print_name..'|</b>\n🗯<b>GroupName|</b><b>'..msg.to.title..'|</b>', ok_cb, false)
  else
    data[tostring(target)]['settings']['lock_rtl'] = 'yes'
    save_data(_config.moderation.data, data)
    return reply_msg(msg.id,'<b> 💭  RTL has been locked\nOrder By</b><b>|'..msg.from.print_name..'|</b>\n🗯<b>GroupName|</b><b>'..msg.to.title..'|</b>', ok_cb, false)
  end
end

local function unlock_group_rtl(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_rtl_lock = data[tostring(target)]['settings']['lock_rtl']
  if group_rtl_lock == 'no' then
    return reply_msg(msg.id,'<b> 💭  RTL is already unlocked\nOrder By</b><b>|'..msg.from.print_name..'|</b>\n🗯<b>GroupName|</b><b>'..msg.to.title..'|</b>', ok_cb, false)
  else
    data[tostring(target)]['settings']['lock_rtl'] = 'no'
    save_data(_config.moderation.data, data)
    return reply_msg(msg.id,'<b> 💭  RTL has been unlocked\nOrder By</b><b>|'..msg.from.print_name..'|</b>\n🗯<b>GroupName|</b><b>'..msg.to.title..'|</b>', ok_cb, false)
  end
end

--Lock TgService

local function lock_group_tgservice(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_tgservice_lock = data[tostring(target)]['settings']['lock_tgservice']
  if group_tgservice_lock == 'yes' then
    return reply_msg(msg.id,'<b> 💭  Tgservice is already locked\nOrder By</b><b>|'..msg.from.print_name..'|</b>\n🗯<b>GroupName|</b><b>'..msg.to.title..'|</b>', ok_cb, false)
  else
    data[tostring(target)]['settings']['lock_tgservice'] = 'yes'
    save_data(_config.moderation.data, data)
    return reply_msg(msg.id,'Tgservice has been locked\nOrder By</b><b>|'..msg.from.print_name..'|</b>\n🗯<b>GroupName|</b><b>'..msg.to.title..'|</b>', ok_cb, false)
  end
end

local function unlock_group_tgservice(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_tgservice_lock = data[tostring(target)]['settings']['lock_tgservice']
  if group_tgservice_lock == 'no' then
    return reply_msg(msg.id,'<b> 💭  TgService Is Not Locked!\nOrder By</b><b>|'..msg.from.print_name..'|</b>\n🗯<b>GroupName|</b><b>'..msg.to.title..'|</b>', ok_cb, false)
  else
    data[tostring(target)]['settings']['lock_tgservice'] = 'no'
    save_data(_config.moderation.data, data)
    return reply_msg(msg.id,'<b> 💭  Tgservice has been unlocked\nOrder By</b><b>|'..msg.from.print_name..'|</b>\n🗯<b>GroupName|</b><b>'..msg.to.title..'|</b>', ok_cb, false)
  end
end

--Lock Sticker

local function lock_group_sticker(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_sticker_lock = data[tostring(target)]['settings']['lock_sticker']
  if group_sticker_lock == 'yes' then
    return reply_msg(msg.id,'<b> 💭  Sticker posting is already locked\nOrder By</b><b>|'..msg.from.print_name..'|</b>\n🗯<b>GroupName|</b><b>'..msg.to.title..'|</b>', ok_cb, false)
  else
    data[tostring(target)]['settings']['lock_sticker'] = 'yes'
    save_data(_config.moderation.data, data)
    return reply_msg(msg.id,'<b> 💭  Sticker posting has been locked\nOrder By</b><b>|'..msg.from.print_name..'|</b>\n🗯<b>GroupName|</b><b>'..msg.to.title..'|</b>', ok_cb, false)
  end
end

local function unlock_group_sticker(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_sticker_lock = data[tostring(target)]['settings']['lock_sticker']
  if group_sticker_lock == 'no' then
    return reply_msg(msg.id,'<b> 💭  Sticker posting is already unlocked\nOrder By</b><b>|'..msg.from.print_name..'|</b>\n🗯<b>GroupName|</b><b>'..msg.to.title..'|</b>', ok_cb, false)
  else
    data[tostring(target)]['settings']['lock_sticker'] = 'no'
    save_data(_config.moderation.data, data)
    return reply_msg(msg.id,'<b> 💭  Sticker posting has been unlocked\nOrder By</b><b>|'..msg.from.print_name..'|</b>\n🗯<b>GroupName|</b><b>'..msg.to.title..'|</b>', ok_cb, false)
  end
end

--Lock Contact

local function lock_group_contacts(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_contacts_lock = data[tostring(target)]['settings']['lock_contacts']
  if group_contacts_lock == 'yes' then
    return reply_msg(msg.id,'<b> 💭  Contact posting is already locked\nOrder By</b><b>|'..msg.from.print_name..'|</b>\n🗯<b>GroupName|</b><b>'..msg.to.title..'|</b>', ok_cb, false)
  else
    data[tostring(target)]['settings']['lock_contacts'] = 'yes'
    save_data(_config.moderation.data, data)
    return reply_msg(msg.id,'<b> 💭  Contact posting has been locked\nOrder By</b><b>|'..msg.from.print_name..'|</b>\n🗯<b>GroupName|</b><b>'..msg.to.title..'|</b>', ok_cb, false)
  end
end

local function unlock_group_contacts(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_contacts_lock = data[tostring(target)]['settings']['lock_contacts']
  if group_contacts_lock == 'no' then
    return reply_msg(msg.id,'<b> 💭  Contact posting is already unlocked\nOrder By</b><b>|'..msg.from.print_name..'|</b>\n🗯<b>GroupName|</b><b>'..msg.to.title..'|</b>', ok_cb, false)
  else
    data[tostring(target)]['settings']['lock_contacts'] = 'no'
    save_data(_config.moderation.data, data)
    return reply_msg(msg.id,'<b> 💭  Contact posting has been unlocked\nOrder By</b><b>|'..msg.from.print_name..'|</b>\n🗯<b>GroupName|</b><b>'..msg.to.title..'|</b>', ok_cb, false)
  end
end

-- Welcome Massege

local function lock_group_welcome(msg, data, target)
      if not is_momod(msg) then
        return "<b>Just Group Admins</b>"
      end
  local welcoms = data[tostring(target)]['settings']['welcome']
  if welcoms == 'yes' then
    return reply_msg(msg.id,'<b>Welcome Is On </b>', ok_cb, false)
  else
    data[tostring(target)]['settings']['welcome'] = 'yes'
    save_data(_config.moderation.data, data)
    return reply_msg(msg.id,'<b>Welcome On For SetGroup Welcome Use /setwlc Text </b>', ok_cb, false)
  end
end
local function unlock_group_welcome(msg, data, target)
      if not is_momod(msg) then
        return "<b>Just Group Admins</b>"
      end
  local welcoms = data[tostring(target)]['settings']['welcome']
  if welcoms == 'no' then
    return reply_msg(msg.id,'<b>Welcome Is Off</b>', ok_cb, false)
  else
    data[tostring(target)]['settings']['welcome'] = 'no'
    save_data(_config.moderation.data, data)
    return reply_msg(msg.id,'<b>Welcome Masseig Off</b>', ok_cb, false)
  end
end

--Strict Settings

local function enable_strict_rules(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_strict_lock = data[tostring(target)]['settings']['strict']
  if group_strict_lock == 'yes' then
    return reply_msg(msg.id,'<b>Settings are already strictly enforced\nOrder By</b><b>|'..msg.from.print_name..'|</b>', ok_cb, false)
  else
    data[tostring(target)]['settings']['strict'] = 'yes'
    save_data(_config.moderation.data, data)
    return reply_msg(msg.id,'<b>Settings will be strictly enforced\nOrder By</b><b>|'..msg.from.print_name..'|</b>', ok_cb, false)
  end
end

local function disable_strict_rules(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_strict_lock = data[tostring(target)]['settings']['strict']
  if group_strict_lock == 'no' then
    return reply_msg(msg.id,'<b>Settings are not strictly enforced\nOrder By</b><b>|'..msg.from.print_name..'|</b>', ok_cb, false)
  else
    data[tostring(target)]['settings']['strict'] = 'no'
    save_data(_config.moderation.data, data)
    return reply_msg(msg.id,'<b>Settings will not be strictly enforced\nOrder By</b><b>|'..msg.from.print_name..'|</b>', ok_cb, false)
  end
end
--End supergroup locks

--'Set supergroup rules' function
local function set_rulesmod(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local data_cat = 'rules'
  data[tostring(target)][data_cat] = rules
  save_data(_config.moderation.data, data)
  return reply_msg(msg.id,'<b>SuperGroup rules set\nOrder By</b><b>|'..msg.from.print_name..'|</b>', ok_cb, false)
end

--'Get supergroup rules' function
local function get_rules(msg, data)
  local data_cat = 'rules'
  if not data[tostring(msg.to.id)][data_cat] then
    return reply_msg(msg.id,'<b>No rules available.</b>', ok_cb, false)
  end
  local rules = data[tostring(msg.to.id)][data_cat]
  local group_name = data[tostring(msg.to.id)]['settings']['set_name']
  local rules = '<code>'..group_name..'</code> <b>rules</b>:\n\n<code>'..rules:gsub("/n", " ")..'</code>'
  reply_msg(msg.id,rules, ok_cb, false)
end

--Set supergroup to public or not public function
local function set_public_membermod(msg, data, target)
  if not is_momod(msg) then
    return reply_msg(msg.id,"<b>For moderators only</b>", ok_cb, false)
  end
  local group_public_lock = data[tostring(target)]['settings']['public']
  local long_id = data[tostring(target)]['long_id']
  if not long_id then
	data[tostring(target)]['long_id'] = msg.to.peer_id
	save_data(_config.moderation.data, data)
  end
  if group_public_lock == 'yes' then
    return reply_msg(msg.id,'<b>Group is already public\nOrder By</b><b>|'..msg.from.print_name..'|</b>', ok_cb, false)
  else
    data[tostring(target)]['settings']['public'] = 'yes'
    save_data(_config.moderation.data, data)
  end
  return reply_msg(msg.id,'<b>SuperGroup is now: public\nOrder By</b><b>|'..msg.from.print_name..'|</b>', ok_cb, false)
end

local function unset_public_membermod(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_public_lock = data[tostring(target)]['settings']['public']
  local long_id = data[tostring(target)]['long_id']
  if not long_id then
	data[tostring(target)]['long_id'] = msg.to.peer_id
	save_data(_config.moderation.data, data)
  end
  if group_public_lock == 'no' then
    return reply_msg(msg.id, '<b>Group is not public\nOrder By</b><b>|'..msg.from.print_name..'|</b>', ok_cb, false)
  else
    data[tostring(target)]['settings']['public'] = 'no'
	data[tostring(target)]['long_id'] = msg.to.long_id
    save_data(_config.moderation.data, data)
    return reply_msg(msg.id, '<b>SuperGroup is now: not public\nOrder By</b><b>|'..msg.from.print_name..'|</b>', ok_cb, false)
  end
end

--Show supergroup settings; function
function show_supergroup_settingsmod(msg, target)
 	if not is_momod(msg) then
    	return
  	end
	local data = load_data(_config.moderation.data)
    if data[tostring(target)] then
     	if data[tostring(target)]['settings']['flood_msg_max'] then
        	NUM_MSG_MAX = tonumber(data[tostring(target)]['settings']['flood_msg_max'])
        	print('custom'..NUM_MSG_MAX)
      	else
        	NUM_MSG_MAX = 7
      	end
    end
	if data[tostring(target)]['settings'] then
		if not data[tostring(target)]['settings']['public'] then
			data[tostring(target)]['settings']['public'] = 'no'
		end
	end
	if data[tostring(target)]['settings'] then
		if not data[tostring(target)]['settings']['tag'] then
			data[tostring(target)]['settings']['tag'] = 'no'
		end
	end
	if data[tostring(target)]['settings'] then
		if not data[tostring(target)]['settings']['username'] then
			data[tostring(target)]['settings']['username'] = 'no'
		end
	end
	if data[tostring(target)]['settings'] then
		if not data[tostring(target)]['settings']['lock_contacts'] then
			data[tostring(target)]['settings']['lock_contacts'] = 'no'
		end
	end
	if data[tostring(target)]['settings'] then
		if not data[tostring(target)]['settings']['english'] then
			data[tostring(target)]['settings']['english'] = 'no'
		end
	end
	if data[tostring(target)]['settings'] then
		if not data[tostring(target)]['settings']['lock_rtl'] then
			data[tostring(target)]['settings']['lock_rtl'] = 'no'
		end
    end
      if data[tostring(target)]['settings'] then
		if not data[tostring(target)]['settings']['lock_tgservice'] then
			data[tostring(target)]['settings']['lock_tgservice'] = 'no'
		end
	end
	if data[tostring(target)]['settings'] then
		if not data[tostring(target)]['settings']['media'] then
			data[tostring(target)]['settings']['media'] = 'no'
		end
	end
	if data[tostring(target)]['settings'] then
       if not data[tostring(target)]['settings']['lock_emoji'] then
           data[tostring(target)]['settings']['lock_emoji'] = 'no'
       end
    end
	if data[tostring(target)]['settings'] then
       if not data[tostring(target)]['settings']['lock_fwd'] then
              data[tostring(target)]['settings']['lock_fwd'] = 'no'
        end
    end
	if data[tostring(target)]['settings'] then
       if not data[tostring(target)]['settings']['inline'] then
              data[tostring(target)]['settings']['inline'] = 'no'
        end
    end
	if data[tostring(target)]['settings'] then
       if not data[tostring(target)]['settings']['join'] then
              data[tostring(target)]['settings']['join'] = 'no'
        end
    end
	if data[tostring(target)]['settings'] then
       if not data[tostring(target)]['settings']['number'] then
              data[tostring(target)]['settings']['number'] = 'no'
        end
    end	
	if data[tostring(target)]['settings'] then
       if not data[tostring(target)]['settings']['cmd'] then
              data[tostring(target)]['settings']['cmd'] = 'no'
        end
    end
	if data[tostring(target)]['settings'] then
       if not data[tostring(target)]['settings']['fosh'] then
              data[tostring(target)]['settings']['fosh'] = 'no'
        end
    end
		if data[tostring(target)]['settings'] then
       if not data[tostring(target)]['settings']['lock_link'] then
              data[tostring(target)]['settings']['lock_link'] = 'no'
        end
    end
	local expiretime = redis:hget('expiretime', get_receiver(msg))
    local expire = ''
  if not expiretime then
  expire = expire..'Unlimited'
  else
   local now = tonumber(os.time())
   expire =  expire..math.floor((tonumber(expiretime) - tonumber(now)) / 86400) + 1
 end
	local bots_protection = "yes"
    if data[tostring(target)]['settings']['lock_bots'] then
    	bots_protection = data[tostring(target)]['settings']['lock_bots'] 
     	end 
	if data[tostring(target)]['settings'] then
		if not data[tostring(target)]['settings']['lock_member'] then
			data[tostring(target)]['settings']['lock_member'] = 'no'
		end
	end
	local gp_type = data[tostring(msg.to.id)]['group_type']
	
if is_muted(tostring(target), 'Audio: yes') then
 Audio = 'yes'
 else
 Audio = 'no'
 end
    if is_muted(tostring(target), 'Photo: yes') then
 Photo = 'yes'
 else
 Photo = 'no'
 end
    if is_muted(tostring(target), 'Video: yes') then
 Video = 'yes'
 else
 Video = 'no'
 end
    if is_muted(tostring(target), 'Gifs: yes') then
 Gifs = 'yes'
 else
 Gifs = 'no'
 end
 if is_muted(tostring(target), 'Documents: yes') then
 Documents = 'yes'
 else
 Documents = 'no'
 end
 if is_muted(tostring(target), 'Text: yes') then
 Text = 'yes'
 else
 Text = 'no'
 end
  if is_muted(tostring(target), 'All: yes') then
 All = 'yes'
 else
 All = 'no'
 end
	local welcome = "yes"
    if  data[tostring(msg.to.id)]['welcome'] then
    welcome = data[tostring(msg.to.id)]['welcome']
    end
  local settings = data[tostring(target)]['settings']
  local text = " <b>─═हईSuperGroup Settingsईह═─ </b> \n➖➖➖➖➖➖➖➖\n<b> 》Lock</b> #Links ➣ <b>"..settings.lock_link.."</b>\n<b> 》Lock</b> ّ#Flood➣ <b>"..settings.flood.."</b>\n<b> 》Lock</b> #Spam➣ <b>"..settings.lock_spam.."</b>\n<b> 》Lock</b> #Arabic➣ <b>"..settings.lock_arabic.."</b>\n<b> 》Lock</b> #Member➣ <b>"..settings.lock_member.."</b>\n<b> 》Lock</b> #Contact➣ <b>"..settings.lock_contacts.."</b>\n<b> 》Lock</b> #RTL➣ <b>"..settings.lock_rtl.."</b>\n<b> 》Lock</b> #Tgservice ➣ <b>"..settings.lock_tgservice.."</b>\n<b> 》Lock</b> #sticker➣ <b>"..settings.lock_sticker.."</b>\n<b> 》Lock</b> #Tag➣ <b>"..settings.tag.."</b>\n<b> 》Lock</b> #Username➣ <b>"..settings.username.."</b>\n<b> 》Lock</b> #Inline➣ <b>"..settings.inline.."</b>\n<b> 》Lock</b> #Fosh➣ <b>"..settings.fosh.."</b>\n<b> 》Lock</b> #Bots➣ <b>"..bots_protection.."</b>\n<b> 》Lock</b> #Cmd ➣ <b>"..settings.cmd.."</b>\n<b> 》Lock</b> #Media ➣ <b>"..settings.media.."</b>\n<b> 》Lock</b> #English➣ <b>"..settings.english.."</b>\n<b> 》Lock</b> #Forward➣ <b>"..settings.lock_fwd.."</b>\n<b> 》Lock</b> #Emoji➣ <b>"..settings.lock_emoji.."</b>\n<b> 》Lock</b> #Number➣ <b>"..settings.number.."</b>\n<b> 》Lock</b> #Join ➣ <b>"..settings.join.."</b>\n➖➖➖➖➖➖➖➖\n<b> ─═हईOther Settingsईह═─ </b>\n<b> 》Public</b>➣ <b>"..settings.public.."</b>\n<b> 》Flood</b> #Sensitivity ➣ "..NUM_MSG_MAX.."\n<b> 》Strict</b> #Settings➣ <b>"..settings.strict.."</b>\n<b> 》Welcome </b> #Massege➣ <b>"..welcome.."</b>\n<b> 》Group </b> #Type➣ <code>"..gp_type.."</code>\n<b> 》Expire</b> #Time➣ <b>"..expire.."</b>\n➖➖➖➖➖➖➖➖\n<b>─═हईMuteListईह═─</b>\n<b> 》Mute</b> #Audio ➣ <i>"..Audio.."</i>\n<b> 》Mute</b> #photo ➣ <i>"..Photo.."</i>\n<b> 》Mute</b> #video ➣ <i>"..Video.."</i>\n<b> 》Mute</b> #Gifs ➣ <i>"..Gifs.."</i>\n<b> 》Mute</b> #Documents ➣ <i>"..Documents.."</i>\n<b> 》Mute</b> #Text ➣ <i>"..Text.."</i>\n<b> 》Mute</b> #All <i>➣ "..All.."</i>\n➖➖➖➖➖➖➖➖\n<b>─═हईAbout SuperGroupईह═─</b>\n<b> 》SuperGroup </b> #Name➣ <code>"..msg.to.title.."</code>\n<b> 》Settings </b> #Requste➣ <b>"..msg.from.first_name.."</b>\n"
if string.match(text, 'yes') then text = string.gsub(text, 'yes', '[ + ]') end
if string.match(text, 'no') then text = string.gsub(text, 'no', '[ - ]') end
if string.match(text, '1') then text = string.gsub(text, '1', '1⃣') end
if string.match(text, '2') then text = string.gsub(text, '2', '2⃣') end
if string.match(text, '3') then text = string.gsub(text, '3', '3⃣') end
if string.match(text, '4') then text = string.gsub(text, '4', '4⃣') end
if string.match(text, '5') then text = string.gsub(text, '5', '5⃣') end
if string.match(text, '6') then text = string.gsub(text, '6', '6⃣') end
if string.match(text, '7') then text = string.gsub(text, '7', '7⃣') end
if string.match(text, '8') then text = string.gsub(text, '8', '8⃣') end
if string.match(text, '9') then text = string.gsub(text, '9', '9⃣') end
if string.match(text, '0') then text = string.gsub(text, '0', '0⃣') end
return reply_msg(msg.id,text , ok_cb, false)
end

local function promote_admin(receiver, member_username, user_id)
  local data = load_data(_config.moderation.data)
  local group = string.gsub(receiver, 'channel#id', '')
  local member_tag_username = string.gsub(member_username, '@', '(at)')
  if not data[group] then
    return
  end
  if data[group]['moderators'][tostring(user_id)] then
    return send_large_msg(receiver, member_username..' <b> 💭  is already a moderator.</b>')
  end
  data[group]['moderators'][tostring(user_id)] = member_tag_username
  save_data(_config.moderation.data, data)
end

local function demote_admin(receiver, member_username, user_id)
  local data = load_data(_config.moderation.data)
  local group = string.gsub(receiver, 'channel#id', '')
  if not data[group] then
    return
  end
  if not data[group]['moderators'][tostring(user_id)] then
    return send_large_msg(receiver, member_tag_username..' <b> 💭  is not a moderator.</b>')
  end
  data[group]['moderators'][tostring(user_id)] = nil
  save_data(_config.moderation.data, data)
end

local function promote2(receiver, member_username, user_id)
  local data = load_data(_config.moderation.data)
  local group = string.gsub(receiver, 'channel#id', '')
  local member_tag_username = string.gsub(member_username, '@', '(at)')
  if not data[group] then
    return send_large_msg(receiver, '<b>SuperGroup is not added.</b>')
  end
  if data[group]['moderators'][tostring(user_id)] then
    return send_large_msg(receiver, member_username..' <b> 💭  is already a moderator.</b>')
  end
  data[group]['moderators'][tostring(user_id)] = member_tag_username
  save_data(_config.moderation.data, data)
  send_large_msg(receiver, member_username..' <b> 💭  has been promoted.</b>')
end

local function demote2(receiver, member_username, user_id)
  local data = load_data(_config.moderation.data)
  local group = string.gsub(receiver, 'channel#id', '')
  if not data[group] then
    return send_large_msg(receiver, '<b>Group is not added.</b>')
  end
  if not data[group]['moderators'][tostring(user_id)] then
    return send_large_msg(receiver, member_tag_username..'<b> 💭  is not a moderator.</b>')
  end
  data[group]['moderators'][tostring(user_id)] = nil
  save_data(_config.moderation.data, data)
  send_large_msg(receiver, member_username..' <b> 💭  has been demoted.</b>')
end

local function modlist(msg)
  local data = load_data(_config.moderation.data)
  local groups = "groups"
  if not data[tostring(groups)][tostring(msg.to.id)] then
    return reply_msg(msg.id,'<b>SuperGroup is not added.</b>', ok_cb, false)
  end
  -- determine if table is empty
  if next(data[tostring(msg.to.id)]['moderators']) == nil then
    return reply_msg(msg.id,'<b>No moderator in this group.\nOrder By</b><b>|'..msg.from.print_name..'|</b>', ok_cb, false)
  end
  local i = 1
  local message = '<b>List of moderators for </b><b>' .. string.gsub(msg.to.print_name, '_', ' ') .. '</b>:\n'
  for k,v in pairs(data[tostring(msg.to.id)]['moderators']) do
    message = '<code>'..message ..i..'</code><b> - </b><code>'..v..'</code> <b>[' ..k.. ']</b> \n'
    i = i + 1
  end
  return reply_msg(msg.id, message, ok_cb, false)
end

-- Start by reply actions
function get_message_callback(extra, success, result)
	local get_cmd = extra.get_cmd
	local msg = extra.msg
	local data = load_data(_config.moderation.data)
	local print_name = user_print_name(msg.from):gsub("‮", "")
	local name_log = print_name:gsub("_", " ")
    if get_cmd == "id" and not result.action then
		local channel = 'channel#id'..result.to.peer_id
		savelog(msg.to.id, name_log.." ["..msg.from.id.."] obtained id for: ["..result.from.peer_id.."]")
		id1 = send_large_msg(channel, result.from.peer_id)
	elseif get_cmd == 'id' and result.action then
		local action = result.action.type
		if action == 'chat_add_user' or action == 'chat_del_user' or action == 'chat_rename' or action == 'chat_change_photo' then
			if result.action.user then
				user_id = result.action.user.peer_id
			else
				user_id = result.peer_id
			end
			local channel = 'channel#id'..result.to.peer_id
			savelog(msg.to.id, name_log.." ["..msg.from.id.."] obtained id by service msg for: ["..user_id.."]")
			id1 = send_large_msg(channel, user_id)
		end
    elseif get_cmd == "idfrom" then
		local channel = 'channel#id'..result.to.peer_id
		savelog(msg.to.id, name_log.." ["..msg.from.id.."] obtained id for msg fwd from: ["..result.fwd_from.peer_id.."]")
		id2 = send_large_msg(channel, result.fwd_from.peer_id)
    elseif get_cmd == 'channel_block' and not result.action then
		local member_id = result.from.peer_id
		local channel_id = result.to.peer_id
    if member_id == msg.from.id then
      return send_large_msg("channel#id"..channel_id, "Leave using kickme command")
    end
    if is_momod2(member_id, channel_id) and not is_admin2(msg.from.id) then
			   return send_large_msg("channel#id"..channel_id, "You can't kick mods/owner/admins")
    end
    if is_admin2(member_id) then
         return send_large_msg("channel#id"..channel_id, "You can't kick other admins")
    end
		--savelog(msg.to.id, name_log.." ["..msg.from.id.."] kicked: ["..user_id.."] by reply")
		kick_user(member_id, channel_id)
	elseif get_cmd == 'channel_block' and result.action and result.action.type == 'chat_add_user' then
		local user_id = result.action.user.peer_id
		local channel_id = result.to.peer_id
    if member_id == msg.from.id then
      return send_large_msg("channel#id"..channel_id, "Leave using kickme command")
    end
    if is_momod2(member_id, channel_id) and not is_admin2(msg.from.id) then
			   return send_large_msg("channel#id"..channel_id, "You can't kick mods/owner/admins")
    end
    if is_admin2(member_id) then
         return send_large_msg("channel#id"..channel_id, "You can't kick other admins")
    end
		savelog(msg.to.id, name_log.." ["..msg.from.id.."] kicked: ["..user_id.."] by reply to sev. msg.")
		kick_user(user_id, channel_id)
	elseif get_cmd == "del" then
		delete_msg(result.id, ok_cb, false)
		savelog(msg.to.id, name_log.." ["..msg.from.id.."] deleted a message by reply")
	elseif get_cmd == "setadmin" then
		local user_id = result.from.peer_id
		local channel_id = "channel#id"..result.to.peer_id
		channel_set_admin(channel_id, "user#id"..user_id, ok_cb, false)
		if result.from.username then
			text = '@'..result.from.username..'<b>set as an admin</b>'
		else
			text = '<b>[ </b><b>'..user_id..'</b><b> ]set as an admin</b>'
		end
		savelog(msg.to.id, name_log..' ['..msg.from.id..'] set: ['..user_id..'] as admin by reply')
		send_large_msg(channel_id, text)
	elseif get_cmd == "demoteadmin" then
		local user_id = result.from.peer_id
		local channel_id = "channel#id"..result.to.peer_id
		if is_admin2(result.from.peer_id) then
			return send_large_msg(channel_id, '<b>You can t demote global admins!</b>')
		end
		channel_demote(channel_id, "user#id"..user_id, ok_cb, false)
		if result.from.username then
			text = '@'..result.from.username..' <b>has been demoted from admin</b>'
		else
			text = '<b>[ </b><b>'..user_id..'</b><b>] has been demoted from admin</b>'
		end
		savelog(msg.to.id, name_log.." ["..msg.from.id.."] demoted: ["..user_id.."] from admin by reply")
		send_large_msg(channel_id, text)
	elseif get_cmd == "setowner" then
		local group_owner = data[tostring(result.to.peer_id)]['set_owner']
		if group_owner then
		local channel_id = 'channel#id'..result.to.peer_id
			if not is_admin2(tonumber(group_owner)) and not is_support(tonumber(group_owner)) then
				local user = "user#id"..group_owner
				channel_demote(channel_id, user, ok_cb, false)
			end
			local user_id = "user#id"..result.from.peer_id
			channel_set_admin(channel_id, user_id, ok_cb, false)
			data[tostring(result.to.peer_id)]['set_owner'] = tostring(result.from.peer_id)
			save_data(_config.moderation.data, data)
			savelog(msg.to.id, name_log.." ["..msg.from.id.."] set: ["..result.from.peer_id.."] as owner by reply")
			if result.from.username then
				text = "@"..result.from.username.." [ "..result.from.peer_id.." ] added as owner"
			else
				text = '<b>[<b> '..result.from.peer_id..' <b>] added as owner</b>'
			end
			send_large_msg(channel_id, text)
		end
	elseif get_cmd == "promote" then
		local receiver = result.to.peer_id
		local full_name = (result.from.first_name or '')..' '..(result.from.last_name or '')
		local member_name = full_name:gsub("‮", "")
		local member_username = member_name:gsub("_", " ")
		if result.from.username then
			member_username = '@'.. result.from.username
		end
		local member_id = result.from.peer_id
		if result.to.peer_type == 'channel' then
		savelog(msg.to.id, name_log.." ["..msg.from.id.."] promoted mod: @"..member_username.."["..result.from.peer_id.."] by reply")
		promote2("channel#id"..result.to.peer_id, member_username, member_id)
	    --channel_set_mod(channel_id, user, ok_cb, false)
		end
	elseif get_cmd == "demote" then
		local full_name = (result.from.first_name or '')..' '..(result.from.last_name or '')
		local member_name = full_name:gsub("‮", "")
		local member_username = member_name:gsub("_", " ")
    if result.from.username then
		member_username = '@'.. result.from.username
    end
		local member_id = result.from.peer_id
		--local user = "user#id"..result.peer_id
		savelog(msg.to.id, name_log.." ["..msg.from.id.."] demoted mod: @"..member_username.."["..user_id.."] by reply")
		demote2("channel#id"..result.to.peer_id, member_username, member_id)
		--channel_demote(channel_id, user, ok_cb, false)
	elseif get_cmd == 'mute_user' then
		if result.service then
			local action = result.action.type
			if action == 'chat_add_user' or action == 'chat_del_user' or action == 'chat_rename' or action == 'chat_change_photo' then
				if result.action.user then
					user_id = result.action.user.peer_id
				end
			end
			if action == 'chat_add_user_link' then
				if result.from then
					user_id = result.from.peer_id
				end
			end
		else
			user_id = result.from.peer_id
		end
		local receiver = extra.receiver
		local chat_id = msg.to.id
		print(user_id)
		print(chat_id)
		if is_muted_user(chat_id, user_id) then
			unmute_user(chat_id, user_id)
			send_large_msg(receiver, '<b>[</b>'..user_id..'<b>] removed from the muted user list</b>')
		elseif is_admin1(msg) then
			mute_user(chat_id, user_id)
			send_large_msg(receiver, ' <b>[<b>'..user_id..'<b>] added to the muted user list</b>')
		end
	end
end
-- End by reply actions

--By ID actions
local function cb_user_info(extra, success, result)
	local receiver = extra.receiver
	local user_id = result.peer_id
	local get_cmd = extra.get_cmd
	local data = load_data(_config.moderation.data)
	--[[if get_cmd == "setadmin" then
		local user_id = "user#id"..result.peer_id
		channel_set_admin(receiver, user_id, ok_cb, false)
		if result.username then
			text = "@"..result.username.." has been set as an admin"
		else
			text = "[ "..result.peer_id.." ] has been set as an admin"
		end
			send_large_msg(receiver, text)]]
	if get_cmd == "demoteadmin" then
		if is_admin2(result.peer_id) then
			return send_large_msg(receiver, "You can't demote global admins!")
		end
		local user_id = "user#id"..result.peer_id
		channel_demote(receiver, user_id, ok_cb, false)
		if result.username then
			text = "@"..result.username.." has been demoted from admin"
			send_large_msg(receiver, text)
		else
			text = "[ "..result.peer_id.." ] has been demoted from admin"
			send_large_msg(receiver, text)
		end
	elseif get_cmd == "promote" then
		if result.username then
			member_username = "@"..result.username
		else
			member_username = string.gsub(result.print_name, '_', ' ')
		end
		promote2(receiver, member_username, user_id)
	elseif get_cmd == "demote" then
		if result.username then
			member_username = "@"..result.username
		else
			member_username = string.gsub(result.print_name, '_', ' ')
		end
		demote2(receiver, member_username, user_id)
	end
end

-- Begin resolve username actions
local function callbackres(extra, success, result)
  local member_id = result.peer_id
  local member_username = "@"..result.username
  local get_cmd = extra.get_cmd
	if get_cmd == "res" then
		local user = result.peer_id
		local name = string.gsub(result.print_name, "_", " ")
		local channel = 'channel#id'..extra.channelid
		send_large_msg(channel, user..'\n'..name)
		return user
	elseif get_cmd == "id" then
		local user = result.peer_id
		local channel = 'channel#id'..extra.channelid
		send_large_msg(channel, user)
		return user
  elseif get_cmd == "invite" then
    local receiver = extra.channel
    local user_id = "user#id"..result.peer_id
    channel_invite(receiver, user_id, ok_cb, false)
	--[[elseif get_cmd == "channel_block" then
		local user_id = result.peer_id
		local channel_id = extra.channelid
    local sender = extra.sender
    if member_id == sender then
      return send_large_msg("channel#id"..channel_id, "Leave using kickme command")
    end
		if is_momod2(member_id, channel_id) and not is_admin2(sender) then
			   return send_large_msg("channel#id"..channel_id, "You can't kick mods/owner/admins")
    end
    if is_admin2(member_id) then
         return send_large_msg("channel#id"..channel_id, "You can't kick other admins")
    end
		kick_user(user_id, channel_id)
	elseif get_cmd == "setadmin" then
		local user_id = "user#id"..result.peer_id
		local channel_id = extra.channel
		channel_set_admin(channel_id, user_id, ok_cb, false)
		if result.username then
			text = "@"..result.username.." has been set as an admin"
			send_large_msg(channel_id, text)
		else
			text = "@"..result.peer_id.." has been set as an admin"
			send_large_msg(channel_id, text)
		end
	elseif get_cmd == "setowner" then
		local receiver = extra.channel
		local channel = string.gsub(receiver, 'channel#id', '')
		local from_id = extra.from_id
		local group_owner = data[tostring(channel)]['set_owner']
		if group_owner then
			local user = "user#id"..group_owner
			if not is_admin2(group_owner) and not is_support(group_owner) then
				channel_demote(receiver, user, ok_cb, false)
			end
			local user_id = "user#id"..result.peer_id
			channel_set_admin(receiver, user_id, ok_cb, false)
			data[tostring(channel)]['set_owner'] = tostring(result.peer_id)
			save_data(_config.moderation.data, data)
			savelog(channel, name_log.." ["..from_id.."] set ["..result.peer_id.."] as owner by username")
		if result.username then
			text = member_username.." [ "..result.peer_id.." ] added as owner"
		else
			text = "[ "..result.peer_id.." ] added as owner"
		end
		send_large_msg(receiver, text)
  end]]
	elseif get_cmd == "promote" then
		local receiver = extra.channel
		local user_id = result.peer_id
		--local user = "user#id"..result.peer_id
		promote2(receiver, member_username, user_id)
		--channel_set_mod(receiver, user, ok_cb, false)
	elseif get_cmd == "demote" then
		local receiver = extra.channel
		local user_id = result.peer_id
		local user = "user#id"..result.peer_id
		demote2(receiver, member_username, user_id)
	elseif get_cmd == "demoteadmin" then
		local user_id = "user#id"..result.peer_id
		local channel_id = extra.channel
		if is_admin2(result.peer_id) then
			return send_large_msg(channel_id, "You can't demote global admins!")
		end
		channel_demote(channel_id, user_id, ok_cb, false)
		if result.username then
			text = "@"..result.username.." has been demoted from admin"
			send_large_msg(channel_id, text)
		else
			text = "@"..result.peer_id.." has been demoted from admin"
			send_large_msg(channel_id, text)
		end
		local receiver = extra.channel
		local user_id = result.peer_id
		demote_admin(receiver, member_username, user_id)
	elseif get_cmd == 'mute_user' then
		local user_id = result.peer_id
		local receiver = extra.receiver
		local chat_id = string.gsub(receiver, 'channel#id', '')
		if is_muted_user(chat_id, user_id) then
			unmute_user(chat_id, user_id)
			send_large_msg(receiver, '<b> [</b>'..user_id..'<b>] removed from muted user list</b>')
		elseif is_owner(extra.msg) then
			mute_user(chat_id, user_id)
			send_large_msg(receiver, '<b> [</b>'..user_id..'<b>] added to muted user list</b>')
		end
	end
end
--End resolve username actions

--Begin non-channel_invite username actions
local function in_channel_cb(cb_extra, success, result)
  local get_cmd = cb_extra.get_cmd
  local receiver = cb_extra.receiver
  local msg = cb_extra.msg
  local data = load_data(_config.moderation.data)
  local print_name = user_print_name(cb_extra.msg.from):gsub("‮", "")
  local name_log = print_name:gsub("_", " ")
  local member = cb_extra.username
  local memberid = cb_extra.user_id
  if member then
    text = '<b>No user</b> @'..member..' <b>in this SuperGroup.</b>'
  else
    text = '<b>No user [</b>'..memberid..'<b>] in this SuperGroup.</b>'
  end
if get_cmd == "channel_block" then
  for k,v in pairs(result) do
    vusername = v.username
    vpeer_id = tostring(v.peer_id)
    if vusername == member or vpeer_id == memberid then
     local user_id = v.peer_id
     local channel_id = cb_extra.msg.to.id
     local sender = cb_extra.msg.from.id
      if user_id == sender then
        return send_large_msg("channel#id"..channel_id, "Leave using kickme command")
      end
      if is_momod2(user_id, channel_id) and not is_admin2(sender) then
        return send_large_msg("channel#id"..channel_id, "You can't kick mods/owner/admins")
      end
      if is_admin2(user_id) then
        return send_large_msg("channel#id"..channel_id, "You can't kick other admins")
      end
      if v.username then
        text = ""
        savelog(msg.to.id, name_log.." ["..msg.from.id.."] kicked: @"..v.username.." ["..v.peer_id.."]")
      else
        text = ""
        savelog(msg.to.id, name_log.." ["..msg.from.id.."] kicked: ["..v.peer_id.."]")
      end
      kick_user(user_id, channel_id)
      return
    end
  end
elseif get_cmd == "setadmin" then
   for k,v in pairs(result) do
    vusername = v.username
    vpeer_id = tostring(v.peer_id)
    if vusername == member or vpeer_id == memberid then
      local user_id = "user#id"..v.peer_id
      local channel_id = "channel#id"..cb_extra.msg.to.id
      channel_set_admin(channel_id, user_id, ok_cb, false)
      if v.username then
        text = "@"..v.username.." ["..v.peer_id.."] has been set as an admin"
        savelog(msg.to.id, name_log.." ["..msg.from.id.."] set admin @"..v.username.." ["..v.peer_id.."]")
      else
        text = "["..v.peer_id.."] has been set as an admin"
        savelog(msg.to.id, name_log.." ["..msg.from.id.."] set admin "..v.peer_id)
      end
	  if v.username then
		member_username = "@"..v.username
	  else
		member_username = string.gsub(v.print_name, '_', ' ')
	  end
		local receiver = channel_id
		local user_id = v.peer_id
		promote_admin(receiver, member_username, user_id)

    end
    send_large_msg(channel_id, text)
    return
 end
 elseif get_cmd == 'setowner' then
	for k,v in pairs(result) do
		vusername = v.username
		vpeer_id = tostring(v.peer_id)
		if vusername == member or vpeer_id == memberid then
			local channel = string.gsub(receiver, 'channel#id', '')
			local from_id = cb_extra.msg.from.id
			local group_owner = data[tostring(channel)]['set_owner']
			if group_owner then
				if not is_admin2(tonumber(group_owner)) and not is_support(tonumber(group_owner)) then
					local user = "user#id"..group_owner
					channel_demote(receiver, user, ok_cb, false)
				end
					local user_id = "user#id"..v.peer_id
					channel_set_admin(receiver, user_id, ok_cb, false)
					data[tostring(channel)]['set_owner'] = tostring(v.peer_id)
					save_data(_config.moderation.data, data)
					savelog(channel, name_log.."["..from_id.."] set ["..v.peer_id.."] as owner by username")
				if result.username then
					text = member_username.."<b> ["..v.peer_id.."] added as owner</b>"
				else
					text = "<b>["..v.peer_id.."] added as owner</b>"
				end
			end
		elseif memberid and vusername ~= member and vpeer_id ~= memberid then
			local channel = string.gsub(receiver, 'channel#id', '')
			local from_id = cb_extra.msg.from.id
			local group_owner = data[tostring(channel)]['set_owner']
			if group_owner then
				if not is_admin2(tonumber(group_owner)) and not is_support(tonumber(group_owner)) then
					local user = "user#id"..group_owner
					channel_demote(receiver, user, ok_cb, false)
				end
				data[tostring(channel)]['set_owner'] = tostring(memberid)
				save_data(_config.moderation.data, data)
				savelog(channel, name_log.."["..from_id.."] set ["..memberid.."] as owner by username")
				text = '<b>[</b>'..memberid..'<b>] added as owner</b>'
			end
		end
	end
 end
send_large_msg(receiver, text)
end
--End non-channel_invite username actions

--'Set supergroup photo' function
local function set_supergroup_photo(msg, success, result)
  local data = load_data(_config.moderation.data)
  if not data[tostring(msg.to.id)] then
      return
  end
  local receiver = get_receiver(msg)
  if success then
    local file = 'data/photos/channel_photo_'..msg.to.id..'.jpg'
    print('File downloaded to:', result)
    os.rename(result, file)
    print('File moved to:', file)
    channel_set_photo(receiver, file, ok_cb, false)
    data[tostring(msg.to.id)]['settings']['set_photo'] = file
    save_data(_config.moderation.data, data)
    send_large_msg(receiver, '<b>Photo saved!</b>', ok_cb, false)
  else
    print('Error downloading: '..msg.id)
    send_large_msg(receiver, '<b/>Failed, please try again!</b>', ok_cb, false)
  end
end

--Run function
local function run(msg, matches)
	if msg.to.type == 'chat' then
		if matches[1] == 'tosuper'or matches[1]=='سوپرگروه کن' then
			if not is_admin1(msg) then
				return
			end
			local receiver = get_receiver(msg)
			chat_upgrade(receiver, ok_cb, false)
		end
	elseif msg.to.type == 'channel'then
		if matches[1] == 'tosuper'or matches[1]=='سوپرگروه کن' then
			if not is_admin1(msg) then
				return
			end
			return "<b>Already a SuperGroup</b>"
		end
	end
	if msg.to.type == 'channel' then
	local support_id = msg.from.id
	local receiver = get_receiver(msg)
	local print_name = user_print_name(msg.from):gsub("‮", "")
	local name_log = print_name:gsub("_", " ")
	local data = load_data(_config.moderation.data)
		if matches[1] == 'add'or matches[1]=='نصب' and not matches[2] then
			if not is_admin1(msg) and not is_support(support_id) then
				return
			end
			if is_super_group(msg) then
				return reply_msg(msg.id, '<b>SuperGroup is already added.</b>', ok_cb, false)
			end
			print("SuperGroup "..msg.to.print_name.."("..msg.to.id..") added")
			savelog(msg.to.id, name_log.." ["..msg.from.id.."] added SuperGroup")
			superadd(msg)
			set_mutes(msg.to.id)
			channel_set_admin(receiver, 'user#id'..msg.from.id, ok_cb, false)
		end

		if matches[1] == 'rem' and is_admin1(msg) and not matches[2] or matches[1] == 'حذف' and is_admin1(msg) and not matches[2] then
			if not is_super_group(msg) then
				return reply_msg(msg.id, '<b>SuperGroup is not added.</b>', ok_cb, false)
			end
			print("SuperGroup "..msg.to.print_name.."("..msg.to.id..") removed")
			superrem(msg)
			rem_mutes(msg.to.id)
		end

		if not data[tostring(msg.to.id)] then
			return
		end
		if matches[1] == "info"or matches[1] == "اطلاعات" then
			if not is_owner(msg) then
				return
			end
			savelog(msg.to.id, name_log.." ["..msg.from.id.."] requested SuperGroup info")
			channel_info(receiver, callback_info, {receiver = receiver, msg = msg})
		end

		if matches[1] == "admins" or matches[1] == "ادمین ها" then
			if not is_owner(msg) and not is_support(msg.from.id) then
				return
			end
			member_type = 'Admins'
			savelog(msg.to.id, name_log.." ["..msg.from.id.."] requested SuperGroup Admins list")
			admins = channel_get_admins(receiver,callback, {receiver = receiver, msg = msg, member_type = member_type})
		end

		if matches[1] == "owner" or matches[1] == "صاحب گروه" then
			local group_owner = data[tostring(msg.to.id)]['set_owner']
			if not group_owner then
				return "<b>no owner,ask admins in support groups to set owner for your SuperGroup</b>"
			end
			savelog(msg.to.id, name_log.." ["..msg.from.id.."] used /owner")
			return "<b>SuperGroup owner is</b> <b>["..group_owner..']</b>'
		end

		if matches[1] == "modlist" or matches[1] == "لیست مدیران" then
			savelog(msg.to.id, name_log.." ["..msg.from.id.."] requested group modlist")
			return modlist(msg)
			-- channel_get_admins(receiver,callback, {receiver = receiver})
		end

		if matches[1] == "bots" and is_momod(msg) or matches[1]=="ربات ها" and is_momod(msg) then
			member_type = 'Bots'
			savelog(msg.to.id, name_log.." ["..msg.from.id.."] requested SuperGroup bots list")
			channel_get_bots(receiver, callback, {receiver = receiver, msg = msg, member_type = member_type})
		end

		if matches[1] == "who" and not matches[2] and is_momod(msg) or matches[1]=="چه کسانی" and not matches[2] and is_momod(msg) then
			local user_id = msg.from.peer_id
			savelog(msg.to.id, name_log.." ["..msg.from.id.."] requested SuperGroup users list")
			channel_get_users(receiver, callback_who, {receiver = receiver})
		end

		if matches[1] == "kicked"and is_momod(msg) or matches[1]=="حذف شده" and is_momod(msg) then
			savelog(msg.to.id, name_log.." ["..msg.from.id.."] requested Kicked users list")
			channel_get_kicked(receiver, callback_kicked, {receiver = receiver})
		end

		if matches[1] == 'del'and is_momod(msg) or matches[1]=='پاک' and is_momod(msg) then
			if type(msg.reply_id) ~= "nil" then
				local cbreply_extra = {
					get_cmd = 'del',
					msg = msg
				}
				delete_msg(msg.id, ok_cb, false)
				get_message(msg.reply_id, get_message_callback, cbreply_extra)
			end
		end

		if matches[1] == 'block'and is_momod(msg) or matches[1]=='بلاک' and is_momod(msg) then
			if type(msg.reply_id) ~= "nil" then
				local cbreply_extra = {
					get_cmd = 'channel_block',
					msg = msg
				}
				get_message(msg.reply_id, get_message_callback, cbreply_extra)
			elseif matches[1] == 'block' and matches[2] and string.match(matches[2], '^%d+$') then
				--[[local user_id = matches[2]
				local channel_id = msg.to.id
				if is_momod2(user_id, channel_id) and not is_admin2(user_id) then
					return send_large_msg(receiver, "You can't kick mods/owner/admins")
				end
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] kicked: [ user#id"..user_id.." ]")
				kick_user(user_id, channel_id)]]
				local get_cmd = 'channel_block'
				local msg = msg
				local user_id = matches[2]
				channel_get_users (receiver, in_channel_cb, {get_cmd=get_cmd, receiver=receiver, msg=msg, user_id=user_id})
			elseif matches[1] == "block" and matches[2] and not string.match(matches[2], '^%d+$') then
			--[[local cbres_extra = {
					channelid = msg.to.id,
					get_cmd = 'channel_block',
					sender = msg.from.id
				}
			    local username = matches[2]
				local username = string.gsub(matches[2], '@', '')
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] kicked: @"..username)
				resolve_username(username, callbackres, cbres_extra)]]
			local get_cmd = 'channel_block'
			local msg = msg
			local username = matches[2]
			local username = string.gsub(matches[2], '@', '')
			channel_get_users (receiver, in_channel_cb, {get_cmd=get_cmd, receiver=receiver, msg=msg, username=username})
			end
		end

		if matches[1] == 'id' or matches[1] =='ایدی'then
			if type(msg.reply_id) ~= "nil" and is_momod(msg) and not matches[2] then
				local cbreply_extra = {
					get_cmd = 'id',
					msg = msg
				}
				get_message(msg.reply_id, get_message_callback, cbreply_extra)
			elseif type(msg.reply_id) ~= "nil" and matches[2] == "from" and is_momod(msg) then
				local cbreply_extra = {
					get_cmd = 'idfrom',
					msg = msg
				}
				get_message(msg.reply_id, get_message_callback, cbreply_extra)
			elseif msg.text:match("@[%a%d]") then
				local cbres_extra = {
					channelid = msg.to.id,
					get_cmd = 'id'
				}
				local username = matches[2]
				local username = username:gsub("@","")
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] requested ID for: @"..username)
				resolve_username(username,  callbackres, cbres_extra)
			else
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] requested SuperGroup ID")
            return reply_msg(msg.id,'\n<b> ─═हईGroupNameईह═─</b> \n'..msg.to.title..'\n<b> ─═हईYourNameईह═─</b> \n '..(msg.from.first_name or '')..'\n<b> ─═हईYour Idईह═─</b> \n <b>'..msg.from.id..'</b>',ok_cb, false)
			end
		end

		if matches[1] == 'kickme'or matches[1]=='حذفم کن' then
			if msg.to.type == 'channel' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] left via kickme")
				channel_kick("channel#id"..msg.to.id, "user#id"..msg.from.id, ok_cb, false)
			end
		end

		if matches[1] == 'newlink'and is_momod(msg) or matches[1] =='لینک جدید' and is_momod(msg)then
			local function callback_link (extra , success, result)
			local receiver = get_receiver(msg)
				if success == 0 then
					send_large_msg(receiver, '<b>*Error: Failed to retrieve link* </b>\n<b>Reason: Not creator.</b>\n\n<b>If you have the link, please use /setlink to set it</b>')
					data[tostring(msg.to.id)]['settings']['set_link'] = nil
					save_data(_config.moderation.data, data)
				else
					send_large_msg(receiver, "<b>Created a new link</b>")
					data[tostring(msg.to.id)]['settings']['set_link'] = result
					save_data(_config.moderation.data, data)
				end
			end
			savelog(msg.to.id, name_log.." ["..msg.from.id.."] attempted to create a new SuperGroup link")
			export_channel_link(receiver, callback_link, false)
		end

		if matches[1] == 'setlink'and is_owner(msg) or matches[1] =='ست لینک' and is_owner(msg) then
			data[tostring(msg.to.id)]['settings']['set_link'] = 'waiting'
			save_data(_config.moderation.data, data)
			return reply_msg(msg.id, '<b>Please send the new group link now\nOrder By</b><b>|'..msg.from.id..'|</b>', ok_cb, false)
		end

		if msg.text then
			if msg.text:match("^(https://telegram.me/joinchat/%S+)$") and data[tostring(msg.to.id)]['settings']['set_link'] == 'waiting' and is_owner(msg) then
				data[tostring(msg.to.id)]['settings']['set_link'] = msg.text
				save_data(_config.moderation.data, data)
				return reply_msg(msg.id,"<b>New link set</b>", ok_cb, false)
			end
		end

		if matches[1] == 'link' or matches[1] =='لینک' then
			if not is_momod(msg) then
				return
			end
			local group_link = data[tostring(msg.to.id)]['settings']['set_link']
			if not group_link then
				return reply_msg(msg.id,"<b>Create a link using /newlink first!</b>\n\n<b>Or if I am not creator use /setlink to set your link</b>", ok_cb, false)
			end
			savelog(msg.to.id, name_log.." ["..msg.from.id.."] requested group link ["..group_link.."]")
            return reply_msg(msg.id,'🔘 برای ورود به گروه | '..msg.to.title..' | ازلینک زیر استفاده کنید🔘\n'..group_link..'', ok_cb, false)
		end

		if matches[1] == "invite" and is_sudo(msg) then
			local cbres_extra = {
				channel = get_receiver(msg),
				get_cmd = "invite"
			}
			local username = matches[2]
			local username = username:gsub("@","")
			savelog(msg.to.id, name_log.." ["..msg.from.id.."] invited @"..username)
			resolve_username(username,  callbackres, cbres_extra)
		end

		if matches[1] == 'res'and is_owner(msg) or matches[1]=='رس' and is_owner(msg) then
			local cbres_extra = {
				channelid = msg.to.id,
				get_cmd = 'res'
			}
			local username = matches[2]
			local username = username:gsub("@","")
			savelog(msg.to.id, name_log.." ["..msg.from.id.."] resolved username: @"..username)
			resolve_username(username,  callbackres, cbres_extra)
		end

		--[[if matches[1] == 'kick' and is_momod(msg) then
			local receiver = channel..matches[3]
			local user = "user#id"..matches[2]
			chaannel_kick(receiver, user, ok_cb, false)
		end]]

			if matches[1] == 'setadmin' then
				if not is_support(msg.from.id) and not is_owner(msg) then
					return
				end
			if type(msg.reply_id) ~= "nil" then
				local cbreply_extra = {
					get_cmd = 'setadmin',
					msg = msg
				}
				setadmin = get_message(msg.reply_id, get_message_callback, cbreply_extra)
			elseif matches[1] == 'setadmin' and matches[2] and string.match(matches[2], '^%d+$') then
			--[[]	local receiver = get_receiver(msg)
				local user_id = "user#id"..matches[2]
				local get_cmd = 'setadmin'
				user_info(user_id, cb_user_info, {receiver = receiver, get_cmd = get_cmd})]]
				local get_cmd = 'setadmin'
				local msg = msg
				local user_id = matches[2]
				channel_get_users (receiver, in_channel_cb, {get_cmd=get_cmd, receiver=receiver, msg=msg, user_id=user_id})
			elseif matches[1] == 'setadmin' and matches[2] and not string.match(matches[2], '^%d+$') then
				--[[local cbres_extra = {
					channel = get_receiver(msg),
					get_cmd = 'setadmin'
				}
				local username = matches[2]
				local username = string.gsub(matches[2], '@', '')
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] set admin @"..username)
				resolve_username(username, callbackres, cbres_extra)]]
				local get_cmd = 'setadmin'
				local msg = msg
				local username = matches[2]
				local username = string.gsub(matches[2], '@', '')
				channel_get_users (receiver, in_channel_cb, {get_cmd=get_cmd, receiver=receiver, msg=msg, username=username})
			end
		end

		if matches[1] == 'demoteadmin' then
			if not is_support(msg.from.id) and not is_owner(msg) then
				return
			end
			if type(msg.reply_id) ~= "nil" then
				local cbreply_extra = {
					get_cmd = 'demoteadmin',
					msg = msg
				}
				demoteadmin = get_message(msg.reply_id, get_message_callback, cbreply_extra)
			elseif matches[1] == 'demoteadmin' and matches[2] and string.match(matches[2], '^%d+$') then
				local receiver = get_receiver(msg)
				local user_id = "user#id"..matches[2]
				local get_cmd = 'demoteadmin'
				user_info(user_id, cb_user_info, {receiver = receiver, get_cmd = get_cmd})
			elseif matches[1] == 'demoteadmin' and matches[2] and not string.match(matches[2], '^%d+$') then
				local cbres_extra = {
					channel = get_receiver(msg),
					get_cmd = 'demoteadmin'
				}
				local username = matches[2]
				local username = string.gsub(matches[2], '@', '')
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] demoted admin @"..username)
				resolve_username(username, callbackres, cbres_extra)
			end
		end

		if matches[1] == 'setowner'and is_owner(msg) or matches[1]=='اونرکن' and is_owner(msg) then
			if type(msg.reply_id) ~= "nil" then
				local cbreply_extra = {
					get_cmd = 'setowner',
					msg = msg
				}
				setowner = get_message(msg.reply_id, get_message_callback, cbreply_extra)
			elseif matches[1] == 'setowner' and matches[2] and string.match(matches[2], '^%d+$') then
		--[[	local group_owner = data[tostring(msg.to.id)]['set_owner']
				if group_owner then
					local receiver = get_receiver(msg)
					local user_id = "user#id"..group_owner
					if not is_admin2(group_owner) and not is_support(group_owner) then
						channel_demote(receiver, user_id, ok_cb, false)
					end
					local user = "user#id"..matches[2]
					channel_set_admin(receiver, user, ok_cb, false)
					data[tostring(msg.to.id)]['set_owner'] = tostring(matches[2])
					save_data(_config.moderation.data, data)
					savelog(msg.to.id, name_log.." ["..msg.from.id.."] set ["..matches[2].."] as owner")
					local text = "[ "..matches[2].." ] added as owner"
					return text
				end]]
				local	get_cmd = 'setowner'
				local	msg = msg
				local user_id = matches[2]
				channel_get_users (receiver, in_channel_cb, {get_cmd=get_cmd, receiver=receiver, msg=msg, user_id=user_id})
			elseif matches[1] == 'setowner' and matches[2] and not string.match(matches[2], '^%d+$') or matches[1]=='اونرکن' and matches[2] and not string.match(matches[2], '^%d+$') then
				local	get_cmd = 'setowner'
				local	msg = msg
				local username = matches[2]
				local username = string.gsub(matches[2], '@', '')
				channel_get_users (receiver, in_channel_cb, {get_cmd=get_cmd, receiver=receiver, msg=msg, username=username})
			end
		end

		if matches[1] == 'promote' or matches[1] == 'کمک مدیر'  then
		  if not is_momod(msg) then
				return
			end
			if not is_owner(msg) then
				return "<b>Only owner/admin can promote</b>"
			end
			if type(msg.reply_id) ~= "nil" then
				local cbreply_extra = {
					get_cmd = 'promote',
					msg = msg
				}
				promote = get_message(msg.reply_id, get_message_callback, cbreply_extra)
			elseif matches[1] == 'promote' and matches[2] and string.match(matches[2], '^%d+$') or matches[1] == 'کمک مدیر' and matches[2] and string.match(matches[2], '^%d+$') then
				local receiver = get_receiver(msg)
				local user_id = "user#id"..matches[2]
				local get_cmd = 'promote'
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] promoted user#id"..matches[2])
				user_info(user_id, cb_user_info, {receiver = receiver, get_cmd = get_cmd})
			elseif matches[1] == 'promote' and matches[2] and not string.match(matches[2], '^%d+$') or matches[1] == 'کمک مدیر' and matches[2] and not string.match(matches[2], '^%d+$') then
				local cbres_extra = {
					channel = get_receiver(msg),
					get_cmd = 'promote',
				}
				local username = matches[2]
				local username = string.gsub(matches[2], '@', '')
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] promoted @"..username)
				return resolve_username(username, callbackres, cbres_extra)
			end
		end

		if matches[1] == 'mp' and is_sudo(msg) then
			channel = get_receiver(msg)
			user_id = 'user#id'..matches[2]
			channel_set_mod(channel, user_id, ok_cb, false)
			return "ok"
		end
		if matches[1] == 'md' and is_sudo(msg) then
			channel = get_receiver(msg)
			user_id = 'user#id'..matches[2]
			channel_demote(channel, user_id, ok_cb, false)
			return "ok"
		end

		if matches[1] == 'demote' or matches[1] == 'حذف کمک مدیر' then
			if not is_momod(msg) then
				return
			end
			if not is_owner(msg) then
				return "<b>Only owner/support/admin can promote</b>"
			end
			if type(msg.reply_id) ~= "nil" then
				local cbreply_extra = {
					get_cmd = 'demote',
					msg = msg
				}
				demote = get_message(msg.reply_id, get_message_callback, cbreply_extra)
			elseif matches[1] == 'demote' and matches[2] and string.match(matches[2], '^%d+$') or matches[1]=='حذف کمک مدیر' and matches[2] and string.match(matches[2], '^%d+$') then
				local receiver = get_receiver(msg)
				local user_id = "user#id"..matches[2]
				local get_cmd = 'demote'
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] demoted user#id"..matches[2])
				user_info(user_id, cb_user_info, {receiver = receiver, get_cmd = get_cmd})
			elseif matches[1] == 'demote'and matches[2] and not string.match(matches[2], '^%d+$') or matches[1]=='حذف کمک مدیر' and matches[2] and not string.match(matches[2], '^%d+$') then
				local cbres_extra = {
					channel = get_receiver(msg),
					get_cmd = 'demote'
				}
				local username = matches[2]
				local username = string.gsub(matches[2], '@', '')
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] demoted @"..username)
				return resolve_username(username, callbackres, cbres_extra)
			end
		end

		if matches[1] == "setname"and is_momod(msg) or matches[1]=="نام گروه" and is_momod(msg) then
			local receiver = get_receiver(msg)
			local set_name = string.gsub(matches[2], '_', '')
			savelog(msg.to.id, name_log.." ["..msg.from.id.."] renamed SuperGroup to: "..matches[2])
			rename_channel(receiver, set_name, ok_cb, false)
		end

		if msg.service and msg.action.type == 'chat_rename' then
			savelog(msg.to.id, name_log.." ["..msg.from.id.."] renamed SuperGroup to: "..msg.to.title)
			data[tostring(msg.to.id)]['settings']['set_name'] = msg.to.title
			save_data(_config.moderation.data, data)
		end

		if matches[1] == "setabout"and is_momod(msg) or matches[1]=="درباره گروه" and is_momod(msg) then
			local receiver = get_receiver(msg)
			local about_text = matches[2]
			local data_cat = 'description'
			local target = msg.to.id
			data[tostring(target)][data_cat] = about_text
			save_data(_config.moderation.data, data)
			savelog(msg.to.id, name_log.." ["..msg.from.id.."] set SuperGroup description to: "..about_text)
			channel_set_about(receiver, about_text, ok_cb, false)
			return reply_msg(msg.id,'<b>Description has been set.</b>\n<b>Select the chat again to see the changes.\nOrder By</b><b>|'..msg.from.id..'|</b>',ok_cb, false)
		end

		if matches[1] == "setusername" and is_admin1(msg) then
			local function ok_username_cb (extra, success, result)
				local receiver = extra.receiver
				if success == 1 then
					send_large_msg(receiver, "<b>SuperGroup username Set.</b>\n\n<b>Select the chat again to see the changes.</b>")
				elseif success == 0 then
					send_large_msg(receiver, "<b>Failed to set SuperGroup username.</b>\n<b>Username may already be taken.\n\nNote: Username can use a-z, 0-9 and underscores.\nMinimum length is 5 characters.</b>")
				end
			end
			local username = string.gsub(matches[2], '@', '')
			channel_set_username(receiver, username, ok_username_cb, {receiver=receiver})
		end

		if matches[1] == 'setrules' and is_momod(msg) or matches[1]=='تنظیم قانون' and is_momod(msg) then
			rules = matches[2]
			local target = msg.to.id
			savelog(msg.to.id, name_log.." ["..msg.from.id.."] has changed group rules to ["..matches[2].."]")
			return set_rulesmod(msg, data, target)
		end

		if msg.media then
			if msg.media.type == 'photo' and data[tostring(msg.to.id)]['settings']['set_photo'] == 'waiting' and is_momod(msg) then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] set new SuperGroup photo")
				load_photo(msg.id, set_supergroup_photo, msg)
				return
			end
		end
		if matches[1] == 'setphoto' and is_momod(msg) or matches[1]=='تنظیم عکس' and is_momod(msg) then
			data[tostring(msg.to.id)]['settings']['set_photo'] = 'waiting'
			save_data(_config.moderation.data, data)
			savelog(msg.to.id, name_log.." ["..msg.from.id.."] started setting new SuperGroup photo")
			return reply_msg(msg.id,'<b>Please send the new group photo now\nOrder By</b><b>|'..msg.from.id..'|</b>', ok_cb, false)
		end
		if matches[1] == 'clean'or matches[1]=='پاک کردن' then
			if not is_momod(msg) then
				return
			end
			if not is_momod(msg) then
				return reply_msg(msg.id,'<b>Only owner can clean</b>', ok_cb, false)
			end
			if matches[2] == 'modlist'or matches[2]=='لیست مدیران' then
				if next(data[tostring(msg.to.id)]['moderators']) == nil then
					return reply_msg(msg.id,'<b>No moderator(s) in this SuperGroup.\nOrder By</b><b>|'..msg.from.id..'|</b>', ok_cb, false)
				end
				for k,v in pairs(data[tostring(msg.to.id)]['moderators']) do
					data[tostring(msg.to.id)]['moderators'][tostring(k)] = nil
					save_data(_config.moderation.data, data)
				end
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] cleaned modlist")
				return reply_msg(msg.id,'<b>Modlist has been cleaned\nOrder By</b><b>|'..msg.from.id..'|</b>', ok_cb, false)
			end
			if matches[2] == 'rules'or matches[2]=='قوانین' then
				local data_cat = 'rules'
				if data[tostring(msg.to.id)][data_cat] == nil then
					return reply_msg(msg.id,'<b>Rules have not been set\nOrder By</b><b>|'..msg.from.id..'|</b>', ok_cb, false)
				end
				data[tostring(msg.to.id)][data_cat] = nil
				save_data(_config.moderation.data, data)
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] cleaned rules")
				return reply_msg(msg.id,'<b>Rules have been cleaned\nOrder By</b><b>|'..msg.from.id..'|</b>', ok_cb, false)
			end
			if matches[2] == 'about'or matches[2]=='درباره گروه' then
				local receiver = get_receiver(msg)
				local about_text = ' '
				local data_cat = 'description'
				if data[tostring(msg.to.id)][data_cat] == nil then
					return reply_msg(msg.id,'<b>About is not set\nOrder By</b><b>|'..msg.from.id..'|</b>', ok_cb, false)
				end
				data[tostring(msg.to.id)][data_cat] = nil
				save_data(_config.moderation.data, data)
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] cleaned about")
				channel_set_about(receiver, about_text, ok_cb, false)
				return reply_msg(msg.id,"<b>About has been cleaned\nOrder By</b><b>|'..msg.from.id..'|</b>", ok_cb, false)
			end
			if matches[2] == 'mutelist'or matches[2]=='لیست موت' then
				chat_id = msg.to.id
				local hash =  'mute_user:'..chat_id
					redis:del(hash)
				return reply_msg(msg.id,'<b>Mutelist Cleaned\nOrder By</b><b>|'..msg.from.id..'|</b>', ok_cb, false)
			end
			if matches[2] == 'username' and is_admin1(msg) then
				local function ok_username_cb (extra, success, result)
					local receiver = extra.receiver
					if success == 1 then
						send_large_msg(receiver, "SuperGroup username cleaned.")
					elseif success == 0 then
						send_large_msg(receiver, "Failed to clean SuperGroup username.")
					end
				end
				local username = ""
				channel_set_username(receiver, username, ok_username_cb, {receiver=receiver})
			end
			if matches[2] == "bots" and is_momod(msg) then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] kicked all SuperGroup bots")
				channel_get_bots(receiver, callback_clean_bots, {msg = msg})
			end
		end

		if matches[1] == 'lock' and is_momod(msg) or matches[1] =='قفل' and is_momod(msg) then
			local target = msg.to.id
			if matches[2] == 'links'or matches[2] == 'لینک' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] locked link posting ")
				return lock_group_links(msg, data, target)
			end
   	      if matches[2] == 'emoji' or matches[2] == 'امجو' then
            savelog(msg.to.id, name_log.." ["..msg.from.id.."] locked emoji posting ")
              return lock_group_emoji(msg, data, target)
           end
		   if matches[2] == 'cmd' or matches[2] == 'دستور' then
            savelog(msg.to.id, name_log.." ["..msg.from.id.."] locked cmd posting ")
              return lock_group_cmd(msg, data, target)
		   end
			if matches[2] == 'spam' or matches[2] == 'اسپم' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] locked spam ")
				return lock_group_spam(msg, data, target)
			end
			if matches[2] == 'media' or matches[2] == 'مدیا' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] locked media")
				return lock_group_media(msg, data, target)
			end
			if matches[2] == 'number' or matches[2] == 'عدد' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] locked Number ")
				return lock_group_number(msg, data, target)
			end
			if matches[2] == 'flood' or matches[2] == 'فلود' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] locked flood ")
				return lock_group_flood(msg, data, target)
			end
			if matches[2] == 'arabic' or matches[2] == 'عربی' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] locked arabic ")
				return lock_group_arabic(msg, data, target)
			end
			if matches[2] == 'member'or matches[2] == 'ممبر' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] locked member ")
				return lock_group_membermod(msg, data, target)
			end
			if matches[2] == 'forward'or matches[2] == 'فوروارد' then
                 savelog(msg.to.id, name_log.." ["..msg.from.id.."] locked fwd ")
                 return lock_group_fwd(msg, data, target)
			end
			if matches[2]:lower() == 'rtl'or matches[2] == 'ارتی ال' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] locked rtl chars. in names")
				return lock_group_rtl(msg, data, target)
			end
			if matches[2] == 'tgservice'or matches[2] == 'ورود خروج' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] locked Tgservice Actions")
				return lock_group_tgservice(msg, data, target)
			end
			if matches[2] == 'bots'or matches[2] == 'ربات' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] locked bots")
				return lock_group_bots(msg, data, target)
			end
			if matches[2] == 'sticker'or matches[2] == 'استیکر' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] locked sticker posting")
				return lock_group_sticker(msg, data, target)
			end
			if matches[2] == 'tag'or matches[2] == 'تگ' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] locked tag ")
				return lock_group_tag(msg, data, target)
			end		
			if matches[2] == 'fosh'or matches[2] == 'فحش' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] locked fosh ")
				return lock_group_fosh(msg, data, target)
			end	
			if matches[2] == 'inline'or matches[2] == 'اینلاین' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] locked inline ")
				return lock_group_inline(msg, data, target)
			end	
			if matches[2] == 'join'or matches[2] == 'جوین' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] locked join ")
				return lock_group_join(msg, data, target)
			end	
			if matches[2] == 'username'or matches[2] == 'یوزرنیم' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] locked username ")
				return lock_group_username(msg, data, target)
			end			
			if matches[2] == 'english'or matches[2] == 'انگلیسی' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] locked english ")
				return lock_group_english(msg, data, target)
			end			
			if matches[2] == 'contacts'or matches[2] == 'کانتکت' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] locked contact posting")
				return lock_group_contacts(msg, data, target)
			end
			if matches[2] == 'strict'or matches[2] == 'سختگیرانه' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] locked enabled strict settings")
				return enable_strict_rules(msg, data, target)
			end
		end

		if matches[1] == 'unlock'and is_momod(msg) or matches[1] == 'بازکردن' and is_momod(msg) then
			local target = msg.to.id
			if matches[2] == 'links'or matches[2] == 'لینک' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] unlocked link posting")
				return unlock_group_links(msg, data, target)
			end
			if matches[2] == 'spam' or matches[2] == 'اسپم' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] unlocked spam")
				return unlock_group_spam(msg, data, target)
			end
			if matches[2] == 'cmd' or matches[2] == 'دستور' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] unlocked cmd")
				return unlock_group_cmd(msg, data, target)
			end
			if matches[2] == 'media' or matches[2] == 'مدیا' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] unlocked media")
				return unlock_group_media(msg, data, target)
			end
			if matches[2] == 'join' or matches[2] == 'جوین' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] unlocked join")
				return unlock_group_join(msg, data, target)
			end
			if matches[2] == 'flood'or matches[2] == 'فلود' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] unlocked flood")
				return unlock_group_flood(msg, data, target)
			end
			if matches[2] == 'fosh'or matches[2] == 'فحش' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] unlocked flood")
				return unlock_group_fosh(msg, data, target)
			end
			if matches[2] == 'emoji' or matches[2] == 'امجو' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] unlocked emoji posting")
				return unlock_group_emoji(msg, data, target)
			end
				if matches[2] == 'number' or matches[2] == 'عدد' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] unlocked number posting")
				return unlock_group_number(msg, data, target)
			end
			if matches[2] == 'arabic' or matches[2] == 'عربی' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] unlocked Arabic")
				return unlock_group_arabic(msg, data, target)
			end
			if matches[2] == 'bots'or matches[2] == 'ربات' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] unlocked bots")
				return unlock_group_bots(msg, data, target)
			end
			if matches[2] == 'forward'or matches[2] == 'فوروارد' then
                 savelog(msg.to.id, name_log.." ["..msg.from.id.."] unlocked fwd ")
                 return unlock_group_fwd(msg, data, target)
			end
			if matches[2] == 'member'or matches[2] == 'ممبر' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] unlocked member ")
				return unlock_group_membermod(msg, data, target)
			end
			if matches[2] == 'tag'or matches[2] == 'تگ' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] unlocked tag ")
				return unlock_group_tag(msg, data, target)
			end		
			if matches[2] == 'inline'or matches[2] == 'اینلاین' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] unlocked inline ")
				return unlock_group_inline(msg, data, target)
			end		
			if matches[2] == 'username'or matches[2] == 'یوزرنیم' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] unlocked username ")
				return unlock_group_username(msg, data, target)
			end			
			if matches[2] == 'english'or matches[2] == 'انگلیسی' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] unlocked tag ")
				return unlock_group_english(msg, data, target)
			end			
			if matches[2]:lower() == 'rtl'or matches[2] == 'ارتی ال' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] unlocked RTL chars. in names")
				return unlock_group_rtl(msg, data, target)
			end
				if matches[2] == 'tgservice'or matches[2] == 'ورود خروج' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] unlocked tgservice actions")
				return unlock_group_tgservice(msg, data, target)
			end
			if matches[2] == 'sticker'or matches[2] == 'استیکر' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] unlocked sticker posting")
				return unlock_group_sticker(msg, data, target)
			end
			if matches[2] == 'contacts'or matches[2] == 'کانتکت' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] unlocked contact posting")
				return unlock_group_contacts(msg, data, target)
			end
			if matches[2] == 'strict'or matches[2] == 'سختگیرانه' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] locked disabled strict settings")
				return disable_strict_rules(msg, data, target)
			end
		end

		if matches[1] == 'setflood'or matches[1] =='فلود' then
			if not is_momod(msg) then
				return
			end
			if tonumber(matches[2]) < 2 or tonumber(matches[2]) > 200 then
				return reply_msg(msg.id,'<b>Wrong number,range is [-200]</b>',ok_cb, false)
			end
			local flood_max = matches[2]
			data[tostring(msg.to.id)]['settings']['flood_msg_max'] = flood_max
			save_data(_config.moderation.data, data)
			savelog(msg.to.id, name_log.." ["..msg.from.id.."] set flood to ["..matches[2].."]")
			return reply_msg(msg.id,'<b>Flood has been set to</b>:<b> '..matches[2]..'</b>', ok_cb, false)
		end
		if matches[1] == 'public'and is_momod(msg) or matches[1] =='عمومی' and is_momod(msg) then
			local target = msg.to.id
			if matches[2] == 'yes' or matches[2] =='بله' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] set group to: public")
				return set_public_membermod(msg, data, target)
			end
			if matches[2] == 'no'  or matches[2] =='نه'then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] set SuperGroup to: not public")
				return unset_public_membermod(msg, data, target)
			end
		end

		if matches[1] == 'mute' and is_owner(msg) or matches[1] =='موت' and is_owner(msg) then
			local chat_id = msg.to.id
			if matches[2] == 'audio'  or matches[2] =='ویس'then
			local msg_type = 'Audio'
				if not is_muted(chat_id, msg_type..': yes') then
					savelog(msg.to.id, name_log.." ["..msg.from.id.."] set SuperGroup to: mute "..msg_type)
					mute(chat_id, msg_type)
					return reply_msg(msg.id,'<b>'..msg_type..'</b><b> 》has been muted</b>', ok_cb, false)
				else
					return reply_msg(msg.id,'<b>SuperGroup mute</b><b>'..msg_type..' </b><b>》is already on</b>', ok_cb, false)
				end
			end
			if matches[2] == 'photo' or matches[2] =='عکس' then
			local msg_type = 'Photo'
				if not is_muted(chat_id, msg_type..': yes') then
					savelog(msg.to.id, name_log.." ["..msg.from.id.."] set SuperGroup to: mute "..msg_type)
					mute(chat_id, msg_type)
					return reply_msg(msg.id,'<b>'.. msg_type..'</b><b> 》has been muted\nOrder By</b><b>|'..msg.from.id..'|</b>', ok_cb, false)
				else
					return reply_msg(msg.id,'<b>SuperGroup mute </b><b>'..msg_type..'</b><b> 》is already on\nOrder By</b><b>|'..msg.from.id..'|<b/>', ok_cb, false)
				end
			end
			if matches[2] == 'video' or matches[2] =='فیلم' then
			local msg_type = 'Video'
				if not is_muted(chat_id, msg_type..': yes') then
					savelog(msg.to.id, name_log.." ["..msg.from.id.."] set SuperGroup to: mute "..msg_type)
					mute(chat_id, msg_type)
					return reply_msg(msg.id, '<b>'..msg_type..'</b><b> 》has been muted\nOrder By</b><b>|'..msg.from.id..'|</b>', ok_cb, false)
				else
					return reply_msg(msg.id,'<b>SuperGroup mute </b><b>'..msg_type..' </b><b>》is already on\nOrder By</b><b>|'..msg.from.id..'|</b>', ok_cb, false)
				end
			end
			if matches[2] == 'gifs' or matches[2] =='گیف' then
			local msg_type = 'Gifs'
				if not is_muted(chat_id, msg_type..': yes') then
					savelog(msg.to.id, name_log.." ["..msg.from.id.."] set SuperGroup to: mute "..msg_type)
					mute(chat_id, msg_type)
					return reply_msg(msg.id, '<b>'..msg_type..'</b><b> 》have been muted\nOrder By</b><b>|'..msg.from.id..'|</b>', ok_cb, false)
				else
					return reply_msg(msg.id, '<b>SuperGroup mute </b><b>'..msg_type..' </b><b>》is already on\nOrder By</b><b>|'..msg.from.id..'|</b>', ok_cb, false)
				end
			end
			if matches[2] == 'documents' or matches[2] =='فایل' then
			local msg_type = 'Documents'
				if not is_muted(chat_id, msg_type..': yes') then
					savelog(msg.to.id, name_log.." ["..msg.from.id.."] set SuperGroup to: mute "..msg_type)
					mute(chat_id, msg_type)
					return reply_msg(msg.id,'<b>'..msg_type..' </b><b>》have been muted\nOrder By</b><b>|'..msg.from.id..'|</b>', ok_cb, false)
				else
					return reply_msg(msg.id,'<b>SuperGroup mute </b><b>'..msg_type..' 》is already on\nOrder By</b><b>|'..msg.from.id..'|</b>', ok_cb, false)
				end
			end
			if matches[2] == 'text' or matches[2] =='متن' then
			local msg_type = 'Text'
				if not is_muted(chat_id, msg_type..': yes') then
					savelog(msg.to.id, name_log.." ["..msg.from.id.."] set SuperGroup to: mute "..msg_type)
					mute(chat_id, msg_type)
					return reply_msg(msg.id,'<b>'..msg_type..' </b><b>》has been muted</b>\nOrder By</b><b>|'..msg.from.id..'|', ok_cb, false)
				else
					return reply_msg(msg.id,'<b>Mute</b> <b>'..msg_type..'</b><b> 》is already on\nOrder By</b><b>|'..msg.from.id..'|</b>', ok_cb, false)
				end
			end
			if matches[2] == 'all'  or matches[2] =='همه' then
			local msg_type = 'All'
				if not is_muted(chat_id, msg_type..': yes') then
					savelog(msg.to.id, name_log.." ["..msg.from.id.."] set SuperGroup to: mute "..msg_type)
					mute(chat_id, msg_type)
					return reply_msg(msg.id,'<b>Mute</b><b>'..msg_type..'</b> <b>》has been enabled\nOrder By</b><b>|'..msg.from.id..'|</b>', ok_cb, false)
				else
					return reply_msg(msg.id,'<b>Mute</b> <b>'..msg_type..'</b><b> 》is already on\nOrder By</b><b>|'..msg.from.id..'|</b>', ok_cb, false)
				end
			end
		end
		if matches[1] == 'unmute' and is_momod(msg) or matches[1] =='آنموت' and is_momod(msg) then
			local chat_id = msg.to.id
			if matches[2] == 'audio' or matches[2] =='ویس' then
			local msg_type = 'Audio'
				if is_muted(chat_id, msg_type..': yes') then
					savelog(msg.to.id, name_log.." ["..msg.from.id.."] set SuperGroup to: unmute "..msg_type)
					unmute(chat_id, msg_type)
					return reply_msg(msg.id,'<b>'..msg_type..'</b><b> 》has been unmuted\nOrder By</b><b>|'..msg.from.id..'|</b>',ok_cb, false)
				else
					return reply_msg(msg.id,'<b>Mute</b> <b>'..msg_type..'</b> <b>》is already off\nOrder By</b><b>|'..msg.from.id..'|</b>',ok_cb, false)
				end
			end
			if matches[2] == 'photo' or matches[2] =='عکس' then
			local msg_type = 'Photo'
				if is_muted(chat_id, msg_type..': yes') then
					savelog(msg.to.id, name_log.." ["..msg.from.id.."] set SuperGroup to: unmute "..msg_type)
					unmute(chat_id, msg_type)
					return reply_msg(msg.id,'<b>'..msg_type..'</b> <b>》has been unmuted\nOrder By</b><b>|'..msg.from.id..'|<b>',ok_cb, false)
				else
					return reply_msg(msg.id,'<b>Mute </b><b>'..msg_type..' </b><b>》is already off\nOrder By</b><b>|'..msg.from.id..'|</b>',ok_cb, false)
				end
			end
			if matches[2] == 'video' or matches[2] =='فیلم' then
			local msg_type = 'Video'
				if is_muted(chat_id, msg_type..': yes') then
					savelog(msg.to.id, name_log.." ["..msg.from.id.."] set SuperGroup to: unmute "..msg_type)
					unmute(chat_id, msg_type)
					return reply_msg(msg.id,'<b>'..msg_type..'</b> <b>》has been unmuted\nOrder By</b><b>|'..msg.from.id..'|</b>',ok_cb, false)
				else
					return reply_msg(msg.id,'<b>Mute </b><b>'..msg_type..'</b><b> 》is already off\nOrder By</b><b>|'..msg.from.id..'|</b>',ok_cb, false)
				end
			end
			if matches[2] == 'gifs' or matches[2] =='گیف' then
			local msg_type = 'Gifs'
				if is_muted(chat_id, msg_type..': yes') then
					savelog(msg.to.id, name_log.." ["..msg.from.id.."] set SuperGroup to: unmute "..msg_type)
					unmute(chat_id, msg_type)
					return reply_msg(msg.id,'<b>'..msg_type..'</b><b> 》have been unmuted\nOrder By</b><b>|'..msg.from.id..'|</b>',ok_cb, false)
				else
					return reply_msg(msg.id,'<b>Mute </b><b>'..msg_type..' </b><b>》is already off\nOrder By</b><b>|'..msg.from.id..'|</b>',ok_cb, false)
				end
			end
			if matches[2] == 'documents' or matches[2] =='فایل' then
			local msg_type = 'Documents'
				if is_muted(chat_id, msg_type..': yes') then
					savelog(msg.to.id, name_log.." ["..msg.from.id.."] set SuperGroup to: unmute "..msg_type)
					unmute(chat_id, msg_type)
					return reply_msg(msg.id,'<b>'..msg_type..'</b> <b>》have been unmuted\nOrder By</b><b>|'..msg.from.id..'|</b>',ok_cb, false)
				else
					return reply_msg(msg.id,'<b>Mute</b><b>' ..msg_type..'</b><b> 》is already off\nOrder By</b><b>|'..msg.from.id..'|</b>',ok_cb, false)
				end
			end
			if matches[2] == 'text' or matches[2] =='متن' then
			local msg_type = 'Text'
				if is_muted(chat_id, msg_type..': yes') then
					savelog(msg.to.id, name_log.." ["..msg.from.id.."] set SuperGroup to: unmute message")
					unmute(chat_id, msg_type)
					return reply_msg(msg.id,'<b>'..msg_type..'</b><b> 》has been unmuted\nOrder By</b><b>|'..msg.from.id..'|</b>',ok_cb, false)
				else
					return reply_msg(msg.id,'<b>Mute </b><b>'..msg_type..' </b><b>》is already off\nOrder By</b><b>|'..msg.from.id..'|</b>',ok_cb, false)
				end
			end
			if matches[2] == 'all'  or matches[2] =='همه'then
			local msg_type = 'All'
				if is_muted(chat_id, msg_type..': yes') then
					savelog(msg.to.id, name_log.." ["..msg.from.id.."] set SuperGroup to: unmute "..msg_type)
					unmute(chat_id, msg_type)
					return reply_msg(msg.id,'<b>Mute</b><b>'..msg_type..'</b><b>》has been disabled\nOrder By</b><b>|'..msg.from.id..'|</b>',ok_cb, false)
				else
					return reply_msg(msg.id,'<b>Mute</b><b>'..msg_type..'</b><b> 》is already disabled\nOrder By</b><b>|'..msg.from.id..'|</b>',ok_cb, false)
				end
			end
		end


		if matches[1] == "muteuser"and is_momod(msg) or matches[1]=="سایلنت" and is_momod(msg) then
			local chat_id = msg.to.id
			local hash = "mute_user"..chat_id
			local user_id = ""
			if type(msg.reply_id) ~= "nil" then
				local receiver = get_receiver(msg)
				local get_cmd = "mute_user"
				muteuser = get_message(msg.reply_id, get_message_callback, {receiver = receiver, get_cmd = get_cmd, msg = msg})
			elseif matches[1] == "muteuser"and matches[2] and string.match(matches[2], '^%d+$') or matches[1]=="سایلنت" and matches[2] and string.match(matches[2], '^%d+$') then
				local user_id = matches[2]
				if is_muted_user(chat_id, user_id) then
					unmute_user(chat_id, user_id)
					savelog(msg.to.id, name_log.." ["..msg.from.id.."] removed ["..user_id.."] from the muted users list")
					return "["..user_id.."] removed from the muted users list"
				elseif is_owner(msg) then
					mute_user(chat_id, user_id)
					savelog(msg.to.id, name_log.." ["..msg.from.id.."] added ["..user_id.."] to the muted users list")
					return "["..user_id.."] added to the muted user list"
				end
			elseif matches[1] == "muteuser" and matches[2] and not string.match(matches[2], '^%d+$')  or matches[1]=="سایلنت" and matches[2] and not string.match(matches[2], '^%d+$') then
				local receiver = get_receiver(msg)
				local get_cmd = "mute_user"
				local username = matches[2]
				local username = string.gsub(matches[2], '@', '')
				resolve_username(username, callbackres, {receiver = receiver, get_cmd = get_cmd, msg=msg})
			end
		end

		if matches[1] == "muteslist"and is_momod(msg) or matches[1]=="لیست موت" and is_momod(msg) then
			local chat_id = msg.to.id
			if not has_mutes(chat_id) then
				set_mutes(chat_id)
				return mutes_list(chat_id)
			end
			savelog(msg.to.id, name_log.." ["..msg.from.id.."] requested SuperGroup muteslist")
			return mutes_list(chat_id)
		end
		if matches[1] == "mutelist"or matches[1]=="لیست سایلنت" and is_momod(msg) then
			local chat_id = msg.to.id
			savelog(msg.to.id, name_log.." ["..msg.from.id.."] requested SuperGroup mutelist")
			return muted_user_list(chat_id)
		end

		if matches[1] == 'settings'and is_momod(msg)  or matches[1] =='تنظیمات' and is_momod(msg) then
			local target = msg.to.id
			savelog(msg.to.id, name_log.." ["..msg.from.id.."] requested SuperGroup settings ")
			return show_supergroup_settingsmod(msg, target)
		end

		if matches[1] == 'rules' or matches[1] =='قوانین' then
			savelog(msg.to.id, name_log.." ["..msg.from.id.."] requested group rules")
			return get_rules(msg, data)
		end

		if matches[1] == 'help' and not is_owner(msg) then
			text = ""
			reply_msg(msg.id, text, ok_cb, false)
		elseif matches[1] == 'help' and is_owner(msg) then
			local name_log = user_print_name(msg.from)
			savelog(msg.to.id, name_log.." ["..msg.from.id.."] Used /superhelp")
			return super_help()
		end

		if matches[1] == 'peer_id' and is_admin1(msg)then
			text = msg.to.peer_id
			reply_msg(msg.id, text, ok_cb, false)
			post_large_msg(receiver, text)
		end

		if matches[1] == 'msg.to.id' and is_admin1(msg) then
			text = msg.to.id
			reply_msg(msg.id, text, ok_cb, false)
			post_large_msg(receiver, text)
		end

		--Admin Join Service Message
		if msg.service then
		local action = msg.action.type
			if action == 'chat_add_user_link' then
				if is_owner2(msg.from.id) then
					local receiver = get_receiver(msg)
					local user = "user#id"..msg.from.id
					savelog(msg.to.id, name_log.." Admin ["..msg.from.id.."] joined the SuperGroup via link")
					channel_set_admin(receiver, user, ok_cb, false)
				end
				if is_support(msg.from.id) and not is_owner2(msg.from.id) then
					local receiver = get_receiver(msg)
					local user = "user#id"..msg.from.id
					savelog(msg.to.id, name_log.." Support member ["..msg.from.id.."] joined the SuperGroup")
					channel_set_mod(receiver, user, ok_cb, false)
				end
			end
			if action == 'chat_add_user' then
				if is_owner2(msg.action.user.id) then
					local receiver = get_receiver(msg)
					local user = "user#id"..msg.action.user.id
					savelog(msg.to.id, name_log.." Admin ["..msg.action.user.id.."] added to the SuperGroup by [ "..msg.from.id.." ]")
					channel_set_admin(receiver, user, ok_cb, false)
				end
				if is_support(msg.action.user.id) and not is_owner2(msg.action.user.id) then
					local receiver = get_receiver(msg)
					local user = "user#id"..msg.action.user.id
					savelog(msg.to.id, name_log.." Support member ["..msg.action.user.id.."] added to the SuperGroup by [ "..msg.from.id.." ]")
					channel_set_mod(receiver, user, ok_cb, false)
				end
			end
		end
		if matches[1] == 'msg.to.peer_id' then
			post_large_msg(receiver, msg.to.peer_id)
		end
	end
end

local function pre_process(msg)
  if not msg.text and msg.media then
    msg.text = '['..msg.media.type..']'
  end
  return msg
end

return {
  patterns = {
	"^[#!/]([Aa]dd)$",
	"^(نصب)$",
	"^[#!/]([Rr]em)$",
	"^(حذف)$",
	"^[#!/]([Mm]ove) (.*)$",
	"^[#!/]([Ii]nfo)$",
	"^(اطلاعات)$",
	"^[#!/]([Aa]dmins)$",
	"^(ادمین ها)$",
	"^[#!/]([Oo]wner)$",
	"^(صاحب گروه)$",
	"^[#!/]([Mm]odlist)$",
	"^(لیست مدیران)$",
	"^[#!/]([Bb]ots)$",
	"^(ربات ها)$",
	"^(چه کسانی)$",
	"^[#!/]([Ww]ho)$",
	"^[#!/]([Kk]icked)$",
	"^(حذف شده)$",
    "^[#!/]([Bb]lock) (.*)",
	"^[#!/]([Bb]lock)",
	"^[#!/]([Tt]osuper)$",
	"^(سوپرگروه کن)$",
	"^[#!/]([Ii][Dd])$",
	"^(ایدی)$",
	"^[#!/]([Ii][Dd]) (.*)$",
	"^[#!/]([Kk]ickme)$",
	"^(حذفم کن)$",
	"^[#!/]([Kk]ick) (.*)$",
	"^[#!/]([Nn]ewlink)$",
	"^(لینک جدید)$",
	"^[#!/]([Ss]etlink)$",
	"^(ست لینک)$",
	"^[#!/]([Ll]ink)$",
	"^(لینک)$",
	"^[#!/]([Rr]es) (.*)$",
	"^(رس) (.*)$",
	"^[#!/]([Ss]etadmin) (.*)$",
	"^[#!/]([Ss]etadmin)",
	"^[#!/]([Dd]emoteadmin) (.*)$",
	"^[#!/]([Dd]emoteadmin)",
	"^[#!/]([Ss]etowner) (.*)$",
	"^(اونرکن) (.*)$",
	"^[#!/]([Ss]etowner)$",
	"^(اونرکن)$",
	"^[#!/]([Pp]romote) (.*)$",
	"^(کمک مدیر) (.*)$",
	"^[#!/]([Pp]romote)",
	"^(کمک مدیر)",
	"^[#!/]([Dd]emote) (.*)$",
	"^(حذف کمک مدیر) (.*)$",
	"^[#!/]([Dd]emote)$",
	"^(حذف کمک مدیر)",
	"^[#!/]([Ss]etname) (.*)$",
	"^(نام گروه) (.*)$",
	"^[#!/]([Ss]etabout) (.*)$",
	"^(درباره گروه) (.*)$",
	"^[#!/]([Ss]etrules) (.*)$",
	"^(تنظیم قانون) (.*)$",
	"^[#!/]([Ss]etphoto)$",
	"^(تنظیم عکس)$",
	"^[#!/]([Ss]etusername) (.*)$",
	"^[#!/]([Dd]el)$",
	"^(پاک)$",
	"^[#!/]([Ll]ock) (.*)$",
	"^(قفل) (.*)$",
	"^[#!/]([Uu]nlock) (.*)$",
	"^(بازکردن) (.*)$",
	"^[#!/]([Mm]ute) ([^%s]+)$",
	"^(موت) ([^%s]+)$",
	"^[#!/]([Uu]nmute) ([^%s]+)$",
	"^(آنموت) ([^%s]+)$",
	"^[#!/]([Mm]uteuser)$",
	"^(سایلنت)$",
	"^[#!/]([Mm]uteuser) (.*)$",
    "^(سایلنت) (.*)$",
	"^[#!/]([Pp]ublic) (.*)$",
	"^(عمومی) (.*)$",
	"^[#!/]([Ss]ettings)$",
	"^(تنظیمات)$",
	"^[#!/]([Rr]ules)$",
	"^(قوانین)$",
	"^[#!/]([Ss]etflood) (%d+)$",
	"^(فلود) (%d+)$",
	"^[#!/]([Cc]lean) (.*)$",
	"^(پاک کردن) (.*)$",
	--"^[#!/]([Hh]elp)$",
	"^[#!/]([Mm]uteslist)$",
	"^(لیست موت)$",
	"^[#!/]([Mm]utelist)$",
    "^(لیست سایلنت)$",
	"[#!/](mp) (.*)",
	"[#!/](md) (.*)",
    "^(https://telegram.me/joinchat/%S+)$",
	--"msg.to.peer_id",
	"%[(document)%]",
	"%[(photo)%]",
	"%[(video)%]",
	"%[(audio)%]",
	"%[(contact)%]",
	"^!!tgservice (.+)$",
  },
  run = run,
  pre_process = pre_process
}
--End supergrpup.lua
--By @Tele_sudo
