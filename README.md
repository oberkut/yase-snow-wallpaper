# YaSE (Yet another Snow Effect)

**YaSE** — обои для KDE Plasma 6 с эффектом 3D-снегопада.

![YaSE Preview](preview.png)

---

## Системные требования
Для работы эффекта необходимы библиотеки **Qt6 Quick3D**.

Для **openSUSE (Tumbleweed/Leap)**:
```bash
sudo zypper install qt6-quick3d
```
## Установка
### Способ 1: Автоматический (Рекомендуется)

Скачайте Install.sh. Откройте терминал и выполните:
```bash
chmod +x Install.sh
./Install.sh
```
### Способ 2: Установка пакета .plasmoid

```Bash
kpackagetool6 -t Plasma/Wallpaper -i org.kde.yase.plasmoid
```
### Способ 3: Установка из исходного кода

```Bash
wget [https://github.com/oberkut/yase-snow-wallpaper/archive/refs/heads/main.zip](https://github.com/oberkut/yase-snow-wallpaper/archive/refs/heads/main.zip)
unzip ./main.zip
mkdir -p ~/.local/share/plasma/wallpapers/
cp -r ./yase-snow-wallpaper-main/src/org.kde.yase ~/.local/share/plasma/wallpapers/
```

## Активация
Нажмите правой кнопкой на рабочем столе -> Настроить рабочий стол и обои...

В выпадающем списке выберите YaSE (Yet another Snow Effect).

