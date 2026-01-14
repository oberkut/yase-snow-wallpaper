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

---
Автор: Alexander Novichkov (aka BerkuT)

Лицензия: GPL-3.0

Платформа: KDE Plasma 6 (Qt6)

---


# YaSE (Yet another Snow Effect)

**YaSE** — Live wallpaper for KDE Plasma 6 featuring a 3D snowfall effect.

![YaSE Preview](preview.png)

---

## System Requirements
The **Qt6 Quick3D** libraries are required for this effect to work.

For **openSUSE (Tumbleweed/Leap)**:
```bash
sudo zypper install qt6-quick3d
```
## Installation
### Method 1: Automatic (Recommended)

Download Install.sh. Open your terminal and run:

```bash
chmod +x Install.sh
./Install.sh
```

### Method 2: Installing the .plasmoid package

```bash
kpackagetool6 -t Plasma/Wallpaper -i org.kde.yase.plasmoid
````

### Method 3: Manual Installation (from source)

```Bash
wget [https://github.com/oberkut/yase-snow-wallpaper/archive/refs/heads/main.zip](https://github.com/oberkut/yase-snow-wallpaper/archive/refs/heads/main.zip)
unzip ./main.zip
mkdir -p ~/.local/share/plasma/wallpapers/
cp -r ./yase-snow-wallpaper-main/src/org.kde.yase ~/.local/share/plasma/wallpapers/
```

### Activation
Right-click on your desktop -> Configure Desktop and Wallpaper...

Select YaSE (Yet another Snow Effect) from the "Wallpaper Type" dropdown menu.

---
Author: Alexander Novichkov (aka BerkuT)

License: GPL-3.0

Platform: KDE Plasma 6 (Qt6)

