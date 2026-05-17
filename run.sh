#!/usr/bin/env bash
# =============================================================================
#  YoloSide ~ YOLOv8 PySide6 GUI — macOS launcher
# =============================================================================
#  One script to bootstrap, run, and maintain the project on macOS
#  (Apple Silicon and Intel both supported).
#
#  Usage:
#      ./run.sh [command]
#
#  Commands (tags):
#      setup     Create venv + install pinned dependencies (run once)
#      start     Activate venv and launch the GUI (default)
#      ui        Regenerate ui/home.py from home.ui
#      rc        Regenerate ui/resources_rc.py from resources.qrc
#      regen     Regenerate both ui/home.py and ui/resources_rc.py
#      doctor    Check Python, venv, and key package versions
#      clean     Remove the local virtualenv (.venv)
#      help      Show this message
#
#  Pinned versions (do not change without code updates):
#      ultralytics == 8.0.48   (uses ultralytics.yolo.* namespace)
#      pyside6     == 6.4.2
# =============================================================================

set -euo pipefail

# ---------------------------------------------------------------------------
# === TAG: CONFIG =============================================================
# ---------------------------------------------------------------------------
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VENV_DIR="${PROJECT_DIR}/.venv"
PY_MIN_MAJOR=3
PY_MIN_MINOR=8
PY_MAX_MINOR=11      # ultralytics 8.0.48 + pyside6 6.4.2 are happiest on 3.8–3.11
ULTRALYTICS_PIN="ultralytics==8.0.48"
PYSIDE_PIN="pyside6==6.4.2"
EXTRA_PINS=(
    "numpy<2"        # ultralytics 8.0.48 predates the numpy 2.x ABI break
    "opencv-python"
    "torch"
    "torchvision"
    "Pillow"
    "PyYAML"
    "requests"
    "matplotlib"
    "pandas"
    "seaborn"
    "scipy"
    "tqdm"
    "psutil"
)

cd "${PROJECT_DIR}"

# ---------------------------------------------------------------------------
# === TAG: HELPERS ============================================================
# ---------------------------------------------------------------------------
log()  { printf "\033[1;34m[run.sh]\033[0m %s\n" "$*"; }
warn() { printf "\033[1;33m[run.sh]\033[0m %s\n" "$*" >&2; }
die()  { printf "\033[1;31m[run.sh]\033[0m %s\n" "$*" >&2; exit 1; }

pick_python() {
    # Prefer python3.11, then python3.10, then python3.9, then python3.8, then python3
    for candidate in python3.11 python3.10 python3.9 python3.8 python3; do
        if command -v "${candidate}" >/dev/null 2>&1; then
            local ver
            ver="$("${candidate}" -c 'import sys; print("%d.%d" % sys.version_info[:2])')"
            local major="${ver%%.*}"
            local minor="${ver##*.}"
            if (( major == PY_MIN_MAJOR )) \
               && (( minor >= PY_MIN_MINOR )) \
               && (( minor <= PY_MAX_MINOR )); then
                echo "${candidate}"
                return 0
            fi
        fi
    done
    die "No suitable Python found. Install Python ${PY_MIN_MAJOR}.${PY_MIN_MINOR}–${PY_MIN_MAJOR}.${PY_MAX_MINOR} (e.g. 'brew install python@3.11')."
}

ensure_venv() {
    if [[ ! -d "${VENV_DIR}" ]]; then
        die "No virtualenv at ${VENV_DIR}. Run: ./run.sh setup"
    fi
    # shellcheck disable=SC1091
    source "${VENV_DIR}/bin/activate"
}

