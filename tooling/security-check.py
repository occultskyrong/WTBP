#!/usr/bin/env python3
"""Read-only static safety gate for untrusted Skills and source trees."""

from __future__ import annotations

import argparse
import hashlib
import json
import os
import re
import stat
import sys
from pathlib import Path
from typing import Dict, Iterable, List, Optional, Sequence, Tuple


SCHEMA_VERSION = 1
MAX_FILE_BYTES = 1024 * 1024
MAX_FILES = 10000
MAX_TOTAL_BYTES = 50 * 1024 * 1024
SEVERITY_ORDER = {"critical": 0, "high": 1, "medium": 2, "low": 3, "info": 4}
EXIT_PASS = 0
EXIT_BLOCK = 1
EXIT_REVIEW = 2
EXIT_USAGE = 64

SENSITIVE = re.compile(
    r"(?:~?/(?:[^\s/]+/)*\.ssh/(?:id_[^\s/]+|known_hosts)|"
    r"\.aws/credentials|\.config/gcloud|\.npmrc|\.netrc|\.kube/config|"
    r"(?:^|[^A-Za-z0-9_])(OPENAI_API_KEY|ANTHROPIC_API_KEY|AWS_SECRET_ACCESS_KEY|"
    r"GH_TOKEN|GITHUB_TOKEN|PRIVATE_KEY|SECRET_KEY|ACCESS_TOKEN|PASSWORD)(?:$|[^A-Za-z0-9_])|"
    r"(?:id_rsa|id_ed25519|id_ecdsa|private[_-]?key|secret[_-]?key|api[_-]?key))")
READ_ACTION = re.compile(
    r"\b(?:cat|head|tail|less|more|read|open|readFile(?:Sync)?|read_text|"
    r"getenv|environ|get_generic_password|find-generic-password|copy|cp|"
    r"base64|printenv|env|echo|export)\b|process\.env|os\.environ"
)
NETWORK = re.compile(
    r"\b(?:curl|wget|httpie|nc|netcat|socat|ftp|scp|rsync)\b|"
    r"(?:requests|httpx)\.(?:get|post|put|patch)|axios\.(?:get|post|put|patch)|"
    r"fetch\(|urllib\.(?:request\.)?urlopen|Invoke-(?:WebRequest|RestMethod)|"
    r"http\.request"
)
NETWORK_SINK = re.compile(
    r"\b(?:curl|wget|nc|netcat|socat|scp|rsync)\b[^\n]{0,220}(?:-d\s|--data|--upload-file|--post-file|-T\s)|"
    r"(?:requests|httpx)\.(?:post|put|patch)|axios\.(?:post|put|patch)|fetch\([^\n]{0,160}(?:POST|PUT|PATCH)"
)
PROMPT_INJECTION = re.compile(
    r"(?:ignore|disregard|override|forget)\s+(?:all\s+)?(?:previous|prior|system|safety)|"
    r"(?:忽略|无视|绕过|覆盖)(?:之前|上面|系统|安全)(?:的指令|指示|规则)|"
    r"(?:reveal|print|show|send|upload|read)\s+(?:the\s+)?(?:system prompt|credentials?|secrets?|private keys?)|"
    r"(?:读取|打印|发送|上传)(?:系统提示词|凭据|密钥|私钥)|"
    r"(?:disable|bypass|turn off)\s+(?:security|validation|sandbox)|"
    r"(?:禁用|关闭|绕过)(?:安全|校验|沙箱)"
)
PRIVATE_KEY = re.compile(r"-----BEGIN (?:RSA |EC |OPENSSH |DSA |PGP )?PRIVATE KEY-----")
SECRET_ASSIGNMENT = re.compile(
    r"(?i)(?:password|passwd|secret|token|api[_-]?key|private[_-]?key|access[_-]?key)"
    r"\s*[:=]\s*[\"']?[A-Za-z0-9_./+=:-]{12,}"
)
DANGEROUS_PIPE = re.compile(
    r"\b(?:curl|wget)\b[^\n|]{0,240}\|\s*(?:sh|bash|zsh|fish|python(?:3)?|perl|ruby)\b"
)
DYNAMIC_EXEC = re.compile(
    r"\b(?:eval|exec)\s*\(|\b(?:os\.system|subprocess\.(?:run|Popen|call)|"
    r"child_process\.(?:exec|execFile|spawn)|Runtime\.getRuntime\(\)\.exec|ProcessBuilder)\b"
)
PRIVILEGE = re.compile(
    r"\b(?:sudo|doas|setcap)\b|chmod\s+(?:777|7[0-7]{2})|chown\s+root\b|"
    r"security\s+find-(?:generic|internet)-password|osascript\b|"
    r"launchctl\s+(?:load|bootstrap)|systemctl\s+enable\b"
)
PERSISTENCE = re.compile(
    r"(?:\.git/hooks|hooksPath|(?:pre|post)install|prepare\s*[:=]|launchagents?|"
    r"crontab|/etc/systemd/system|systemctl\s+enable)"
)
OBFUSCATION = re.compile(
    r"base64\s+(?:-d|--decode)|atob\(|Buffer\.from\([^\n]{0,120}base64|"
    r"(?:python|node|ruby|perl)\s+-c"
)
UNSAFE_TLS = re.compile(
    r"(?:verify\s*=\s*False|NODE_TLS_REJECT_UNAUTHORIZED\s*=\s*0|"
    r"\bcurl\b[^\n]*(?:\s-k\b|\s--insecure\b)|--no-verify\b)"
)
WORKFLOW_UNTRUSTED = re.compile(r"(?:pull_request_target|workflow_run)")
WORKFLOW_CONTEXT_RUN = re.compile(
    r"^\s*(?:run|script)\s*:.*\$\{\{\s*github\.event\.[^}]+\}\}"
)
WORKFLOW_WRITE = re.compile(r"^\s*(?:permissions\s*:\s*write-all|contents\s*:\s*write)\s*$")
UNPINNED_ACTION = re.compile(r"^\s*-?\s*uses:\s*[^\s@]+@(?:v?\d+(?:\.\d+){0,2}|main|master|latest)\s*$")
WORKFLOW_SENSITIVE_PERMISSION = re.compile(r"^\s*(?:id-token|actions|packages|pull-requests|security-events|deployments|statuses)\s*:\s*write\s*$")
ARCHIVE_SUFFIXES = (".7z", ".rar", ".tar", ".tar.gz", ".tgz", ".zip", ".jar", ".whl", ".gz", ".bz2", ".xz")


