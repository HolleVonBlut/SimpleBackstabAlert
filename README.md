Simple Backstab Alert (BSA)
Simple Backstab Alert es un addon ligero diseñado específicamente para Turtle WoW (1.12.1). Su función principal es proporcionar retroalimentación visual y sonora inmediata cuando intentas usar habilidades que requieren estar detrás del objetivo (como Backstab, Ambush o Shred) y no estás en la posición correcta.

🚀 Funcionalidades
Indicador de 3 Colores:

🟢 Verde: Estás fuera de combate (Estado de espera).

🟡 Amarillo: Estás en combate y posicionado correctamente (o no has fallado ataques).

🔴 Rojo: ¡Error de posición! Se activa cuando el juego muestra el mensaje "You must be behind your target".

Alerta Sonora: Emite un sonido personalizado (alerta.wav) al detectar el error de posición.

Sistema Anti-Spam: El sonido está limitado a una reproducción por segundo para evitar ruidos molestos si se presiona la tecla repetidamente.

Modo Edición (Edit Mode): Permite mover el icono libremente por la pantalla y guardar su posición.

Escalado Dinámico: El usuario puede cambiar el tamaño del icono mediante comandos.

Persistencia: La posición, el tamaño y la configuración del sonido se guardan automáticamente entre sesiones.

🛠 Instalación
Descarga o crea la carpeta SimpleBackstabAlert dentro de tu directorio Interface\AddOns\.

Asegúrate de que la estructura sea la siguiente:


Plaintext
SimpleBackstabAlert/
├── SimpleBackstabAlert.toc
├── SimpleBackstabAlert.lua
└── media/
    ├── verde.tga
    ├── amarillo.tga
    ├── rojo.tga
    └── alerta.wav

⌨️ Comandos de ChatPuedes usar el comando principal /bsa seguido de una opción:

Comando // Descripción
/bsa help,Muestra el menú de ayuda con todos los comandos disponibles.
/bsa edit,Interruptor (Toggle): Desbloquea el icono para moverlo con el ratón o lo bloquea guardando la posición.
/bsa size [N],Cambia el tamaño del icono. Ejemplo: /bsa size 80 (Valores recomendados: 20 a 400).
/bsa sound,Interruptor (Toggle): Activa o desactiva la alerta sonora.
