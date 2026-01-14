#!/bin/bash

NAME="org.kde.yase"

kpackagetool6 -t Plasma/Wallpaper -r $NAME 2>/dev/null
rm -rf $NAME
mkdir -p $NAME/contents/ui/data
mkdir -p $NAME/contents/config

cat <<EOF > $NAME/metadata.json
{
    "KPackageStructure": "Plasma/Wallpaper",
    "KPlugin": {
        "Authors": [{"Name": "Alexander Novichkov aka BerkuT"}],
        "Description": "YaSE: Yet another Snow Effect. Professional 3D snowfall",
        "Icon": "weather-snow",
        "Id": "$NAME",
        "Name": "YaSE (Yet another Snow Effect)",
        "Version": "0.5",
        "License": "GPL-3.0+"
    },
    "X-KDE-ParentApp": "org.kde.plasmashell"
}
EOF

cat <<EOF > $NAME/contents/config/main.xml
<?xml version="1.0" encoding="UTF-8"?>
<kcfg xmlns="http://www.kde.org/standards/kcfg/1.0">
  <group name="General">
    <entry name="Image" type="String"><default></default></entry>
    <entry name="FillMode" type="int"><default>0</default></entry>
  </group>
  <group name="Snow">
    <entry name="Velocity" type="int"><default>1</default></entry>
    <entry name="Particles" type="int"><default>60</default></entry>
    <entry name="Size" type="int"><default>9</default></entry>
    <entry name="Snowflake" type="String"><default>data/snowflake1.png</default></entry>
    <entry name="SnowColor" type="Color"><default>#ffffff</default></entry>
    <entry name="Opacity" type="int"><default>100</default></entry>
    <entry name="Rotation" type="int"><default>40</default></entry>
    <entry name="RandomRot" type="bool"><default>false</default></entry>
    <entry name="DepthEffect" type="bool"><default>false</default></entry>
    <entry name="Wind" type="int"><default>10</default></entry>
    <entry name="Gusts" type="int"><default>20</default></entry>
  </group>
</kcfg>
EOF

cat <<'EOF' > $NAME/contents/ui/main.qml
import QtQuick
import QtQuick3D
import QtQuick3D.Particles3D
import org.kde.plasma.plasmoid