def is_negated(line: str) -> bool:
    return bool(re.search(r"\b(?:do not|don't|never|must not|禁止|不得|不要|请勿)\b", line, re.I))


def relative_path(path: Path, root: Path) -> str:
    try:
        return str(path.relative_to(root)) or "."
    except ValueError:
        return str(path)


def add_finding(
    findings: List[Dict[str, object]],
    severity: str,
    rule: str,
    path: str,
    line: int,
    evidence: str,
) -> None:
    item = {
        "severity": severity,
        "rule": rule,
        "path": path,
        "line": line,
        "evidence": evidence,
    }
    key = tuple(item.values())
    if not any(tuple(existing.values()) == key for existing in findings):
        findings.append(item)


def is_binary(data: bytes) -> bool:
    return b"\x00" in data[:8192]


def iter_files(root: Path) -> Iterable[Path]:
    for current, dirs, files in os.walk(root, followlinks=False):
        retained_dirs = []
        for name in sorted(dirs):
            path = Path(current) / name
            if name == ".git":
                continue
            if path.is_symlink():
                yield path
                continue
            retained_dirs.append(name)
        dirs[:] = retained_dirs
        for name in sorted(files):
            yield Path(current) / name
    hooks = root / ".git" / "hooks"
    if hooks.is_dir():
        for current, dirs, files in os.walk(hooks, followlinks=False):
            for name in sorted(files):
                yield Path(current) / name


