import QtQuick
import QtQuick.Controls
import QtQuick.Dialogs
import QtQuick.Layouts
import org.kde.kirigami as Kirigami

Kirigami.FormLayout {
    id: root
    property string cfg_Image; property int cfg_FillMode; property string cfg_Snowflake
    property int cfg_Particles; property int cfg_Size; property int cfg_Velocity
    property color cfg_SnowColor; property int cfg_Opacity; property int cfg_Rotation
    property bool cfg_RandomRot; property bool cfg_DepthEffect
    property int cfg_Wind; property int cfg_Gusts

    function t(ru, en) { return (Qt.locale().name.substring(0,2) === "ru") ? ru : en; }
    function previewPath(p) {
        if (!p || p === "") return "";
        let s = p.toString();
        if (s.indexOf("/") === 0) return "file://" + s;
        return s;
    }

    Kirigami.Separator { Kirigami.FormData.label: t("Фон рабочего стола", "Desktop Background") }
    
    Item {
        Kirigami.FormData.label: t("Изображение:", "Image:")
        implicitWidth: 200; implicitHeight: 112
        Rectangle {
            anchors.fill: parent; color: "transparent"; border.color: Kirigami.Theme.textColor; border.width: 1; radius: 4; clip: true
            Image { anchors.fill: parent; anchors.margins: 1; source: previewPath(cfg_Image); fillMode: Image.PreserveAspectCrop; visible: source != "" }
            Kirigami.Icon { anchors.centerIn: parent; source: "document-open-symbolic"; width: 32; height: 32; opacity: 0.5; visible: cfg_Image === "" }
            Text { anchors.bottom: parent.bottom; anchors.horizontalCenter: parent.horizontalCenter; anchors.bottomMargin: 8; text: t("Нажмите для выбора фона", "Click to choose background"); font.pixelSize: 9; color: Kirigami.Theme.textColor; opacity: 0.6; visible: cfg_Image === "" }
            MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: bgFileDialog.open() }
        }
    }

    ComboBox {
        Kirigami.FormData.label: t("Размещение:", "Placement:")
        model: [t("Заполнить экран (Crop)", "Fill Screen (Crop)"), t("Вписать (Fit)", "Fit"), t("Растянуть (Stretch)", "Stretch")]
        currentIndex: cfg_FillMode
        onActivated: cfg_FillMode = index
    }

    Kirigami.Separator { Kirigami.FormData.label: t("Внешний вид снега", "Snow Appearance") }

    RowLayout {
        Kirigami.FormData.label: t("Текстура:", "Texture:")
        spacing: 10
        Repeater {
            model: ["data/snowflake1.png", "data/snowflake2.png", "data/snowflake3.png"]
            Button {
                implicitWidth: 54; implicitHeight: 54; onClicked: cfg_Snowflake = modelData
                background: Rectangle { color: cfg_Snowflake === modelData ? Kirigami.Theme.highlightColor : "transparent"; border.color: Kirigami.Theme.textColor; radius: 6; opacity: cfg_Snowflake === modelData ? 1 : 0.4; border.width: cfg_Snowflake === modelData ? 2 : 1 }
                contentItem: Image { source: modelData; fillMode: Image.PreserveAspectFit; anchors.margins: 4 }
            }
        }
        Button {
            implicitWidth: 54; implicitHeight: 54; onClicked: cfg_Snowflake = "mix"
            background: Rectangle { color: cfg_Snowflake === "mix" ? Kirigami.Theme.highlightColor : "transparent"; border.color: Kirigami.Theme.textColor; radius: 6; opacity: cfg_Snowflake === "mix" ? 1 : 0.4; border.width: cfg_Snowflake === "mix" ? 2 : 1 }
            contentItem: Item {
                Image { source: "data/snowflake1.png"; width: 22; height: 22; anchors.top: parent.top; anchors.left: parent.left }
                Image { source: "data/snowflake2.png"; width: 22; height: 22; anchors.bottom: parent.bottom; anchors.right: parent.right }
                Text { text: "MIX"; anchors.centerIn: parent; font.pixelSize: 10; font.bold: true; color: Kirigami.Theme.textColor }
            }
        }
    }

    RowLayout {
        Kirigami.FormData.label: t("Цвет:", "Color:")
        Rectangle { width: 32; height: 32; color: cfg_SnowColor; radius: 4; border.color: "gray"; MouseArea { anchors.fill: parent; onClicked: colorDialog.open() } }
        TextField { text: cfg_SnowColor; onTextEdited: cfg_SnowColor = text; Layout.fillWidth: true }
    }

    SpinBox { Kirigami.FormData.label: t("Непрозрачность %:", "Opacity %:"); from: 0; to: 100; value: cfg_Opacity; onValueModified: cfg_Opacity = value }
    SpinBox { Kirigami.FormData.label: t("Размер:", "Size:"); from: 1; to: 100; value: cfg_Size; onValueModified: cfg_Size = value }

    Kirigami.Separator { Kirigami.FormData.label: t("Динамика", "Dynamics") }

    ComboBox {
        Kirigami.FormData.label: t("Режим падения:", "Fall Mode:")
        model: [t("Медленно (Вальс)", "Slow (Waltz)"), t("Нормально", "Normal"), t("Быстро (Метель)", "Fast (Blizzard)")]
        currentIndex: cfg_Velocity
        onActivated: cfg_Velocity = index
    }

    SpinBox { Kirigami.FormData.label: t("Интенсивность:", "Intensity:"); from: 1; to: 500; value: cfg_Particles; onValueModified: cfg_Particles = value }
    
    RowLayout {
        Kirigami.FormData.label: t("Вращение:", "Rotation:")
        SpinBox { from: 0; to: 360; value: cfg_Rotation; onValueModified: cfg_Rotation = value }
        CheckBox { text: t("В разные стороны", "Bi-directional"); checked: cfg_RandomRot; onToggled: cfg_RandomRot = checked }
    }

    CheckBox { Kirigami.FormData.label: t("3D Эффект:", "3D Effect:"); text: t("Полет в камеру", "Fly towards camera"); checked: cfg_DepthEffect; onToggled: cfg_DepthEffect = checked }
    SpinBox { Kirigami.FormData.label: t("Постоянный ветер:", "Constant Wind:"); from: -500; to: 500; value: cfg_Wind; onValueModified: cfg_Wind = value }
    SpinBox { Kirigami.FormData.label: t("Сила порывов:", "Gust Strength:"); from: 0; to: 1000; value: cfg_Gusts; onValueModified: cfg_Gusts = value }

    Kirigami.Separator { }

    Button {
        text: t("Вернуть настройки по умолчанию", "Restore Defaults")
        icon.name: "edit-reset"
        onClicked: {
            cfg_Particles = 60; cfg_Size = 9; cfg_SnowColor = "#ffffff";
            cfg_Wind = 10; cfg_Gusts = 20; cfg_Velocity = 1; cfg_FillMode = 0;
            cfg_Snowflake = "data/snowflake1.png";
            cfg_Rotation = 40; cfg_Opacity = 100;
            cfg_RandomRot = false; cfg_DepthEffect = false;
        }
    }

    FileDialog { id: bgFileDialog; onAccepted: cfg_Image = selectedFile.toString().replace("file://", "") }
    ColorDialog { id: colorDialog; onAccepted: cfg_SnowColor = selectedColor }
}
