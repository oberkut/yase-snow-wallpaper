import QtQuick
import QtQuick.Controls
import QtQuick.Dialogs
import QtQuick.Layouts
import org.kde.kirigami as Kirigami

Kirigami.FormLayout {
    id: root

    // --- Связывание настроек (Aliases) ---
    // Имена свойств должны начинаться с 'cfg_' + имя параметра из main.xml
    // Использование alias позволяет KDE автоматически отслеживать изменения.
    
    property alias cfg_FillMode: fillModeCombo.currentIndex
    property alias cfg_Snowflake: snowflakeRepeater.selectedTexture
    property alias cfg_Particles: particlesSpin.value
    property alias cfg_Size: sizeSpin.value
    property alias cfg_Velocity: velocityCombo.currentIndex
    
    // Для цвета нужен особый подход, alias на colorDialog или rectangle не всегда работает гладко,
    // но alias на свойство color Rectangle - рабочий вариант, если обновлять его.
    // Однако надежнее использовать явное свойство и обновлять его, KDE это тоже понимает, 
    // если имя совпадает. Для текста/строк лучше использовать property string.
    
    property alias cfg_SnowColor: colorRect.color
    property alias cfg_Opacity: opacitySpin.value
    property alias cfg_Rotation: rotationSpin.value
    property alias cfg_RandomRot: randomRotCheck.checked
    property alias cfg_DepthEffect: depthCheck.checked
    property alias cfg_Wind: windSpin.value
    property alias cfg_Gusts: gustsSpin.value
    
    // Для картинки используем строку, так как FileDialog возвращает URL, а нам нужен путь
    property string cfg_Image

    // Вспомогательная функция для перевода
    function t(ru, en) { return (Qt.locale().name.substring(0,2) === "ru") ? ru : en; }
    
    // Функция для предпросмотра картинки
    function previewPath(p) {
        if (!p || p === "") return "";
        let s = p.toString();
        if (s.indexOf("/") === 0) return "file://" + s;
        return s;
    }

    // --- Интерфейс ---

    Kirigami.Separator { Kirigami.FormData.label: t("Фон рабочего стола", "Desktop Background") }
    
    // Выбор изображения
    Item {
        Kirigami.FormData.label: t("Изображение:", "Image:")
        implicitWidth: 200; implicitHeight: 112
        Rectangle {
            anchors.fill: parent; color: "transparent"
            border.color: Kirigami.Theme.textColor; border.width: 1; radius: 4; clip: true
            
            Image { 
                anchors.fill: parent; anchors.margins: 1
                source: previewPath(cfg_Image)
                fillMode: Image.PreserveAspectCrop; visible: source != "" 
            }
            Kirigami.Icon { 
                anchors.centerIn: parent; source: "document-open-symbolic"
                width: 32; height: 32; opacity: 0.5; visible: cfg_Image === "" 
            }
            Text { 
                anchors.bottom: parent.bottom; anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottomMargin: 8
                text: t("Нажмите для выбора фона", "Click to choose background")
                font.pixelSize: 9; color: Kirigami.Theme.textColor; opacity: 0.6
                visible: cfg_Image === "" 
            }
            MouseArea { 
                anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                onClicked: bgFileDialog.open() 
            }
        }
    }

    ComboBox {
        id: fillModeCombo
        Kirigami.FormData.label: t("Размещение:", "Placement:")
        model: [t("Заполнить экран (Crop)", "Fill Screen (Crop)"), t("Вписать (Fit)", "Fit"), t("Растянуть (Stretch)", "Stretch")]
    }

    Kirigami.Separator { Kirigami.FormData.label: t("Внешний вид снега", "Snow Appearance") }

    // Выбор текстуры снежинки
    RowLayout {
        Kirigami.FormData.label: t("Текстура:", "Texture:")
        spacing: 10
        
        // Кастомное свойство для хранения выбранной текстуры, чтобы alias работал
        property string selectedTexture: "data/snowflake1.png"
        id: snowflakeRepeater
        
        // При изменении cfg_Snowflake извне (при загрузке), обновляем локальное свойство
        Component.onCompleted: {
            if (cfg_Snowflake && cfg_Snowflake !== "") selectedTexture = cfg_Snowflake
        }
        // При изменении локального, обновляется alias cfg_Snowflake
        onSelectedTextureChanged: cfg_Snowflake = selectedTexture

        Repeater {
            model: ["data/snowflake1.png", "data/snowflake2.png", "data/snowflake3.png"]
            Button {
                implicitWidth: 54; implicitHeight: 54
                onClicked: snowflakeRepeater.selectedTexture = modelData
                background: Rectangle { 
                    color: snowflakeRepeater.selectedTexture === modelData ? Kirigami.Theme.highlightColor : "transparent"
                    border.color: Kirigami.Theme.textColor
                    radius: 6
                    opacity: snowflakeRepeater.selectedTexture === modelData ? 1 : 0.4
                    border.width: snowflakeRepeater.selectedTexture === modelData ? 2 : 1 
                }
                contentItem: Image { source: modelData; fillMode: Image.PreserveAspectFit; anchors.margins: 4 }
            }
        }
        // Кнопка MIX
        Button {
            implicitWidth: 54; implicitHeight: 54
            onClicked: snowflakeRepeater.selectedTexture = "mix"
            background: Rectangle { 
                color: snowflakeRepeater.selectedTexture === "mix" ? Kirigami.Theme.highlightColor : "transparent"
                border.color: Kirigami.Theme.textColor
                radius: 6
                opacity: snowflakeRepeater.selectedTexture === "mix" ? 1 : 0.4
                border.width: snowflakeRepeater.selectedTexture === "mix" ? 2 : 1 
            }
            contentItem: Item {
                Image { source: "data/snowflake1.png"; width: 22; height: 22; anchors.top: parent.top; anchors.left: parent.left }
                Image { source: "data/snowflake2.png"; width: 22; height: 22; anchors.bottom: parent.bottom; anchors.right: parent.right }
                Text { text: "MIX"; anchors.centerIn: parent; font.pixelSize: 10; font.bold: true; color: Kirigami.Theme.textColor }
            }
        }
    }

    RowLayout {
        Kirigami.FormData.label: t("Цвет:", "Color:")
        Rectangle { 
            id: colorRect
            width: 32; height: 32
            color: "#ffffff" // Дефолт, перезапишется при загрузке конфига
            radius: 4; border.color: "gray"
            MouseArea { anchors.fill: parent; onClicked: colorDialog.open() } 
        }
        // Текстовое поле для ручного ввода цвета
        TextField { 
            text: colorRect.color
            onTextEdited: colorRect.color = text
            Layout.fillWidth: true 
        }
    }

    SpinBox { id: opacitySpin; Kirigami.FormData.label: t("Непрозрачность %:", "Opacity %:"); from: 0; to: 100 }
    SpinBox { id: sizeSpin; Kirigami.FormData.label: t("Размер:", "Size:"); from: 1; to: 100 }

    Kirigami.Separator { Kirigami.FormData.label: t("Динамика", "Dynamics") }

    ComboBox {
        id: velocityCombo
        Kirigami.FormData.label: t("Режим падения:", "Fall Mode:")
        model: [t("Медленно (Вальс)", "Slow (Waltz)"), t("Нормально", "Normal"), t("Быстро (Метель)", "Fast (Blizzard)")]
    }

    SpinBox { id: particlesSpin; Kirigami.FormData.label: t("Интенсивность:", "Intensity:"); from: 1; to: 500 }
    
    RowLayout {
        Kirigami.FormData.label: t("Вращение:", "Rotation:")
        SpinBox { id: rotationSpin; from: 0; to: 360 }
        CheckBox { id: randomRotCheck; text: t("В разные стороны", "Bi-directional") }
    }

    CheckBox { id: depthCheck; Kirigami.FormData.label: t("3D Эффект:", "3D Effect:"); text: t("Полет в камеру", "Fly towards camera") }
    SpinBox { id: windSpin; Kirigami.FormData.label: t("Постоянный ветер:", "Constant Wind:"); from: -500; to: 500 }
    SpinBox { id: gustsSpin; Kirigami.FormData.label: t("Сила порывов:", "Gust Strength:"); from: 0; to: 1000 }

    Kirigami.Separator { }

    // Кнопка сброса
    Button {
        text: t("Вернуть настройки по умолчанию", "Restore Defaults")
        icon.name: "edit-reset"
        onClicked: {
            particlesSpin.value = 60
            sizeSpin.value = 9
            colorRect.color = "#ffffff"
            windSpin.value = 10
            gustsSpin.value = 20
            velocityCombo.currentIndex = 1
            fillModeCombo.currentIndex = 0
            snowflakeRepeater.selectedTexture = "data/snowflake1.png"
            rotationSpin.value = 40
            opacitySpin.value = 100
            randomRotCheck.checked = false
            depthCheck.checked = false
            // Для картинки сложнее, так как она не alias, сбрасываем свойство
            cfg_Image = ""
        }
    }

    // Диалоги
    FileDialog { 
        id: bgFileDialog
        title: t("Выберите изображение", "Choose Image")
        nameFilters: ["Image files (*.jpg *.png *.jpeg *.bmp *.svg)"]
        onAccepted: cfg_Image = selectedFile.toString().replace("file://", "") 
    }
    
    ColorDialog { 
        id: colorDialog
        onAccepted: colorRect.color = selectedColor 
    }
}
