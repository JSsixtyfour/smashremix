import re
import os
import struct
import math
from collections import defaultdict
import csv
import json
import pandas as pd
from SSB import SSBtbl, N64, fetch, NALE, NALEnum, ReplaceData, process, FinishROM, tblentry, VPK
import tempfile
import argparse
import platform
import subprocess

# Offset to each character's structs pointer
character_struct_offsets = {
    "MARIO": "0x93010",
    "FOX": "0x94EF4",
    "DK": "0x9648C",
    "SAMUS": "0x98478",
    "LUIGI": "0x998A0",
    "LINK": "0x9AD20",
    "YOSHI": "0x9C1D0",
    "CAPTAIN": "0x9D698",
    "KIRBY": "0x9EE80",
    "PIKACHU": "0xA04E4",
    "JIGGLYPUFF": "0xA197C",
    "NESS": "0xA2EA0",
    "BOSS": "0xA447C",
    "METAL": "0x93A20",
}

main_files = {
    "MARIO": 0xCB,
    "FOX": 0xD1,
    "DK": 0xD5,
    "SAMUS": 0xD9,
    "LUIGI": 0xDD,
    "LINK": 0xE1,
    "YOSHI": 0xF7,
    "CAPTAIN": 0xEC,
    "KIRBY": 0xE5,
    "PIKACHU": 0xF3,
    "JIGGLYPUFF": 0xE9,
    "NESS": 0xEF,
    "BOSS": 0xFA,
    "METAL": 0xCE,
}

character_files = {
    "MARIO": 0x128,
    "FOX": 0x139,
    "DK": 0x13D,
    "SAMUS": 0x140,
    "LUIGI": 0x143,
    "LINK": 0x144,
    "YOSHI": 0x152,
    "CAPTAIN": 0x14C,
    "KIRBY": 0x148,
    "PIKACHU": 0x155,
    "JIGGLYPUFF": 0x14A,
    "NESS": 0x14F,
    "BOSS": 0x158,
    "METAL": 0x12C,
}

shield_poses = {
    "MARIO": 0x012A,
    "METAL": 0x012A,
    "FOX": 0x013A,
    "DONKEY": 0x013E,
    "SAMUS": 0x0142,
    "LUIGI": 0x012A,
    "LINK": 0x0147,
    "KIRBY": 0x0149,
    "JIGGLYPUFF": 0x014B,
    "CAPTAIN": 0x014E,
    "NESS": 0x0151,
    "PIKACHU": 0x0157,
    "YOSHI": 0x0154
}


def run_windows_command(command: str):
    if platform.system() == "Linux":
        command = 'wine '+command

    result = subprocess.run(
        command.split(" "),
        capture_output=True,
        text=True
    )
    return result


def parse_file_definitions():
    # Parse files from src/File.asm
    files = {}
    pattern = r'constant\s+(\w+)\((0x[0-9A-Fa-f]+)\)'

    with open('src/File.asm', 'r', encoding='utf-8') as f:
        for line in f:
            if 'constant' in line:
                match = re.search(pattern, line)
                if match:
                    name, value = match.groups()
                    files[name] = int(value, 16)

    return files


def parse_character_definitions():
    # Parse characters from src/Character.asm
    characters = {}
    pattern = r'define_character\((.*?)\)'

    with open('src/Character.asm', 'r', encoding='utf-8') as f:
        for line in f:
            # Skip comments or macro definitions
            if line.strip().startswith('//') or line.strip().startswith('macro'):
                continue
            if 'define_character' in line:
                match = re.search(pattern, line)
                if match:
                    try:
                        params = [p.strip() for p in match.group(1).split(',')]

                        characters[params[0]] = {
                            'name': params[0],
                            'parent': params[1],
                            'file_main': params[2],
                            'file_2': params[3],
                            'file_3': params[4],
                            'file_character': params[5],
                            'file_shield': params[6],
                            'file_6': params[7],
                            'file_7': params[8],
                            'file_8': params[9],
                            'file_9': params[10],
                            'attrib_offset': params[11],
                            'add_actions': params[12]
                        }
                    except:
                        pass
    return characters


def parse_actions():
    # Parse actions from src/Action.asm
    actions = {}
    pattern = r'constant\s+(\w+)\((0x[0-9A-Fa-f]+)\)'

    with open('src/Action.asm', 'r', encoding='utf-8') as f:
        for line in f:
            match = re.search(pattern, line)
            if match:
                name, value = match.groups()
                actions[name] = int(value, 16)

    return actions


