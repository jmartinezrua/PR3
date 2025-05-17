Aquí tienes el contenido completo del `README.md` generado:

---

# Proyecto PR3 – UOC 20242

Este proyecto está compuesto por dos partes:

* **UOCPlay**: una biblioteca estática con toda la lógica del programa.
* **UOC20242**: una aplicación que utiliza la biblioteca y ejecuta pruebas.

---

## 📁 Estructura de carpetas

```
UOC20242/
├── src/                 # Código fuente principal (main.c)
├── test/                # Pruebas organizadas en test/src y test/include
├── UOCPlay/             # Biblioteca estática
│   ├── include/         # Cabeceras públicas
│   └── src/             # Implementación
├── build/               # Carpeta generada automáticamente por CMake
└── .vscode/             # Configuración para VS Code (tareas, depuración, IntelliSense)
```

---

## 🛠️ Requisitos

En WSL (Debian/Ubuntu):

```bash
sudo apt update
sudo apt install build-essential gdb cmake -y
```

---

## ⚙️ Compilación

Desde la carpeta `UOC20242/`:

```bash
cmake -S . -B build/UOC20242
cmake --build build/UOC20242
```

Esto compila la biblioteca `UOCPlay` y el ejecutable `UOC20242`.

---

## ▶️ Ejecución

```bash
./build/UOC20242/UOC20242
```

---

## 🐞 Depuración en Visual Studio Code

1. Abre la carpeta `UOC20242/` en VS Code.
2. Ejecuta la tarea:

   * `Terminal > Run Task > Build UOC20242`
3. Inicia la depuración:

   * Presiona `F5`
   * O elige `Run > Start Debugging`

> Se usa `gdb` sobre WSL, configurado en `.vscode/launch.json`.

---

## 🧠 IntelliSense

El archivo `.vscode/c_cpp_properties.json` define las rutas de cabecera para que el autocompletado funcione correctamente.

---

## 🧹 Limpieza

Para limpiar toda la compilación:

```bash
rm -rf build/
```

---

## 📦 Entrega

Recuerda incluir en tu entrega:

* Los archivos `.c` y `.h` modificados
* El archivo `README.txt` con tu nombre, correo y sistema operativo
* El informe PDF (2 páginas) explicando dificultades y aprendizajes


