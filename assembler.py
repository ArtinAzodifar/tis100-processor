# نگاشت رجیسترها و پورت‌ها به کدهای ۴ بیتی
OPERANDS = {
    "NIL": "0000", "ACC": "0001", "BAK": "0010",
    "UP": "0011", "DOWN": "0100", "LEFT": "0101",
    "RIGHT": "0110", "ANY": "0111", "LAST": "1000"
}

# نگاشت دستورات به Opcodeهای ۴ بیتی
OPCODES = {
    "MOV": "0001", "ADD": "0010", "SUB": "0011",
    "NEG": "0100", "SAV": "0101", "SWP": "0110",
    "JMP": "0111", "JEZ": "1000", "JNZ": "1001",
    "JGZ": "1010", "JLZ": "1011", "JRO": "1100",
    "NOP": "0010"
}


def to_11bit_binary(value):
    """تبدیل عدد صحیح به رشته باینری ۱۱ بیتی با علامت (مکمل دو)"""
    if value < 0:
        value = (1 << 11) + value
    return f"{value & 0x7FF:011b}"


def assemble_tis100_with_labels(asm_code):
    lines = asm_code.strip().split('\n')
    labels = {}

    # پیش‌پردازش: حذف کامنت‌ها و خطوط خالی
    cleaned_lines = []
    for line in lines:
        line = line.split('#')[0].strip()
        if line:
            cleaned_lines.append(line)

    # مرحله اول (Pass 1): یافتن برچسب‌ها و تعیین آدرس آن‌ها
    pc = 0
    for line in cleaned_lines:
        if line.endswith(':'):
            label_name = line[:-1].strip()
            labels[label_name] = pc
        else:
            # اگر خط شامل دستور همراه با برچسب در همان خط باشد
            if ':' in line:
                parts = line.split(':')
                label_name = parts[0].strip()
                labels[label_name] = pc
            pc += 1

    # مرحله دوم (Pass 2): ترجمه دستورات به ماشین‌کد
    machine_code = []
    pc = 0

    for line in cleaned_lines:
        # جدا کردن برچسب از دستور
        if ':' in line:
            line = line.split(':')[1].strip()
        if not line:
            continue

        line = line.replace(',', ' ')
        tokens = line.split()
        op = tokens[0].upper()

        opcode = OPCODES.get(op, "0000")
        rd = OPERANDS["NIL"]
        rs = OPERANDS["NIL"]
        flag = "0"
        funct7 = "0000000"

        # دستورات بدون عملوند
        if op in ["NOP", "SWP", "NEG", "SAV"]:
            if op == "NEG":
                rd = OPERANDS["ACC"]
                rs = OPERANDS["ACC"]
            elif op == "SAV":
                rd = OPERANDS["BAK"]
                rs = OPERANDS["ACC"]

            machine_code.append(f"{funct7}{rs}{flag}{rd}{opcode}")

        # پرش‌ها (Jumps) - پیدا کردن آفست از طریق Label
        elif op in ["JMP", "JEZ", "JNZ", "JGZ", "JLZ"]:
            target = tokens[1]
            flag = "1"
            # محاسبه آفست نسبت به PC دستور فعلی
            offset = labels[target] - pc
            imm = to_11bit_binary(offset)
            machine_code.append(f"{imm}{flag}{rd}{opcode}")

        # دستورات با یک عملوند (ADD, SUB, JRO)
        elif op in ["ADD", "SUB", "JRO"]:
            src = tokens[1]
            if op in ["ADD", "SUB"]:
                rd = OPERANDS["ACC"]

            if src in OPERANDS:  # حالت R-type
                flag = "0"
                rs = OPERANDS[src]
                machine_code.append(f"{funct7}{rs}{flag}{rd}{opcode}")
            else:  # حالت I-type
                flag = "1"
                imm = to_11bit_binary(int(src))
                machine_code.append(f"{imm}{flag}{rd}{opcode}")

        # دستور MOV (دو عملوندی)
        elif op == "MOV":
            src = tokens[1]
            dst = tokens[2]
            rd = OPERANDS.get(dst, OPERANDS["NIL"])

            if src in OPERANDS:  # حالت R-type
                flag = "0"
                rs = OPERANDS[src]
                machine_code.append(f"{funct7}{rs}{flag}{rd}{opcode}")
            else:  # حالت I-type
                flag = "1"
                imm = to_11bit_binary(int(src))
                machine_code.append(f"{imm}{flag}{rd}{opcode}")

        pc += 1

    return machine_code


if __name__ == "__main__":
    import os
    import glob
    input_dir = "."   # می‌توانید مسیر دلخواه را قرار دهید

    # دریافت لیست تمام فایل‌های با پسوند asm در پوشه
    asm_files = glob.glob(os.path.join(input_dir, "*.asm"))
    
    for input_filename in asm_files:
        print(f"Processing: {input_filename}")
        
        with open(input_filename, 'r', encoding='utf-8') as f:
            asm_code = f.read()
        
        binary_output = assemble_tis100_with_labels(asm_code)
        
        # ساخت نام خروجی: base_name + "_machine.txt"
        base = os.path.splitext(input_filename)[0]
        output_filename = f"{base}_machine.txt"
        
        with open(output_filename, 'w', encoding='utf-8') as out:
            for b in binary_output:
                out.write(b + '\n')
        
    print("Done.")