FILES = parse_file_definitions()
CHARACTERS = parse_character_definitions()
ACTIONS = parse_actions()


class EditableROMGenerator:
    def __init__(self, args):
        self.args = args

        self.temp_dir = tempfile.TemporaryDirectory()
        self.rom = N64(open(args.rom, "rb").read())
        self.entries = SSBtbl.fromROM(self.rom)

        if not args.character in CHARACTERS:
            raise ValueError(f"Character {args.character} not found!")

        self.character = CHARACTERS[args.character]

    def extract_file(self, file_id, path=None):
        if path is None:
            path = f"{self.temp_dir.name}/{file_id:04X}.bin"
        print(f"Extracting file {file_id:04X} from ROM")
        with open(f"{path}", "wb") as f:
            f.write(self.entries[int(file_id)].extract("data"))

    def cleanup(self):
        self.temp_dir.cleanup()

    def get_character_animation_definitions(self):
        animation_entries = []

        for root, _, files in os.walk('src'):
            for file in files:
                if file.endswith('.asm'):
                    with open(os.path.join(root, file), 'r', encoding='utf-8') as f:
                        lines = [
                            line for line in f if not line.strip().startswith('//')]
                        content = ''.join(lines)

                        # Look for both edit and add action parameter patterns
                        patterns = [
                            rf'Character\.(edit_action_parameters)\(\s*{self.character["name"]}\s*,\s*([^,]+),\s*File\.([^,]+).*?,.*?(0x[0-9A-Fa-f]+|\-1|\d+)\)',
                            # rf'Character\.(add_new_action_params)\(\s*{self.character["name"]}\s*,\s*([^,]+),.*?File\.([^,]+).*?,\s*(0x[0-9A-Fa-f]+|\-1|\d+)\)',
                            rf'Character\.(edit_menu_action_parameters)\(\s*{self.character["name"]}\s*,\s*([^,]+),.*?File\.([^,]+).*?,\s*(0x[0-9A-Fa-f]+|\-1|\d+)\)'
                        ]

                        for pattern in patterns:
                            matches = re.finditer(
                                pattern, content, re.MULTILINE)
                            for match in matches:
                                func, action_name, file_name, flags = match.groups()

                                print(func, action_name, file_name, flags)

                                if file_name != '-1':
                                    animation_entries.append((
                                        file_name,
                                        action_name.split(".")[-1],
                                        int(flags, 16) if flags != '-1' else -1,
                                        func
                                    ))

        return animation_entries

    def get_action_animation_file(self, action_id, function_used):
        animation_file_id = None

        with open(f"{self.args.vanilla}", "rb") as rom:
            if function_used == "edit_action_parameters":
                SHARED_ACTION_ARRAY = 0xA45D8
                PARENT_ACTION_STRUCT = SHARED_ACTION_ARRAY + action_id * 0x14
                rom.seek(PARENT_ACTION_STRUCT)
                param_read = int.from_bytes(
                    rom.read(2), byteorder='big')
                param_offset = (param_read >> 6)

                param_array = int(
                    character_struct_offsets[self.character['parent']], 16) + 0x64
                rom.seek(param_array)
                param_array_origin = int.from_bytes(
                    rom.read(4), byteorder='big')-0x80084800

                action_struct_address = param_array_origin + param_offset * 0xC

                rom.seek(action_struct_address)
                animation_file_id = int.from_bytes(
                    rom.read(4), byteorder='big')
            elif function_used == "edit_menu_action_parameters":
                menu_array = int(
                    character_struct_offsets[self.character['parent']], 16) + 0x68
                rom.seek(menu_array)
                menu_array_origin = int.from_bytes(
                    rom.read(4), byteorder='big')-0x80288A20
                action_struct_address = menu_array_origin + action_id * 0xC

                rom.seek(action_struct_address)
                animation_file_id = int.from_bytes(
                    rom.read(4), byteorder='big')

        return animation_file_id

    def change_action_flags(self, action_id, flags, function_used):
        animation_file_id = None

        with open(f"{self.args.output}", "r+b") as rom:
            if function_used == "edit_action_parameters":
                SHARED_ACTION_ARRAY = 0xA45D8
                PARENT_ACTION_STRUCT = SHARED_ACTION_ARRAY + action_id * 0x14
                rom.seek(PARENT_ACTION_STRUCT)
                param_read = int.from_bytes(
                    rom.read(2), byteorder='big')
                param_offset = (param_read >> 6)

                param_array = int(
                    character_struct_offsets[self.character['parent']], 16) + 0x64
                rom.seek(param_array)
                param_array_origin = int.from_bytes(
                    rom.read(4), byteorder='big')-0x80084800
                action_struct_address = param_array_origin + param_offset * 0xC

            elif function_used == "edit_menu_action_parameters":
                menu_array = int(
                    character_struct_offsets[self.character['parent']], 16) + 0x68
                rom.seek(menu_array)
                menu_array_origin = int.from_bytes(
                    rom.read(4), byteorder='big')-0x80288A20
                action_struct_address = menu_array_origin + action_id * 0xC

            flags_bytes = flags.to_bytes(4, byteorder='big')
            rom.seek(action_struct_address+0x8)
            rom.write(flags_bytes)

            print(
                f"Setting action type {function_used} ID: {action_id:02X}, Flags: {flags:08X}")

    def create_rom(self):
        print(self.character)

        main_file = FILES[
            self.character["file_main"].split("File.")[1]
        ]
        character_file = FILES[
            self.character["file_character"].split("File.")[1]
        ]

        animation_files = self.get_character_animation_definitions()
        print(animation_files)

        with open(f'{self.temp_dir.name}/inject_files.csv', 'w', encoding='utf-8') as f:
            f.write(
                "Mode,FileNumberHex,NewFilePath,Compressed,InternalFileTableOffsetBytes,InternalFileResourceOffsetBytes,ReqFilesFile,CompressionLevel\n"
            )

            shield_pose_remix = self.character["file_shield"]

            # Convert shield pose value to file ID if needed
            if isinstance(shield_pose_remix, str) and shield_pose_remix.startswith('File.'):
                # In case it's a imported file, we'll overwrite the vanilla shield pose with it
                print("Replace shield pose")

                shield_pose_remix = FILES[shield_pose_remix.split('File.')[1]]
                self.extract_file(shield_pose_remix)

                entry = self.entries[shield_pose_remix]

                table_offset = (entry.tbl or 0)
                resource_offset = (
                    entry.res or 0) if entry.res != None else 0x3FFFC

                f.write(
                    f"MODIFY,{shield_poses[self.character['parent']]:04X},"
                    f"{self.temp_dir.name}/{shield_pose_remix:04X}.bin,"
                    f"{1},"
                    f"{table_offset:04X},"
                    f"{resource_offset:04X},"
                    f","
                    f"2\n"
                )
                print(
                    f"MODIFY,{shield_poses[self.character['parent']]:04X},"
                    f"{self.temp_dir.name}/{shield_pose_remix:04X}.bin,"
                    f"{1},"
                    f"{table_offset:04X},"
                    f"{resource_offset:04X},"
                    f","
                    f"2\n"
                )
            else:
                # Character uses some vanilla shield pose
                shield_pose_remix = int(shield_pose_remix, 16)

            # Replace main and character files, update reqlists
            for (remix_file, original_file, compressed) in [
                [
                    f"{main_file:04X}",
                    f"{main_files[self.character['parent']]:04X}",
                    "1"
                ],
                [
                    f"{character_file:04X}",
                    f"{character_files[self.character['parent']]:04X}",
                    "0"
                ]
            ]:
                self.extract_file(int(remix_file, 16))

                entry = self.entries[int(remix_file, 16)]

                with open(f"{self.temp_dir.name}/{remix_file}.txt", "w", encoding='utf-8') as reqlist:
                    for i in range(0, (len(entry.idx) >> 1)*2, 2):
                        file_id = int.from_bytes(entry.idx[i:i+2])

                        if file_id == character_file:
                            file_id = character_files[self.character['parent']]

                        if file_id == shield_pose_remix:
                            file_id = shield_poses[self.character['parent']]

                        # If the file ID is bigger than the last file in vanilla, this would make the game crash
                        # instead, assign the character file
                        if file_id > 0x853:
                            file_id = character_files[self.character['parent']]

                        reqlist.write(
                            f"{file_id:04X}\n")

                        print(f"{file_id:04X}")
                    reqlist.write("END OF REQ LIST")

                table_offset = (entry.tbl or 0)
                resource_offset = (
                    entry.res or 0) if entry.res != None else 0x3FFFC

                f.write(
                    f"MODIFY,{original_file},"
                    f"{self.temp_dir.name}/{remix_file}.bin,"
                    f"{compressed},"
                    f"{table_offset:04X},"
                    f"{resource_offset:04X},"
                    f"{self.temp_dir.name}/{remix_file}.txt,"
                    f"2\n"
                )

            # Overwrite animations
            for (file_name, action_name, flags, func) in animation_files:
                try:
                    self.extract_file(FILES[file_name])

                    action_id = ACTIONS[action_name] if action_name in ACTIONS else int(
                        action_name, 16)

                    if action_id >= 0xDC:
                        print("skip")
                        continue

                    action_file = self.get_action_animation_file(
                        action_id, func)

                    if action_file is not None and action_file != 0:
                        f.write(
                            f"MODIFY,{action_file:04X},"
                            f"{self.temp_dir.name}/{FILES[file_name]:04X}.bin,"
                            f"{0},"  # if func == 'edit_action_parameters' else 0
                            # Exceptions: ShieldOn and ShieldOff
                            f"{'0000' if action_id not in [0x98, 0x9A] else '0004'},"
                            f"3FFFC,"
                            f","
                            f"2\n"
                        )

                        print(
                            f"MODIFY,{action_file:04X},"
                            f"{self.temp_dir.name}/{FILES[file_name]:04X}.bin,"
                            f"{0},"  # if func == 'edit_action_parameters' else 0
                            # Exceptions: ShieldOn and ShieldOff
                            f"{'0000' if action_id not in [0x98, 0x9A] else '0004'},"
                            f"3FFFC,"
                            f","
                            f"2\n"
                        )
                except:
                    print(
                        f"Couldn't replace {func}, {file_name}, {action_name}, {flags}")

        append = run_windows_command(
            f'build/SSBFileInjector.exe csv={self.temp_dir.name}/inject_files.csv inputROM={self.args.vanilla} outputROM=../{self.args.output}'
        )

        print(append.stdout)
        print(append.stderr)

        # Update attribute offsets
        with open(f"{self.args.output}", "r+b") as rom:
            attrib_offset = int(
                character_struct_offsets[self.character['parent']], 16)
            rom.seek(attrib_offset + 0x60)
            rom.write(struct.pack(
                '>I', int(self.character['attrib_offset'], 16)))

        # Unlock all characters
        # At 0x147028, write 0x2408FFFF
        with open(f"{self.args.output}", "r+b") as rom:
            rom.seek(0x147028)
            rom.write(bytes.fromhex("2408FFFF"))

        # Update animation flags
        for (file_name, action_name, flags, func) in animation_files:
            try:
                action_id = ACTIONS[action_name] if action_name in ACTIONS else int(
                    action_name, 16)

                if action_id >= 0xDC:
                    print("skip")
                    continue

                if flags != -1:
                    self.change_action_flags(action_id, flags, func)
            except:
                print(
                    f"Couldn't update flag {file_name}, {action_name}, {flags}")

        # Fix crc
        crcfix = run_windows_command(
            f"assembler/rn64crc.exe -u {self.args.output}"
        )

        print(crcfix.stdout)
        print(crcfix.stderr)

        animation_files = self.get_character_animation_definitions()
        os.makedirs("animations", exist_ok=True)
        for animation_file in animation_files:
            filename = f"{animation_file[0]}({animation_file[1]})"
            if animation_file[2] != -1:
                filename += f"[0x{animation_file[2]:08X}]"
            self.extract_file(
                FILES[animation_file[0]], f"animations/{filename}.bin")
            print(filename)


def main():
    parser = argparse.ArgumentParser(
        description="Generates a vanilla ROM with a Remix character injected over their base character for editing.")
    parser.add_argument(
        '--character', help='Smash Remix Character ID', required=True, choices=list(CHARACTERS.keys()))
    parser.add_argument('--rom', help='Path to Remix\'s original.z64 ROM file or Remix patched ROM',
                        default='roms/original.z64')
    parser.add_argument('--vanilla', help='Path to the vanilla Smash 64 ROM file',
                        default='roms/ssb.rom')
    parser.add_argument('--output', default='editable_rom.z64',
                        help='Output ROM file path')
    args = parser.parse_args()

    ergen = EditableROMGenerator(args)
    try:
        ergen.create_rom()
    finally:
        ergen.cleanup()


if __name__ == "__main__":
    main()
