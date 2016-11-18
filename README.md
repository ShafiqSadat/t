# [TeleRedStar](https://telegram.me/Tele_sudo)



#ربات ضد اسپم رد استار


قابلیت منحصر به فرد سورس

1-اتولانچ

2-دستورات هم فارسی هم انگلیسی

3-دارای گرافیک زیبا

شما میتوانید به خواسته خود از دستورات فارسی یا دستورات انگلیسی ربات استفاده نمایید.
# اموزش نصب
***
چون سورس بر پایه اچ تی ام ال میباشد و به صورت بولد و ایتالیک است باید تی جی چنج شود
***

#نحوه نصب

```sh

اول نصب پیش نیاز
sudo apt-get update
sudo apt-get install libreadline-dev libconfig-dev libssl-dev lua5.2 liblua5.2-dev lua-socket lua-sec lua-expat libevent-dev make unzip git redis-server autoconf g++ libjansson-dev libpython-dev expat libexpat1-dev

دوم کلون کردن بر روی سرور خود
git clone https://github.com/TeleSudo/TeleRedStar.git
سوم کد زیر را میزنیم
cd TeleRedStar
چهارم برای دسترسی داشتن به فایل لانچر دستور زیر رامیزنیم
chmod +x launch.sh
پنجم دستور زیر را برای نصب ربات میزنیم
./launch.sh install
و اخر دستور زیر را زده و اجرا میگیریم و شماره تلفن را داده وبات اماده است
./launch.sh 

```



#نکته این سورس بر پایه بولد و ایتالیک نوشته شده

لطفا فایل [lua_tg.c](https://telegram.me/tg_github/5)
را دانلود و بر پوشه tg بریزید

# بعد دستور
cd TeleBot

cd tg

make

cd ../..

را بزنید و تمام حال ربات اماده است که به صورت بلد کارکند.

#نویسنده سورس

# [Abolfazl] (https://telegram.me/Tele_sudo)
#حل مشکلات
[اینجا کلیک کنید](https://telegram.me/Tele_sudo)


#دستورات اتولانچ 

```sh

cd TeleRedStar
killall screen
killall tmux
killall telegram-cli
tmux new-session -s script "bash steady.sh -t"

```
