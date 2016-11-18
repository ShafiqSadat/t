do

local function run(msg, matches)
  if matches[1]:lower() == "مقام من" then
    if is_sudo(msg) then
    send_document(get_receiver(msg), "/root/TeleSeed/axs/sudo.webp", ok_cb, false)
      return "😎شما صاحب ربات هستید😎"
	  elseif is_admin1 (msg) then
	  send_document(get_receiver(msg), "/root/TeleSeed/axs/admin.webp", ok_cb, false)
      return "😃شما ادمین ربات هستید😃"
    elseif is_owner(msg) then
    send_document(get_receiver(msg), "/root/TeleSeed/axs/owner.webp", ok_cb, false)
      return "👻شما صاحب گروه هستید👻"
    elseif is_momod(msg) then
    send_document(get_receiver(msg), "/root/TeleSeed/axs/mod.webp", ok_cb, false)
      return "😝شما مدیر گروه هستید😝"
    else
      --send_document(get_receiver(msg), "/root/TeleSeed/axs/member.webp", ok_cb, false)
      return "😶شما کاربر عادی هستید😶"
  end
end
end

return {
  patterns = {
    "^(مقام من)$",
    },
  run = run
}
end




--  -_-_-_-_-_-_-_-_-_-   ||-_-_-_-_-_   ||             ||-_-_-_-_-_
--           ||           ||             ||             ||
--           ||           ||             ||             ||
--           ||           ||             ||             ||
--           ||           ||-_-_-_-_-_   ||             ||-_-_-_-_-_
--           ||           ||             ||             ||
--           ||           ||             ||             ||
--           ||           ||             ||             ||
--           ||           ||-_-_-_-_-_   ||-_-_-_-_-_   ||-_-_-_-_-_
--
--
--                               /\                              /\             /-_-_-_-_-_    ||-_-_-_-_-_   ||-_-_-_-_-_
--  ||\\            //||        //\\        ||      //||        //\\           //              ||             ||         //
--  || \\          // ||       //  \\       ||     // ||       //  \\         //               ||             ||       //
--  ||  \\        //  ||      //    \\      ||    //  ||      //    \\       ||                ||             ||    //
--  ||   \\      //   ||     //______\\     ||   //   ||     //______\\      ||      -_-_-_-   ||-_-_-_-_-_   || //
--  ||    \\    //    ||    //        \\    ||  //    ||    //        \\     ||           ||   ||             ||  \\ 
--  ||     \\  //     ||   //          \\   || //     ||   //          \\     \\          ||   ||             ||     \\
--  ||      \\//      ||  //            \\  ||//      ||  //            \\     \\-_-_-_-_-||   ||-_-_-_-_-_   ||        \\
--
--
--  ||-_-_-_-    ||           ||           ||               //-_-_-_-_-_-
--  ||     ||    ||           ||           ||              //
--  ||_-_-_||    ||           ||           ||             //
--  ||           ||           ||           ||             \\
--  ||           ||           \\           //              \\
--  ||           ||            \\         //               //
--  ||           ||-_-_-_-_     \\-_-_-_-//    -_-_-_-_-_-//
--