def scan_file(path: Path, root: Path, findings: List[Dict[str, object]]) -> None:
    display_path = relative_path(path, root)
    try:
        if path.is_symlink():
            target = path.resolve(strict=False)
            if root not in target.parents and target != root:
                add_finding(findings, "high", "symlink-outside-target", display_path, 1, "符号链接指向候选目录之外")
            else:
                add_finding(findings, "high", "unverified-symlink", display_path, 1, "符号链接内容未跟随读取，无法确认其实际目标")
            return
        mode = path.stat().st_mode
        if not stat.S_ISREG(mode):
            add_finding(findings, "high", "unverified-special-file", display_path, 1, "特殊文件未读取或执行，无法确认其行为")
            return
        size = path.stat().st_size
        if size > MAX_FILE_BYTES:
            add_finding(findings, "high", "unverified-large-file", display_path, 1, "文件超过静态扫描大小上限，内容未完整检查")
            return
        data = path.read_bytes()
    except OSError as exc:
        add_finding(findings, "medium", "unreadable-file", display_path, 1, f"文件无法读取：{exc.__class__.__name__}")
        return

    if is_binary(data):
        add_finding(findings, "high", "unverified-binary", display_path, 1, "二进制内容未执行或反编译，无法由文本规则确认")
        return
    text = data.decode("utf-8", errors="replace")
    lines = text.splitlines() or [""]
    lower_path = display_path.lower()
    if lower_path.endswith(ARCHIVE_SUFFIXES):
        add_finding(findings, "high", "unverified-archive", display_path, 1, "压缩或打包内容未递归展开，需隔离后单独检查")

    credential_lines: List[int] = []
    network_lines: List[int] = []
    dynamic_lines: List[int] = []
    for number, line in enumerate(lines, start=1):
        if PRIVATE_KEY.search(line):
            add_finding(findings, "critical", "private-key-material", display_path, number, "发现私钥材料标记；输出已省略具体内容")
        if SECRET_ASSIGNMENT.search(line) and not is_negated(line):
            add_finding(findings, "high", "embedded-secret", display_path, number, "发现疑似硬编码凭据；输出已省略具体内容")
        if SENSITIVE.search(line) and READ_ACTION.search(line) and not is_negated(line):
            credential_lines.append(number)
            add_finding(findings, "high", "credential-access", display_path, number, "代码读取凭据、密钥或敏感环境变量")
        if NETWORK.search(line):
            network_lines.append(number)
        if NETWORK_SINK.search(line) and SENSITIVE.search(line) and not is_negated(line):
            add_finding(findings, "critical", "credential-exfiltration", display_path, number, "同一操作同时触及敏感材料与网络上传入口")
        if DANGEROUS_PIPE.search(line):
            add_finding(findings, "critical", "download-and-execute", display_path, number, "远程内容直接通过管道交给解释器执行")
        if DYNAMIC_EXEC.search(line) and not is_negated(line):
            dynamic_lines.append(number)
            add_finding(findings, "medium", "dynamic-execution", display_path, number, "发现动态执行或子进程入口，需核对输入是否可信")
        if PRIVILEGE.search(line) and not is_negated(line):
            add_finding(findings, "high", "privilege-escalation", display_path, number, "发现提权、系统密钥链或高权限持久化操作")
        if PERSISTENCE.search(line) and not is_negated(line):
            add_finding(findings, "high", "persistence-hook", display_path, number, "发现安装钩子、Git Hook 或系统持久化入口")
        if PROMPT_INJECTION.search(line) and not is_negated(line):
            add_finding(findings, "high", "prompt-injection", display_path, number, "发现要求忽略安全边界或索取敏感材料的指令")
        if OBFUSCATION.search(line) and DYNAMIC_EXEC.search(line):
            add_finding(findings, "high", "obfuscated-execution", display_path, number, "发现编码/解码与动态执行组合")
        if UNSAFE_TLS.search(line) and not is_negated(line):
            add_finding(findings, "medium", "security-bypass", display_path, number, "发现关闭 TLS、校验或 Git 完整性检查的参数")
        if lower_path.startswith(".github/workflows/"):
            if WORKFLOW_CONTEXT_RUN.search(line):
                add_finding(findings, "high", "workflow-script-injection", display_path, number, "工作流把不可信 GitHub 上下文直接插入脚本")
            if WORKFLOW_WRITE.search(line):
                severity = "high" if "write-all" in line else "medium"
                add_finding(findings, severity, "workflow-token-permission", display_path, number, "工作流声明了超出只读默认值的 Token 权限")
            if WORKFLOW_SENSITIVE_PERMISSION.search(line):
                add_finding(findings, "medium", "workflow-sensitive-permission", display_path, number, "工作流声明了敏感写权限，需确认是否最小化")
            if UNPINNED_ACTION.search(line):
                add_finding(findings, "medium", "unpinned-action", display_path, number, "第三方 Action 未固定到完整提交 SHA")
            if re.search(r"^\s*runs-on:\s*self-hosted\b", line):
                add_finding(findings, "high", "self-hosted-runner", display_path, number, "工作流可在维护者环境执行不可信候选代码")

    for credential_line in credential_lines:
        if any(abs(credential_line - network_line) <= 20 for network_line in network_lines):
            add_finding(findings, "critical", "credential-network-correlation", display_path, credential_line, "敏感材料读取与网络访问在同一文件的相邻范围内出现")
    if dynamic_lines and network_lines:
        add_finding(findings, "high", "downloaded-dynamic-execution", display_path, dynamic_lines[0], "网络访问与动态执行在同一文件中组合出现")
    if WORKFLOW_UNTRUSTED.search(text) and re.search(r"actions/checkout[^\n]*(?:head\.sha|pull_request\.head|github\.event\.pull_request)", text):
        add_finding(findings, "critical", "workflow-untrusted-checkout", display_path, 1, "高权限工作流检出不可信 Pull Request 内容")
    if lower_path.endswith(("package.json", "package.yaml", "package.yml")):
        for number, line in enumerate(lines, start=1):
            if re.search(r"[\"'](?:preinstall|install|postinstall|prepare)[\"']\s*:", line):
                add_finding(findings, "high", "package-lifecycle-script", display_path, number, "包管理器安装阶段会自动执行脚本")