WallpaperItem {
    id: wallpaper
    readonly property var speeds: [25, 80, 200]
    readonly property real currentSpeed: speeds[wallpaper.configuration.Velocity] || 80
    readonly property real calcLife: (5000 / currentSpeed) * 1000 + 3000
    readonly property bool isMix: wallpaper.configuration.Snowflake === "mix"
    readonly property real snowAlpha: wallpaper.configuration.Opacity / 100.0
    readonly property bool biDir: wallpaper.configuration.RandomRot
    readonly property int rotSpeed: wallpaper.configuration.Rotation
    readonly property vector3d rotVel: biDir ? Qt.vector3d(0,0,0) : Qt.vector3d(0, 0, rotSpeed)
    readonly property vector3d rotVar: biDir ? Qt.vector3d(0, 0, rotSpeed) : Qt.vector3d(0, 0, 10)
    readonly property real zVar: wallpaper.configuration.DepthEffect ? 20.0 : 0.0

    function resolvePath(p) {
        if (!p || p === "") return "";
        let s = p.toString();
        if (s.indexOf("/") === 0) return "file://" + s;
        return s;
    }

    Image {
        id: root
        anchors.fill: parent
        fillMode: {
            switch(wallpaper.configuration.FillMode) {
                case 1: return Image.PreserveAspectFit;
                case 2: return Image.Stretch;
                default: return Image.PreserveAspectCrop;
            }
        }
        source: resolvePath(wallpaper.configuration.Image)

        View3D {
            anchors.fill: parent
            environment: SceneEnvironment { backgroundMode: SceneEnvironment.Transparent; antialiasingMode: SceneEnvironment.MSAA }
            PerspectiveCamera { id: camera; position: Qt.vector3d(0, 0, 600); clipFar: 5000 }

            ParticleSystem3D {
                id: psystem
                startTime: Math.min(wallpaper.calcLife, 60000)
                SpriteParticle3D {
                    id: snow1; billboard: true
                    color: Qt.rgba(wallpaper.configuration.SnowColor.r, wallpaper.configuration.SnowColor.g, wallpaper.configuration.SnowColor.b, wallpaper.snowAlpha)
                    sprite: Texture { source: resolvePath("data/snowflake1.png") }
                    maxAmount: 15000; fadeInDuration: 1000; fadeOutDuration: 1500
                }
                SpriteParticle3D {
                    id: snow2; billboard: true
                    color: Qt.rgba(wallpaper.configuration.SnowColor.r, wallpaper.configuration.SnowColor.g, wallpaper.configuration.SnowColor.b, wallpaper.snowAlpha)
                    sprite: Texture { source: resolvePath("data/snowflake2.png") }
                    maxAmount: 15000; fadeInDuration: 1000; fadeOutDuration: 1500
                }
                SpriteParticle3D {
                    id: snow3; billboard: true
                    color: Qt.rgba(wallpaper.configuration.SnowColor.r, wallpaper.configuration.SnowColor.g, wallpaper.configuration.SnowColor.b, wallpaper.snowAlpha)
                    sprite: Texture { source: resolvePath("data/snowflake3.png") }
                    maxAmount: 15000; fadeInDuration: 1000; fadeOutDuration: 1500
                }
                readonly property real baseScale: wallpaper.configuration.Size / 3.5
                readonly property real scaleVar: baseScale * 0.3
                ParticleEmitter3D {
                    particle: snow1
                    enabled: isMix || wallpaper.configuration.Snowflake === "data/snowflake1.png"
                    emitRate: isMix ? (wallpaper.configuration.Particles / 3) : (wallpaper.configuration.Snowflake === "data/snowflake1.png" ? wallpaper.configuration.Particles : 0)
                    position: Qt.vector3d(0, 1400, -200); scale: Qt.vector3d(60.0, 1.0, 40.0)
                    shape: ParticleShape3D { type: ParticleShape3D.Cube }
                    particleScale: psystem.baseScale
                    particleScaleVariation: psystem.scaleVar
                    particleRotationVariation: Qt.vector3d(0, 0, 180)
                    particleRotationVelocity: wallpaper.rotVel
                    particleRotationVelocityVariation: wallpaper.rotVar
                    velocity: VectorDirection3D {
                        direction: Qt.vector3d(wallpaper.configuration.Wind, -wallpaper.currentSpeed, 0)
                        directionVariation: Qt.vector3d(Math.abs(wallpaper.configuration.Wind) * 0.2, wallpaper.currentSpeed * 0.1, wallpaper.zVar)
                    }
                    lifeSpan: wallpaper.calcLife
                }
                ParticleEmitter3D {
                    particle: snow2
                    enabled: isMix || wallpaper.configuration.Snowflake === "data/snowflake2.png"
                    emitRate: isMix ? (wallpaper.configuration.Particles / 3) : (wallpaper.configuration.Snowflake === "data/snowflake2.png" ? wallpaper.configuration.Particles : 0)
                    position: Qt.vector3d(0, 1400, -200); scale: Qt.vector3d(60.0, 1.0, 40.0)
                    shape: ParticleShape3D { type: ParticleShape3D.Cube }
                    particleScale: psystem.baseScale
                    particleScaleVariation: psystem.scaleVar
                    particleRotationVariation: Qt.vector3d(0, 0, 180)
                    particleRotationVelocity: wallpaper.rotVel
                    particleRotationVelocityVariation: wallpaper.rotVar
                    velocity: VectorDirection3D {
                        direction: Qt.vector3d(wallpaper.configuration.Wind, -wallpaper.currentSpeed, 0)
                        directionVariation: Qt.vector3d(Math.abs(wallpaper.configuration.Wind) * 0.2, wallpaper.currentSpeed * 0.1, wallpaper.zVar)
                    }
                    lifeSpan: wallpaper.calcLife
                }
                ParticleEmitter3D {
                    particle: snow3
                    enabled: isMix || wallpaper.configuration.Snowflake === "data/snowflake3.png"
                    emitRate: isMix ? (wallpaper.configuration.Particles / 3) : (wallpaper.configuration.Snowflake === "data/snowflake3.png" ? wallpaper.configuration.Particles : 0)
                    position: Qt.vector3d(0, 1400, -200); scale: Qt.vector3d(60.0, 1.0, 40.0)
                    shape: ParticleShape3D { type: ParticleShape3D.Cube }
                    particleScale: psystem.baseScale
                    particleScaleVariation: psystem.scaleVar
                    particleRotationVariation: Qt.vector3d(0, 0, 180)
                    particleRotationVelocity: wallpaper.rotVel
                    particleRotationVelocityVariation: wallpaper.rotVar
                    velocity: VectorDirection3D {
                        direction: Qt.vector3d(wallpaper.configuration.Wind, -wallpaper.currentSpeed, 0)
                        directionVariation: Qt.vector3d(Math.abs(wallpaper.configuration.Wind) * 0.2, wallpaper.currentSpeed * 0.1, wallpaper.zVar)
                    }
                    lifeSpan: wallpaper.calcLife
                }
                Wander3D {
                    enabled: wallpaper.configuration.Gusts > 0
                    system: psystem
                    globalAmount: Qt.vector3d(wallpaper.configuration.Gusts, wallpaper.configuration.Gusts * 0.3, wallpaper.configuration.Gusts * 0.5)
                    globalPace: Qt.vector3d(0.15, 0.1, 0.15)
                    uniqueAmount: Qt.vector3d(wallpaper.configuration.Gusts * 0.4, 15, 20)
                    uniquePace: Qt.vector3d(0.3, 0.2, 0.3)
                }
            }
        }
    }
}
EOF

