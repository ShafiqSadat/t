do
 function run(msg, matches)
return [[
<code>راهنمای دستورات ربات</code>


| !/#  |  <b>lock</b> | <b>contacts-links-flood-spam-arabic-member-rtl-sticker-tag-username-bots-english-forward-inline-number-cmds</b>
<code>بستن امکانات بالا</code>
➖➖➖➖➖➖
| !/#  |  <b>unlock</b> | <b>contacts-links-flood-spam-arabic-member-rtl-sticker-tag-username-bots-english-forward-inline-number-cmds</b>
<code>بازکردن امکانات بالا</code>
➖➖➖➖➖➖
| !/#  |  <b>mute</b> | <b>gifs-audio-photo-video-text-documents-all</b>
<code>موت کردن امکانات بالا</code>
➖➖➖➖➖➖
| !/#  |  <b>unmute</b> | <b>gifs-audio-photo-video-text-documents-all</b>
<code>آنموت کردن امکانات بالا</code>
➖➖➖➖➖➖
| !/#  |  <b>promote @username</b> 
<code>کمک مدیر کردن یک شخص</code>
➖➖➖➖➖➖
| !/#  |  <b>demote @username</b>
<code>خارج کردن شخص ازکمک مدیریت</code>
➖➖➖➖➖➖
| !/#  |  <b>modlist</b>
<code>نمایش کمک مدیران</code>
➖➖➖➖➖➖
| !/#  |  <b>ban @username </b>
<code>اخراج کردن یک فرد از گروه به صورت دائمی</code>
➖➖➖➖➖➖
| !/#  |  <b>unban @username</b>
<code>خارج کردن یک فرد از حالت اخراج دائمی</code>
➖➖➖➖➖➖
| !/#  |  <b>info</b>
<code>نمایش اطلاعات اصلی گروه</code>
➖➖➖➖➖➖
| !/#  |  <b>del [reply|number]</b>
<code>پاک کردن تعداد پیام های مورد نظر با ریپلی و تعداد</code>
➖➖➖➖➖➖
| !/#  |  <b>admins</b>
<code>نمایش لیست ادمین های گروه</code>
➖➖➖➖➖➖
| !/#  |  <b>filter [word]</b>
<code>فیلتر کردن یک کلمه</code>
➖➖➖➖➖➖
| !/#  |  <b>unfilter [word]</b>
<code>در اوردن کلمه از فیلتر</code>
➖➖➖➖➖➖
| !/#  |  <b>filterlist</b>
<code>نشان دادن کلمه های فیلتر شده.</code>
➖➖➖➖➖➖
| !/#  |  <b>owner</b>
<code>نمایش آیدی خریدار گروه</code>
➖➖➖➖➖➖
| !/#  |  <b>kick [reply|id]</b>
<code>بلاک کردن و کیک کردن فرد از گروه.</code>
➖➖➖➖➖➖
| !/#  |  <b>setwlc[Text]</b>
<code>تنظیم یک متن به عنوان متن خوشامد گویی</code>
➖➖➖➖➖➖
| !/#  |  <b>delwlc</b>
<code>حذف پیام خوشامد گویی</code>
➖➖➖➖➖➖
| !/#  |  <b>id</b>
<code>نمایش اطلاعات اکانت شما .</code>
➖➖➖➖➖➖
| !/#  |  <b>setname [text]</b>
<code>تغییر اسم گروه</code>
➖➖➖➖➖➖
| !/#  |  <b>setphoto</b>
<code>جایگزین کردن عکس گروه</code>
➖➖➖➖➖➖
| !/#  |  <b>setrules [text]</b>
<code>گذاشتن قوانین برای گروه</code>
➖➖➖➖➖➖
| !/#  |  <b>setabout [text]</b>
<code>گذاشتن متن توضیحات برای سوپر گروه(این متن در بخش توضیحات گروه هم نمایش داده میشه)</code>
➖➖➖➖➖➖
| !/#  |  <b>newlink</b>
<code>ساختن لینک جدید</code>
➖➖➖➖➖➖
| !/#  |  <b>link</b>
<code>گرفتن لینک</code>
➖➖➖➖➖➖
| !/#  |  <b>rules</b>
<code>نمایش قوانین</code>
➖➖➖➖➖➖
| !/#  |  <b>setflood [value]</b>
<code>گذاشتن value به عنوان حساسیت اسپم</code>
➖➖➖➖➖➖
| !/#  |  <b>settings</b>
<code>نمایش تنظیمات گروه</code>
➖➖➖➖➖➖
| !/#  |  <b>muteslist</b>
<code>نمایش لیست افراد سایلنت شده</code>
➖➖➖➖➖➖
| !/#  |  <b>clean [rules|about|modlist|mutelist|bots]</b>
<code>پاک کردن لیست ناظم ها-درباره-لیست سایلنت شده ها-قوانین-بات ها</code>
➖➖➖➖➖➖
]]
end
return {
patterns = {
"^[!/#][Hh]elp$",
"^[Hh]elp$",
"^❓$"
},
run = run
}
end