def scan_target(target: Path) -> Tuple[Path, List[Dict[str, object]], str]:
    if not target.exists():
        raise ValueError("目标不存在")
    original_target = target.absolute()
    resolved = target.resolve()
    if not resolved.is_file() and not resolved.is_dir():
        raise ValueError("目标必须是文件或目录")
    root = resolved if resolved.is_dir() else resolved.parent
    findings: List[Dict[str, object]] = []
    snapshot = hashlib.sha256()
    if original_target.is_symlink():
        add_finding(findings, "high", "unverified-root-symlink", str(original_target.name), 1, "扫描目标本身是符号链接，来源边界未固定")
    if resolved.is_file():
        snapshot.update(resolved.name.encode("utf-8", errors="replace"))
        snapshot.update(resolved.read_bytes())
        scan_file(resolved, root, findings)
    else:
        file_count = 0
        total_bytes = 0
        for path in iter_files(resolved):
            file_count += 1
            if file_count > MAX_FILES:
                add_finding(findings, "high", "unverified-file-budget", ".", 1, "文件数量超过静态扫描上限，剩余内容未检查")
                break
            try:
                entry_size = path.lstat().st_size
            except OSError:
                entry_size = 0
            total_bytes += entry_size
            if total_bytes > MAX_TOTAL_BYTES:
                add_finding(findings, "high", "unverified-byte-budget", ".", 1, "候选总大小超过静态扫描上限，剩余内容未检查")
                break
            snapshot.update(relative_path(path, resolved).encode("utf-8", errors="replace"))
            try:
                snapshot.update(path.read_bytes())
            except OSError:
                snapshot.update(b"<unreadable>")
            scan_file(path, resolved, findings)
        if file_count == 0:
            add_finding(findings, "high", "empty-target", ".", 1, "目标没有可检查的文件")
    findings.sort(key=lambda item: (SEVERITY_ORDER[str(item["severity"])], str(item["path"]), int(item["line"]), str(item["rule"])))
    return resolved, findings, snapshot.hexdigest()


def build_report(target: Path, findings: Sequence[Dict[str, object]], snapshot_sha256: str) -> Dict[str, object]:
    counts = {severity: sum(1 for item in findings if item["severity"] == severity) for severity in SEVERITY_ORDER}
    if counts["critical"] or counts["high"]:
        status = "block"
    elif counts["medium"]:
        status = "review"
    else:
        status = "pass"
    return {
        "schemaVersion": SCHEMA_VERSION,
        "tool": "wtbp-security-check",
        "scannerVersion": "0.1.0",
        "policyVersion": "1",
        "target": target.name or ".",
        "snapshotSha256": snapshot_sha256,
        "status": status,
        "counts": counts,
        "staticOnly": True,
        "executionPerformed": False,
        "networkAccessPerformed": False,
        "findings": list(findings),
        "boundary": "静态规则不能证明不存在未知漏洞；通过后仍需核对来源、版本、依赖和运行时权限。",
    }


def text_report(report: Dict[str, object]) -> str:
    status = str(report["status"])
    labels = {"pass": "通过", "review": "需人工复核", "block": "阻断"}
    counts = report["counts"]
    lines = [
        f"WTBP 安全校验：{labels[status]}",
        f"目标：{report['target']}",
        f"发现：critical={counts['critical']} high={counts['high']} medium={counts['medium']} low={counts['low']}",
        "执行第三方代码：否；访问外部网络：否；输出证据：已脱敏",
    ]
    findings = report["findings"]
    if findings:
        lines.append("发现明细：")
        for item in findings:
            lines.append(
                f"- [{str(item['severity']).upper()}] {item['rule']} "
                f"{item['path']}:{item['line']}：{item['evidence']}"
            )
    else:
        lines.append("发现明细：无")
    lines.append(f"边界：{report['boundary']}")
    return "\n".join(lines)


def parse_args(argv: Optional[Sequence[str]] = None) -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="对 Skill 或项目目录执行默认只读、无网络、不会运行候选代码的静态安全校验。"
    )
    parser.add_argument("target", help="要检查的本地文件或目录")
    parser.add_argument("--format", choices=("text", "json"), default="text", dest="output_format")
    return parser.parse_args(argv)


def main(argv: Optional[Sequence[str]] = None) -> int:
    try:
        args = parse_args(argv)
        target, findings, snapshot_sha256 = scan_target(Path(args.target))
        report = build_report(target, findings, snapshot_sha256)
    except (ValueError, OSError) as exc:
        print(f"WTBP 安全校验失败：{exc}", file=sys.stderr)
        return EXIT_USAGE
    if args.output_format == "json":
        print(json.dumps(report, ensure_ascii=False, indent=2))
    else:
        print(text_report(report))
    return EXIT_BLOCK if report["status"] == "block" else EXIT_REVIEW if report["status"] == "review" else EXIT_PASS


if __name__ == "__main__":
    raise SystemExit(main())
