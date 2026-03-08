import os
import sys
import re
from typing import List, Set
import argparse

ASM_COMMANDS = {
    "LA", "LB", "LBU", "SB", "LH", "LHU", "SH", "LW", "LWU", "SW", "LD", "SD", "LWL", "LWR", "SWL", "SWR", "LDL", "LDR", "SDL", "SDR", "LL", "LLI", "LUI", "SC", "LLD", "SCD", "LWC1", "SWC1", "LDC1", "SDC1", "LWXC1", "SWXC1", "LDXC1", "SDXC1", "ADDI", "ADDIU", "SLTI", "SLTIU", "ANDI", "ORI", "XORI", "DADDI", "DADDIU", "ADD", "ADDU", "SUB", "SUBU", "DADD", "DADDU", "DSUB", "DSUBU", "SLT", "SLTU", "AND", "OR", "XOR", "NOR", "SLL", "SRL", "SRA", "SLLV", "SRLV", "SRAV", "DSLL", "DSRL", "DSRA", "DSLL32", "DSRL32", "DSRA32", "DSLLV", "DSRLV", "DSRAV", "MULT", "MULTU", "DIV", "DIVU", "DMULT", "DMULTU", "DDIV", "DDIVU", "MFHI", "MTHI", "MFLO", "MTLO", "J", "JAL", "JR", "JALR", "BEQ", "BNE", "BLEZ", "BGTZ", "BNEL", "BLEZL", "BGTZL", "BLTZ", "BGEZ", "BLTZAL", "BGEZAL", "BLTZL", "BGEZL", "BLTZALL", "BGEZALL", "SYSCALL", "BREAK", "TGE", "TGEU", "TLT", "TLTU", "TEQ", "TNE", "TGEI", "TGEIU", "TLTI", "TLTIU", "TEQI", "TNEI", "SYNC", "MOVN", "MOVZ", "PREF", "PREFX", "LWC2", "SWC2", "LDC2", "SDC2", "LWC3", "SWC3", "LDC3", "SDC3", "COP0", "COP1", "COP2", "COP3", "NOP", "DB", "DW", "DH", "writehex", "LI", "BEQL", "MOV", "DIV.D", "MOV.D", "C.LE.D", "BC1F", "C.LT.D", "MTC1", "CVT.D.W", "CACHE", "SUB.D", "ADD.D", "MUL.D", "C.EQ.D", "MFC0", "ABS.S", "ABS.D", "ADD.S", "BC1T", "BC1FL", "BC1TL", "C.F.S", "C.UN.S", "C.EQ.S", "C.UEQ.S", "C.OLT.S", "C.ULT.S", "C.OLE.S", "C.ULE.S", "C.SF.S", "C.NGLE.S", "C.SEQ.S", "C.NGL.S", "C.LT.S", "C.NGE.S", "C.LE.S", "C.NGT.S", "C.F.D", "C.UN.D", "C.UEQ.D", "C.OLT.D", "C.ULT.D", "C.OLE.D", "C.ULE.D", "C.SF.D", "C.NGLE.D", "C.SEQ.D", "C.NGL.D", "C.NGE.D", "C.NGT.D", "CEIL.W.S", "CEIL.W.D", "CEIL.L.S", "CEIL.L.D", "CVT.S.W", "CVT.S.L", "CVT.S.D", "CVT.W.S", "CVT.W.D", "CVT.D.S", "CVT.D.L", "CVT.L.S", "CVT.L.D", "DIV.S", "MOV.S", "FLOOR.L.S", "FLOOR.L.D", "FLOOR.W.S", "FLOOR.W.D", "DMTC1", "MFC1", "DMFC1", "MUL.S", "NEG.S", "NEG.D", "ROUND.L.S", "ROUND.L.D", "SUB.S", "SQRT.S", "SQRT.D", "ROUND.W.S", "ROUND.W.D", "TRUNC.L.S", "TRUNC.L.D", "TRUNC.W.S", "TRUNC.W.D", "BGE", "BLT", "BLE", "BGT", "B", "BAL", "CL", "BEQZ", "BEQZL", "BNEZ", "SUBI", "SUBIU", "BEQI", "BNEI", "BGTI", "BLTI", "BGEI", "BLEI", "VMULF", "VMULU", "VRNDP", "VMULQ", "VMUDL", "VMUDM", "VMUDN", "VMUDH", "VMACF", "VMACU", "VRNDN", "VMACQ", "VMADL", "VMADN", "VMADM", "VMADH", "VADD", "VSUB", "VSUT", "VABS", "VADDC", "VSUBC", "VADDB", "VSUBB", "VACCB", "VSUCB", "VSAD", "VSAC", "VSUM", "VSAW", "VLT", "VEQ", "VNE", "VGE", "VCL", "VCH", "VCR", "VMRG", "VAND", "VNAND", "VOR", "VNOR", "VXOR", "VNXOR", "VRCP", "VRCPL", "VRCPH", "VMOV", "VRSQ", "VRSQL", "VRSQH", "MFC2", "MTC2", "LBV", "LSV", "LLV", "LDV", "LQV", "LRV", "LPV", "LUV", "LHV", "LFV", "LWV", "LTV", "SBV", "SSV", "SLV", "SDV", "SQV", "SRV", "SPV", "SUV", "SHV", "SFV", "SWV", "STV"
}

