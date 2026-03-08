'''
This script checks for duplicate definitions of "Character.edit_action_parameters" in .asm files
'''
import os
import re
import sys
import argparse


def find_duplicate_action_parameters(root_dir):
    pattern = re.compile(
        r'Character\.edit_action_parameters\(\s*([^,]+),\s*([^,]+),'
    )
    occurrences = {}
    for subdir, _, files in os.walk(root_dir):
        for file in files:
            if file.endswith('.asm'):
                path = os.path.join(subdir, file)
                with open(path, 'r', encoding='utf-8', errors='ignore') as f:
                    for lineno, line in enumerate(f, 1):
                        match = pattern.search(line)
                        if match:
                            character = match.group(1).strip()
                            action = match.group(2).strip()
                            key = (character, action)
                            if key not in occurrences:
                                occurrences[key] = []
                            occurrences[key].append(
                                (path, lineno, line.strip()))
    duplicates = {k: v for k, v in occurrences.items() if len(v) > 1}
    return duplicates


def main():
    parser = argparse.ArgumentParser(
        description="Check for duplicate Character.edit_action_parameters definitions in .asm files under a src/ subtree."
    )
    parser.add_argument(
        '--src', help='Path to the src directory', default='src'
    )
    args = parser.parse_args()

    duplicates = find_duplicate_action_parameters(args.src)

    if duplicates:
        print("Duplicate action parameter definitions found:")
        for key, entries in duplicates.items():
            print(f"\nCharacter: {key[0]}, Action: {key[1]}")
            for path, lineno, line in entries:
                print(f"  {path}:{lineno}: {line}")
        sys.exit(1)
    else:
        print("No duplicate action parameter definitions found.")
        sys.exit(0)


if __name__ == "__main__":
    main()
