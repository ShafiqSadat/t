local function run(msg, matches, callback, extra)

local data = load_data(_config.moderation.data)

local group_type = data[tostring(msg.to.id)]['group_type']

if matches[1] and is_sudo(msg) then
    
data[tostring(msg.to.id)]['group_type'] = matches[1]
        save_data(_config.moderation.data, data)
        
        return '<b>Group Type Seted To :</b> <code>'..matches[1]..'</code>'

end
if not is_owner(msg) then 
    return '<b>You Are Not Allow To set Group Type !</b>'
    end
end
return {
  patterns = {
  "^[#!/]type (.*)$",
  },
  run = run
}