BRANCH_JUMP_COMMANDS = {
    "J", "JAL", "JR", "JALR", "BEQ", "BNE", "BLEZ", "BGTZ", "BNEL", "BLEZL", "BGTZL", "BLTZ", "BGEZ", "BLTZAL", "BGEZAL", "BLTZL", "BGEZL", "BLTZALL", "BGEZALL", "BEQL", "BC1F", "BC1T", "BC1FL", "BC1TL", "BGE", "BLT", "BLE", "BGT", "B", "BAL", "BEQZ", "BEQZL", "BNEZ", "BEQI", "BNEI", "BGTI", "BLTI", "BGEI", "BLEI"
}

MULTILINE_PSEUDO_COMMANDS = {
    "LI"
}

LABEL_PATTERN = re.compile(r"^(\w+):", re.IGNORECASE)  # Matches labels


class SequentialWarning:
    def __init__(self, file_path: str, line1: int, line2: int, command1: str, command2: str):
        self.file_path = file_path
        self.line1 = line1
        self.line2 = line2
        self.command1 = command1
        self.command2 = command2


class CodeAnalysis:
    def __init__(self):
        self.sequential_branches = []
        self.pseudoinstructions_after_branches = []

    def analyze_file(self, file_path: str):
        with open(file_path, encoding='utf-8') as f:
            prev_command_branch = False
            prev_command = ""
            prev_command_line = -1
            last_valid_command = None

            for line_number, line in enumerate(f, start=1):
                # Remove comments
                line = line.split('#')[0]
                line = line.split("//")[0]
                # Split by ';' and strip whitespace
                commands = [cmd.strip()
                            for cmd in line.split(';') if cmd.strip()]

                for command in commands:
                    if command.split()[0].upper() in ASM_COMMANDS:
                        last_valid_command = command
                        if command.split()[0].upper() in BRANCH_JUMP_COMMANDS:
                            if prev_command_branch:
                                self.sequential_branches.append(
                                    SequentialWarning(file_path, prev_command_line, line_number, prev_command, command))
                            prev_command_branch = True
                            prev_command = command
                            prev_command_line = line_number
                        elif command.split()[0].upper() in MULTILINE_PSEUDO_COMMANDS:
                            if prev_command_branch:
                                self.pseudoinstructions_after_branches.append(
                                    SequentialWarning(file_path, prev_command_line, line_number, prev_command, command))
                            prev_command_branch = False
                        else:
                            prev_command_branch = False
                    else:
                        if not LABEL_PATTERN.match(command):
                            prev_command_branch = False

                        if command.startswith("OS."):
                            last_valid_command = command

            if last_valid_command != None and last_valid_command.split()[0].upper() in BRANCH_JUMP_COMMANDS:
                print("File ended with branch!?")
                print(file_path)

    def print_warnings(self):
        """
        Print all warnings.
        """
        print("===== Sequential Branch commands (ERROR) =====")
        if len(self.sequential_branches) == 0:
            print("No sequential branches found.")
        else:
            for branch in self.sequential_branches:
                print(f"> [{branch.command1.split()[0]} -> {branch.command2.split()[0]}] at {
                    branch.file_path}:{branch.line1}, {branch.file_path}:{branch.line2}")

        print("===== Multiline pseudoinstructions after branch commands (Warning) =====")
        if len(self.pseudoinstructions_after_branches) == 0:
            print("No multiline pseudo instructions found after branches.")
        else:
            for branch in self.pseudoinstructions_after_branches:
                print(f"> [{branch.command1.split()[0]} -> {branch.command2.split()[0]}] at {
                    branch.file_path}:{branch.line1}, {branch.file_path}:{branch.line2}")


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    args = parser.parse_args()

    analysis = CodeAnalysis()

    for root, _, files in os.walk("."):
        for file in files:
            if file.endswith(".asm"):
                analysis.analyze_file(os.path.join(root, file))

    analysis.print_warnings()

    if len(analysis.sequential_branches) > 0:
        sys.exit(1)