cat <<EOF > $NAME/contents/ui/config.qml
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
EOF

cat << 'EOF' | base64 -d > $NAME/contents/ui/data/snowflake1.png
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
5ajJPEm6AAAAAElFTkSuQmCC
EOF
cat << 'EOF' | base64 -d > $NAME/contents/ui/data/snowflake2.png
iVBORw0KGgoAAAANSUhEUgAAAGQAAABkCAMAAABHPGVmAAAAAXNSR0IArs4c6QAAAAlwSFlzAAAL
EwAACxMBAJqcGAAAAAd0SU1FB9oCHBMJNh9mHVcAAAAddEVYdENvbW1lbnQAQ3JlYXRlZCB3aXRo
IFRoZSBHSU1Q72QlbgAAAtZQTFRFAAAA////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
////////E/HvlQAAAPF0Uk5TAAECAwQFBgcICQoLDA0ODxAREhMUFRYXGBkaGxwdHh8gISIjJCUm
JygpKissLS4vMDEyMzQ1Njc4OTo7PD0+P0BBQkNERUZHSElKS0xNTk9QUlNUVVZYWVpbXF1eX2Bi
Y2RlZmdoaWtsbW5vcHFyc3R1dnd4eXt8fn+AgYKDhIWGh4mKi4yNjo+QkZKTlJWWl5udnp+goaKj
pKWmp6ipqqusra6vsLGys7S1tre4u7y9vr/AwcLDxMXGx8jJysvMzc7P0NHS09TV1tfY2drb3N3e
4OHi4+Tl5ufo6err7O3u7/Dx8vP09fb3+Pn6+/z9/pvsBHUAAAABYktHRACIBR1IAAAGbElEQVR4
2u2a13LjOhKGmSnmLHne/+HGEnPO4vkBoepsrWSXL2Tc7IJS2eMB+PHvbqCbBEWBQ/ufhbD+x69C
RFEkjOP4RYgkShRyP+6/BpFIw887ab8DAUOWZQrZ9x2U34CIsqwosiTCWvu27fvxCxBRklVVlSUJ
1trXdd3vx/shkqJoqgYpAoQs67Jt97dDRFnVNF1TFEXYtm2Zl2Xdj3dDJFXTT7oOLQJ0zPM0L+v9
vRAI0U4n4wSOJiwgTOM0LfvxVgiE6IZpGNbpBMg09eM4jDOkvBMCIYZpWbZlUMjYd30/jJDyVoh6
Mi3bcyzD1IV5GPu27vphWt8KkTXC8FxQAAGjqQll2d8IEZWTZfu+73qmeRKmYaibqqq6ftqO90Ek
1bT9IPQD29GhZG67sirKqhvW+/sgsm55QRwFvsd8UldlnpV1P+9vg4iy4flJHEah6ZiqsA7tUORF
llb1+KP4Er/8w3+MFjXbiy9RErmeYSCEx7Fu8jS/ZnW3HK+GfgsRH/mV9TwO1l8yvPCcXGI/cEw6
T4a2rLJreivq8c7OgnFsJMZh7FcQEekV+RWNMe744IeoWEHykZzPgWubJ5hrGrqmvN3Sz7Tst0Nk
40B5ENi4lxDSUZZIIxjCIA0jBNWJz5c/SRTZtqECso5dl+fp3+sta1cBw9goDGKjdgJ6AQFDQu7D
94EhVwMGybOyE39cLufYd01dxSq8zkNTZbfr9TNrd5KVMZSoeSCQmjd8QXkBIQg0GQfDoD1KBiP6
83GJI985aaos7OsytVWeXT//5qMgMO0Mse040IB5AcEFqYqq4YuPrNCLOwRisO1QgstHcgk8uF0G
ZIfr6/Kafl7LTURPdBWp7G1ftxWfBV9oeYKIoozTa8h+OMCSZBzMj7tgJLBW6BgQgvQLKWNbwF7p
KMgsUu47Dpx9mXEsC1D7cTxBJECAMHXjdNKpIvlxhcQIknv+E/oILYUWEhsCrCr+3po7MdVD8U4V
zNM0zgMwgNyfILRQQIY1bZtQwFFltEOkoXw/BUlkmxAiAnJAytDlaTlJNHQPcUdbQSCMrhuQm2mh
8QyRVTCw2rq2bRGKgkZcSimCHQXUI/Tf1Ctl3gkPxgFtaITRd12D1RmUdX8BEQGBqSzH9VzXMjWi
BQGH09Do1xzX0BWZnXTf5rFpF+IPmBPQO9GxDH3T1E3bTyOBvAxhosQ0Hd9zA8+y4RdUWTILZkHQ
mBDKpFIWQWCBu6MSgz+6vi6bumqHgSh5FcJwCikWTNd3kTlcxzBUVFlQwpYZUWdCBCZlPh6/EyUb
yqRxbBtkmaZqBlJkwCXPEGov1COu54Vh6Po2uXI6/VkniYTW41fiBJav6FTaqbKuaoqiqOsGtQyz
1hMEUrSTYTleEISRF9oOCSY2DUT6/1QIzEWlUMbBJhIJt7Yr6rwoy7rtx2mBkJcQTEfdQL0Q+nHo
h/A+IozOAxxsdWMrLXH2wSB0HiGy4POiKrKqQIUxzpiKryG4VA3zxPUjZFokKMtA7ftQwiiEwc7N
GA8l24IKBokMOTmvGsyTBUJfQlidaDlBGEfQ4jkGpDATPdq/EHadzHQQMrY1dORZUbY9qS2/yYwS
vOK4YMRR5HmmoT2cLf53d8pgEBIEyzjUdZ5noDQtPHI/voagwFJPlhvGcXIOAt9FeU2lPPdkJBbO
KMGbqixvaZYVTT+tKMe+gcAtumEHUZwkUeJ7FskfkPIKwTAQQvJLX1dpnqZZXnbjDId8C0Ec66Yb
xefkHAcBVhI2y7+AsNmPNaYss1t6y/JmmBG930GY8x0f9rrE58C3aAb5FkKzS1+Vt+wKa1UtnP6D
4k5WTHjlfEniOHTptJe+gdzpZG+KLEuvN3hk2PYfVZCyavsR7PURh4FtYslnUl4LwRI/dGWRfcJa
edWt+w/LVEV3goRUc5fQg8HIKvkFhKyNMFZdXEmtl5btvP24FtYMLzjDYEkc0SpIemkwNkdQH+VZ
CmPdynpcBD4QPubi43g+IcxnMvJZVvgskFyWej5Ji0/65VJI8CmJuBR3fMpULgU3l1sHLjdBfG7n
uNyYcrnF5vKwgMdjDy4PcLg8iuLxUI3H40EODzo5PLLl8PCZw2N0DhsCHLY2OGzScNhu4rBxxnkL
kP9mJv9tWf4bzPy3yjls+nN4fYHDixgcXinh8HIM99d8nvsf/3+/6xfbP5PtAN2N97LHAAAAAElF
TkSuQmCC
EOF
cat << 'EOF' | base64 -d > $NAME/contents/ui/data/snowflake3.png
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
EOF

kpackagetool6 -t Plasma/Wallpaper -i $NAME
kbuildsycoca6
zip -r org.kde.yase.plasmoid org.kde.yase
rm -rf org.kde.yase/
echo "--- YaSE v0.5 (Test Release) INSTALLED ---"