# ---------------------------------------------------------------------------
# === TAG: SETUP ==============================================================
# ---------------------------------------------------------------------------
cmd_setup() {
    log "macOS detected: $(sw_vers -productName 2>/dev/null || echo macOS) $(sw_vers -productVersion 2>/dev/null || true) ($(uname -m))"

    local py
    py="$(pick_python)"
    log "Using interpreter: $(command -v "${py}") ($("${py}" -c 'import sys;print(sys.version.split()[0])'))"

    if [[ ! -d "${VENV_DIR}" ]]; then
        log "Creating virtualenv at ${VENV_DIR}"
        "${py}" -m venv "${VENV_DIR}"
    else
        log "Reusing existing virtualenv at ${VENV_DIR}"
    fi

    # shellcheck disable=SC1091
    source "${VENV_DIR}/bin/activate"

    log "Upgrading pip / setuptools / wheel"
    python -m pip install --upgrade pip setuptools wheel

    log "Installing pinned dependencies"
    python -m pip install \
        "${ULTRALYTICS_PIN}" \
        "${PYSIDE_PIN}" \
        "${EXTRA_PINS[@]}"

    log "Setup complete. Launch the GUI with: ./run.sh start"
}

# ---------------------------------------------------------------------------
# === TAG: START ==============================================================
# ---------------------------------------------------------------------------
cmd_start() {
    ensure_venv
    if [[ ! -f "${PROJECT_DIR}/models/yolov8n.pt" ]]; then
        warn "models/yolov8n.pt not found — the GUI may fail until you place a .pt model in models/."
    fi
    log "Launching YoloSide GUI"
    exec python main.py
}

# ---------------------------------------------------------------------------
# === TAG: UI REGEN ===========================================================
# ---------------------------------------------------------------------------
cmd_ui() {
    ensure_venv
    log "Regenerating ui/home.py from home.ui"
    pyside6-uic home.ui -o ui/home.py
    log "Done."
}

cmd_rc() {
    ensure_venv
    log "Regenerating ui/resources_rc.py from resources.qrc"
    pyside6-rcc resources.qrc -o ui/resources_rc.py
    log "Done."
}

cmd_regen() {
    cmd_ui
    cmd_rc
}

# ---------------------------------------------------------------------------
# === TAG: DOCTOR =============================================================
# ---------------------------------------------------------------------------
cmd_doctor() {
    log "macOS: $(sw_vers -productVersion 2>/dev/null || echo unknown) ($(uname -m))"
    if [[ -d "${VENV_DIR}" ]]; then
        # shellcheck disable=SC1091
        source "${VENV_DIR}/bin/activate"
        log "Python: $(python --version) at $(command -v python)"
        python - <<'PY'
import importlib
for mod in ("ultralytics", "PySide6", "torch", "cv2", "numpy"):
    try:
        m = importlib.import_module(mod)
        print(f"  ok  {mod:12s} {getattr(m, '__version__', '?')}")
    except Exception as exc:
        print(f"  FAIL {mod:12s} {exc}")
PY
    else
        warn "No virtualenv at ${VENV_DIR} — run: ./run.sh setup"
    fi
}

# ---------------------------------------------------------------------------
# === TAG: CLEAN ==============================================================
# ---------------------------------------------------------------------------
cmd_clean() {
    if [[ -d "${VENV_DIR}" ]]; then
        log "Removing ${VENV_DIR}"
        rm -rf "${VENV_DIR}"
    else
        log "Nothing to clean."
    fi
}

# ---------------------------------------------------------------------------
# === TAG: HELP ===============================================================
# ---------------------------------------------------------------------------
cmd_help() {
    sed -n '2,25p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'
}

# ---------------------------------------------------------------------------
# === TAG: DISPATCH ===========================================================
# ---------------------------------------------------------------------------
main() {
    local cmd="${1:-start}"
    case "${cmd}" in
        setup)        cmd_setup ;;
        start|run)    cmd_start ;;
        ui)           cmd_ui ;;
        rc|resources) cmd_rc ;;
        regen)        cmd_regen ;;
        doctor|check) cmd_doctor ;;
        clean)        cmd_clean ;;
        help|-h|--help) cmd_help ;;
        *) die "Unknown command: ${cmd}. Try: ./run.sh help" ;;
    esac
}

main "$@"
