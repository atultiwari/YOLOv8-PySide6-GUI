# YoloSide ~ A GUI For YoloV8 `V2.0`
---
![](img/home.png)

## 🛑Warning
- This project has been discontinued for maintenance, and normal operation is not guaranteed. You can continue to refer to the following projects. Thanks to every open source contributor for their contribution.
- 此项目已经停止维护，不保证仍能正常运行。您可以继续参考以下项目：
- [Ultralytics-PySide6](https://github.com/WangQvQ/Ultralytics-PySide6)
- [YOLOSHOW](https://github.com/SwimmingLiu/YOLOSHOW)
- [yolov8客户端-简单修改](https://www.bilibili.com/video/BV1xh4y1F7sv/?spm_id_from=333.999.0.0&vd_source=0940bf29b38efba56ccfc6a3cef8182d)
- [YOLOv8-GUI-PySide6](https://github.com/SuPoTing/YOLOv8-GUI-PySide6)
- Please search for more projects on github yourself, all the best.

## How to Run

### Quickstart (macOS)

A helper script, [`run.sh`](./run.sh), wraps every command needed to bootstrap and launch the project on macOS (Apple Silicon and Intel). It creates an isolated `.venv`, installs the exact pinned versions the code requires, and starts the GUI.

```bash
./run.sh setup     # one-time: create venv + install pinned deps
./run.sh start     # launch the GUI (default command, same as ./run.sh)
```

#### Available tags

| Tag | What it does |
| --- | --- |
| `setup` | Create `.venv` and install pinned dependencies |
| `start` (default) | Activate the venv and run `python main.py` |
| `ui` | Regenerate `ui/home.py` from `home.ui` (`pyside6-uic`) |
| `rc` | Regenerate `ui/resources_rc.py` from `resources.qrc` (`pyside6-rcc`) |
| `regen` | Run both `ui` and `rc` |
| `doctor` | Print Python + key package versions to verify the environment |
| `clean` | Delete the local `.venv` |
| `help` | Show inline usage |

#### Pinned versions (do not change without code updates)

- `python` 3.8 – 3.11 (the script auto-picks `python3.11` → `python3.8`)
- `ultralytics==8.0.48` — required, uses the legacy `ultralytics.yolo.*` namespace this code imports
- `pyside6==6.4.2`
- `numpy<2`, `torch`, `torchvision`, `opencv-python`, plus standard scientific deps

> If you skip the pins, you will see errors such as `not enough values to unpack (expected 5, got 4)` or `ModuleNotFoundError: No module named 'ultralytics.yolo'`.

### Manual install (any OS)

```bash
python -m venv .venv
source .venv/bin/activate
pip install --upgrade pip
pip install "ultralytics==8.0.48" "pyside6==6.4.2" "numpy<2" torch torchvision opencv-python
python main.py
```

## Notice
- `ultralytics` follows the `GPL-3.0`, if you need commercial use, you need to obtain its license.
- If you expect to use your own model, you need to use `ultralytics` to train the yolov8/5 model first, and then put the trained `.pt` file into the `models` folder.
- There are still some bugs in the software, and I will continue to optimize and add some more interesting functions as my time allows.
- If you check the save results, they will be saved in the `./run` path
- The UI design file is `home.ui`; if you modify it, regenerate the Python with `./run.sh ui` (or `pyside6-uic home.ui -o ui/home.py`)
- The resource file is `resources.qrc`; if you modify the default icon, regenerate it with `./run.sh rc` (or `pyside6-rcc resources.qrc -o ui/resources_rc.py`)

## Video
- [BiliBili~YoloSide V2.0](https://www.bilibili.com/video/BV1Cb411f7cw/?spm_id_from=333.999.0.0)
- [Youtube~YoloSide V2.0](https://www.youtube.com/watch?v=auJLVrt7ImQ)

## To Do

- [ ] The input source supports camera and RTSP (if you need this function urgently, you can modify it according to the `chosen_cam`、`chose_rtsp`、`load_rtsp` function in `mian.py`)
- [ ] Graph showing changes in target quantity
- [ ] Target tracking
- [ ] Instance segmentation
- [ ] Monitor system hardware usage

## References
- [PyQt5-YOLOv5](https://github.com/Javacr/PyQt5-YOLOv5)
- [ultralytics](https://github.com/ultralytics/ultralytics)
- [pyqt5仿交易软件界面](https://www.bilibili.com/video/BV1tg411Y7KH/?spm_id_from=333.999.0.0&vd_source=0940bf29b38efba56ccfc6a3cef8182d)
