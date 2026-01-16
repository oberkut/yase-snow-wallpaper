import QtQuick
import QtQuick3D
import QtQuick3D.Particles3D
import org.kde.plasma.plasmoid

WallpaperItem {
    id: wallpaper

    // --- Логика параметров ---
    // Читаем настройки напрямую из wallpaper.configuration
    readonly property var speeds: [25, 80, 200]
    readonly property real currentSpeed: speeds[wallpaper.configuration.Velocity] || 80
    // Вычисляем время жизни снежинки: чем медленнее летит, тем дольше живет
    readonly property real calcLife: (5000 / currentSpeed) * 1000 + 3000
    
    readonly property bool isMix: wallpaper.configuration.Snowflake === "mix"
    readonly property real snowAlpha: wallpaper.configuration.Opacity / 100.0
    
    // Настройки вращения
    readonly property bool biDir: wallpaper.configuration.RandomRot
    readonly property int rotSpeed: wallpaper.configuration.Rotation
    readonly property vector3d rotVel: biDir ? Qt.vector3d(0,0,0) : Qt.vector3d(0, 0, rotSpeed)
    readonly property vector3d rotVar: biDir ? Qt.vector3d(0, 0, rotSpeed) : Qt.vector3d(0, 0, 10)
    
    // 3D эффект (глубина полета по Z оси)
    readonly property real zVar: wallpaper.configuration.DepthEffect ? 20.0 : 0.0

    // Функция для корректного пути к файлам (убирает file:// если нужно)
    function resolvePath(p) {
        if (!p || p === "") return "";
        let s = p.toString();
        if (s.indexOf("/") === 0) return "file://" + s;
        return s;
    }

    // --- Визуальная часть ---
    Image {
        id: root
        anchors.fill: parent
        
        // Режимы заполнения фона
        fillMode: {
            switch(wallpaper.configuration.FillMode) {
                case 1: return Image.PreserveAspectFit;
                case 2: return Image.Stretch;
                default: return Image.PreserveAspectCrop;
            }
        }
        source: resolvePath(wallpaper.configuration.Image)

        // 3D Сцена
        View3D {
            anchors.fill: parent
            // Прозрачный фон для сцены, чтобы видеть обои сзади
            environment: SceneEnvironment { 
                backgroundMode: SceneEnvironment.Transparent 
                antialiasingMode: SceneEnvironment.MSAA 
            }
            
            // Камера смотрит на снег
            PerspectiveCamera { 
                id: camera
                position: Qt.vector3d(0, 0, 600)
                clipFar: 5000 
            }

            // Система частиц
            ParticleSystem3D {
                id: psystem
                startTime: Math.min(wallpaper.calcLife, 60000) // Предзапуск анимации

                // Определяем три типа снежинок как спрайты
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

                // Эмиттеры (источники) частиц
                // Логика emitRate: если выбран MIX, делим кол-во на 3. Если конкретная текстура - выдаем все кол-во на неё.
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
                
                // Копия эмиттера для снежинки 2
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

                // Копия эмиттера для снежинки 3
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

                // Ветер (Wander) - добавляет случайности движению
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
