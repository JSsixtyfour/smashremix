import re
import os
from typing import List, Set
import argparse

ASM_COMMANDS = {
    # ...existing ASM_COMMANDS...
}

BRANCH_JUMP_COMMANDS = {
    # ...existing BRANCH_JUMP_COMMANDS...
}

# Example assembly line patterns
# Matches jump to hex address
JUMP_PATTERN = re.compile(r"\bj\s+0x([0-9A-Fa-f]+)", re.IGNORECASE)
NOP_PATTERN = re.compile(r"\bnop\b", re.IGNORECASE)  # Matches NOP instructions
LABEL_PATTERN = re.compile(r"^(\w+):", re.IGNORECASE)  # Matches labels
PATCH_START_PATTERN = re.compile(
    r"OS\.patch_start\(\s*0x([0-9A-Fa-f]+)\s*,\s*0x([0-9A-Fa-f]+)\s*\)", re.IGNORECASE)
PATCH_END_PATTERN = re.compile(r"OS\.patch_end\(\s*\)", re.IGNORECASE)
# Matches branch instructions
BRANCH_PATTERN = re.compile(r"\bb(?:eq|ne|lt|le|gt|ge)\b", re.IGNORECASE)


class Jump:
    def __init__(self, address: int, file_path: str, line_number: int, runtime_address: int):
        self.address = address
        self.file_path = file_path
        self.line_number = line_number
        self.runtime_address = runtime_address


class Patch:
    def __init__(self, rom_address: int, runtime_address: int, file_path: str, line_number: int):
        self.rom_address = rom_address
        self.runtime_address = runtime_address
        self.file_path = file_path
        self.line_number = line_number
        self.size = 0
        self.jumps = []


class CodeAnalysis:
    def __init__(self):
        self.patches = []
        self.labels = set()
        self.outside_jumps = []
        self.jumps = set()

    def load_jump_addresses(self, file_path: str):
        jump_addresses = set()
        with open(file_path, encoding='utf-8') as f:
            for line in f:
                address = int(line.strip(), 16)
                jump_addresses.add(address)
        self.jumps = jump_addresses

    def load_log(self, log_file: str):
        patch_start_pattern = re.compile(
            r"OS\.patch_start origin 0x([0-9A-Fa-f]+) pc 0x([0-9A-Fa-f]+)")
        patch_end_pattern = re.compile(
            r"OS\.patch_end origin 0x([0-9A-Fa-f]+) pc 0x([0-9A-Fa-f]+)")

        patch_stack = []

        with open(log_file, encoding='utf-8') as f:
            for line in f:
                if match := patch_start_pattern.match(line):
                    rom_address = int(match.group(1), 16)
                    runtime_address = int(match.group(2), 16)
                    patch = Patch(rom_address, runtime_address, log_file, 0)
                    patch_stack.append(patch)
                elif match := patch_end_pattern.match(line):
                    if patch_stack:
                        patch = patch_stack.pop()
                        patch.size = int(match.group(1), 16) - \
                            patch.rom_address
                        self.patches.append(patch)

    def analyze_file(self, file_path: str):
        with open(file_path, encoding='utf-8') as f:
            for line_number, line in enumerate(f, start=1):
                self.analyze_line(line, file_path, line_number)

    def analyze_line(self, line: str, file_path: str, line_number: int):
        # Remove comments
        line = line.split('#')[0]
        # Split by ';' and strip whitespace
        commands = [cmd.strip() for cmd in line.split(';') if cmd.strip()]

        for command in commands:
            if match := LABEL_PATTERN.match(command):
                label = match.group(1)
                self.labels.add(label)
            elif match := PATCH_START_PATTERN.match(command):
                rom_address = int(match.group(1), 16)
                runtime_address = int(match.group(2), 16)
                # Find the respective patch and update the filename
                for patch in self.patches:
                    if patch.rom_address == rom_address:
                        patch.file_path = file_path
                        patch.line_number = line_number
                        break

    def check_jump_addresses(self):
        """
        Check if there's any patch that starts (runtime address) at the slot right after a jump address.
        """
        for jump in self.jumps:
            for patch in self.patches:
                if patch.runtime_address == jump+4:
                    print(f"Warning: Patch starting at 0x{patch.runtime_address:08X} (ends at 0x{patch.runtime_address + patch.size:08X}) in file {patch.file_path}:{patch.line_number} "
                          f"starts right after a jump address at 0x{jump:08X}.")

    def check_patch_overlaps(self):
        """
        Check if patches overlap each other using the ROM address.
        """
        print("== Overlapping Patches ==")
        for i, patch in enumerate(self.patches):
            patch_end_address = patch.rom_address + patch.size
            for j, other_patch in enumerate(self.patches):
                if i >= j:
                    continue
                other_patch_end_address = other_patch.rom_address + other_patch.size
                if (patch.rom_address < other_patch_end_address and
                        patch_end_address > other_patch.rom_address):
                    print(f"> Conflict: Patch starting at 0x{patch.rom_address:08X} (ends at 0x{patch_end_address:08X}) in file {patch.file_path}:{patch.line_number} "
                          f"overlaps with patch starting at 0x{other_patch.rom_address:08X} (ends at 0x{other_patch_end_address:08X}) in file {other_patch.file_path}:{other_patch.line_number}.")


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--logfile", type=str, default="output.log")
    args = parser.parse_args()

    if not os.path.exists(args.logfile):
        print("Error: Log file not found. You must build the project using 'patch.bat > output.log' to generate the log file.")
        exit(1)

    analysis = CodeAnalysis()

    analysis.load_log(args.logfile)

    for root, _, files in os.walk("."):
        for file in files:
            if file.endswith(".asm"):
                analysis.analyze_file(os.path.join(root, file))

    analysis.load_jump_addresses(os.path.join(
        os.path.dirname(__file__), "jump_addresses.txt"))

    print("Statistics:")
    print(f"Number of jumps: {len(analysis.jumps)}")
    print(f"Number of labels: {len(analysis.labels)}")
    print(f"Number of patches: {len(analysis.patches)}")

    # analysis.check_jump_addresses()
    analysis.check_patch_overlaps()
