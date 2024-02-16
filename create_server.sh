# Copyright received! БЕЗ ВЕДОМА НЕ ПЕРЕДАВАТЬ! ЗАБАНЮ!
# Скрипт исполняем только от root пользователя или пользователя имеющего доступ к группе sudoers

rm -rf /etc/nginx/sites-available/
rm -rf /etc/nginx/sites-enabled
mkdir /etc/nginx/sites-available
mkdir /etc/nginx/sites-enabled

#-------------------------------------------------------------------------------------------------------------#
# Обновляемся
apt update -y
apt upgrade -y
#-------------------------------------------------------------------------------------------------------------#
# Ставим пакет nginx
apt install nginx -y
#-------------------------------------------------------------------------------------------------------------#
# Отключаем ufw
ufw disable
#-------------------------------------------------------------------------------------------------------------#
# Создаём логи
touch /opt/users.log
#-------------------------------------------------------------------------------------------------------------#
# Создаем 100 пользователей
for i in $(seq -w 1 100); do
	useradd -m profi$i
	echo "Пользователь profi$i создан успешно"
done
#-------------------------------------------------------------------------------------------------------------#
# Присваиваем всем пользователям рандомный пароль длиной 20 символов
# Генерируем рандомный пароль из символов A-Z, a-z, 0-9
random_password() {
	< /dev/urandom tr -dc A-Za-z0-9 | head -c 20
}
# Меняем пароль для каждого пользователя на сгенерированный
for i in $(seq -w 1 100); do
	password=$(random_password)
	echo profi$i:$password | chpasswd
	echo "Пароль для пользователя profi$i изменен успешно на $password" >> users.log
done
#-------------------------------------------------------------------------------------------------------------#
# По умолчанию в Nginx уже создан первый виртуальный хост в директории /var/www/html.
# Мы не будем изменять его, а создадим для наших сайтов новые виртуальные хосты.
# Чтобы у нас было больше гибкости в управлении сайтами, создадим их в отдельных директориях:
for i in $(seq -w 1 100); do
	mkdir -p /var/www/profi$i/html
done
#-------------------------------------------------------------------------------------------------------------#
# Создаём 100 index.html в наших папочках /var/www/profi$i/html
for i in $(seq -w 1 100); do
        touch /var/www/profi$i/html/index.html
done
#-------------------------------------------------------------------------------------------------------------#
# Для теста хостов рассылаем простую вёрстку на все index.html
for i in $(seq -w 1 100); do
	cat /opt/test.txt > /var/www/profi$i/html/index.html
done
#-------------------------------------------------------------------------------------------------------------#
# Создаём новый файл
touch=/etc/nginx/sites-available/profi.com
# Вписывыем из template.txt в наш новый файл
cat template.txt > /etc/nginx/sites-available/profi.com
# Создаём 100 файликов profi$i.com
for i in $(seq -w 1 100); do
	touch /etc/nginx/sites-available/profi$ip.profi.com
done
# Копируем темплейт в наши файлики 
for i in $(seq -w 1 100); do
	cat  /etc/nginx/sites-available/profi.com > /etc/nginx/sites-available/profi$i.profi.com
done
# Меняем темплейт через цикл на нужные нам слова
for i in $(seq -w 1 100); do
	sed -i s/profi.com/profi$i.profi.com/g /etc/nginx/sites-available/profi$i.profi.com
done
#-------------------------------------------------------------------------------------------------------------#
# Создаём символические ссылки
for i in $(seq -w 1 100); do
	ln -s /etc/nginx/sites-available/profi$i.profi.com /etc/nginx/sites-enabled/
done
#-------------------------------------------------------------------------------------------------------------#
# Назначаем всем нашим пользователям доступ на папочки /var/www/profi$i
for i in $(seq -w 1 100); do
# Получаем имя пользователя и папки
        user=profi$i
        folder=/var/www/$user/html
# Проверяем, существует ли папка
if [ -d $folder ]; then
# Назначаем пользователю полные права на папку
        chown $user:$user $folder
        chmod 755 $folder
fi
done
#-------------------------------------------------------------------------------------------------------------#
