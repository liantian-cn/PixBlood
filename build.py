"""Build the current Pix project for Windows x64.

Run: uv run --no-project --python 3.13 build.py
Requires uv, CPython 3.13 x64 and Visual Studio C++ build tools with a Windows SDK.
Only build/ and dist/<addon name>/ are written; existing project files stay intact.
Distribute the entire dist/<addon name>/ directory, not just its executable.
"""

from __future__ import annotations

import os
from pathlib import Path
import shutil
import struct
import subprocess
import sys
import tomllib
import xml.etree.ElementTree as ET


NUITKA_VERSION = "4.2.2"
ROOT = Path(__file__).resolve().parent


def run(*arguments: str | Path, env: dict[str, str] | None = None) -> None:
    command = [str(argument) for argument in arguments]
    print(f"\n> {subprocess.list2cmdline(command)}", flush=True)
    subprocess.run(command, cwd=ROOT, env=env, check=True)


def checked_path(path: Path, parent: Path) -> Path:
    """Never replace or remove a directory outside its intended parent."""
    resolved = path.resolve()
    if path.is_symlink() or path.is_junction() or not resolved.is_relative_to(parent.resolve()):
        raise RuntimeError(f"Unsafe build path: {path}")
    if resolved == parent.resolve():
        raise RuntimeError(f"Refusing to replace the parent directory: {path}")
    return path


def remove_directory(path: Path, parent: Path) -> None:
    checked_path(path, parent)
    if path.exists():
        shutil.rmtree(path)


def main() -> int:
    if sys.platform != "win32" or sys.version_info[:2] != (3, 13) or struct.calcsize("P") != 8:
        raise RuntimeError("Run with Windows x64 CPython 3.13: uv run --no-project --python 3.13 build.py")
    uv = shutil.which("uv")
    if uv is None:
        raise RuntimeError("uv must be installed and available on PATH.")

    for relative in ("pyproject.toml", "uv.lock", "pix/main.py", "pix/assets/app.ico"):
        if not (ROOT / relative).is_file():
            raise RuntimeError(f"Required project file is missing: {relative}")
    addons = list((ROOT / "pix/lua").glob("*.toc"))
    if len(addons) != 1:
        raise RuntimeError("Expected exactly one pix/lua/*.toc file to identify this project.")
    name = addons[0].stem
    if not name.isascii() or not name.isidentifier():
        raise RuntimeError(f"Invalid addon/executable name: {name}")
    with (ROOT / "pyproject.toml").open("rb") as stream:
        project = tomllib.load(stream)["project"]
    if project["name"].casefold() != name.casefold():
        raise RuntimeError("The project name and Lua addon name do not match.")

    build = checked_path(ROOT / "build", ROOT)
    dist = checked_path(ROOT / "dist", ROOT)
    work = checked_path(build / "nuitka", build)
    environment = checked_path(build / ".venv", build)
    for directory in (build, dist, work):
        directory.mkdir(parents=True, exist_ok=True)

    # Export without changing the lock file or the project's development environment.
    requirements = build / "requirements.txt"
    run(uv, "export", "--locked", "--no-dev", "--no-emit-project", "--no-header", "--quiet",
        "--output-file", requirements)
    python = environment / "Scripts/python.exe"
    if not python.is_file():
        run(uv, "venv", "--python", sys.executable, environment)
    run(python, "-c",
        "import struct, sys; assert sys.version_info[:2] == (3, 13) and struct.calcsize('P') == 8")
    run(uv, "pip", "install", "--python", python, "-r", requirements,
        f"Nuitka=={NUITKA_VERSION}")

    # Import main as a package module so __file__ still locates pix/assets and pix/lua.
    entry = work / f"{name}.py"
    entry.write_text("from pix.main import main\n\nraise SystemExit(main())\n", encoding="utf-8")
    report = work / "compilation-report.xml"
    candidate = checked_path(work / f"{name}.dist", work)
    remove_directory(candidate, work)
    compile_env = os.environ.copy()
    compile_env.pop("PYTHONHOME", None)
    compile_env["PYTHONPATH"] = str(ROOT)
    run(
        python, "-m", "nuitka",
        "--mode=standalone", "--msvc=latest", "--enable-plugin=pyside6",
        "--windows-console-mode=disable", "--windows-uac-admin",
        f"--windows-icon-from-ico={ROOT / 'pix/assets/app.ico'}",
        f"--product-name={name}", f"--file-description={name}",
        f"--product-version={project['version']}",
        f"--output-dir={work}", f"--output-filename={name}.exe",
        f"--include-data-dir={ROOT / 'pix/assets'}=pix/assets",
        f"--include-data-dir={ROOT / 'pix/lua'}=pix/lua",
        f"--force-stdout-spec={{CACHE_DIR}}/{name}.stdout.log",
        f"--force-stderr-spec={{CACHE_DIR}}/{name}.stderr.log",
        "--include-module=pix.main", "--assume-yes-for-downloads",
        f"--report={report}", entry,
        env=compile_env,
    )

    if not (candidate / f"{name}.exe").is_file():
        raise RuntimeError("Nuitka did not produce the expected executable.")
    compiled = {
        module.attrib["name"]
        for module in ET.parse(report).iter("module")
        if module.attrib.get("kind") == "CompiledPythonModule"
    }
    expected = {"pix.main", "pix.ui", "pix.action", "pix.capture", "pix.context",
                "pix.matrix", "pix.keyboard", "pix.rotation"}
    if missing := expected - compiled:
        raise RuntimeError(f"Project modules were not compiled: {', '.join(sorted(missing))}")
    for relative in (Path("pix/assets"), Path("pix/lua")):
        for source in (ROOT / relative).rglob("*"):
            if source.is_file():
                target = candidate / source.relative_to(ROOT)
                if not target.is_file() or source.read_bytes() != target.read_bytes():
                    raise RuntimeError(f"Missing or altered resource: {source.relative_to(ROOT)}")

    # Keep the last release until compilation and resource validation both succeed.
    release = checked_path(dist / name, dist)
    previous = checked_path(build / f"{name}.previous", build)
    remove_directory(previous, build)
    had_release = release.exists()
    if had_release:
        release.rename(previous)
    try:
        candidate.rename(release)
    except OSError:
        if had_release:
            previous.rename(release)
        raise
    remove_directory(previous, build)
    print(f"\nBuilt: {release / (name + '.exe')}", flush=True)
    print(f"Distribute the entire directory: {release}")
    print(f"Compilation report: {report}")
    print(f"Runtime logs: %LOCALAPPDATA%/{name}.stdout.log and {name}.stderr.log")
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except (OSError, RuntimeError, ValueError, subprocess.CalledProcessError, ET.ParseError) as error:
        print(f"\nBuild failed: {error}", file=sys.stderr)
        raise SystemExit(1)
