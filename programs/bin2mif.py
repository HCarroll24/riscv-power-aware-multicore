import sys

DEPTH = 4096                                    # IROM words
NOP = 0x00000013

data = open(sys.argv[1], "rb").read()
words = []
for i in range(0, len(data), 4):
    words.append(int.from_bytes(data[i:i + 4].ljust(4, b"\0"), "little"))

if len(words) > DEPTH:
    sys.exit(f"program is {len(words)} words, IROM holds {DEPTH}")

with open(sys.argv[2], "w") as f:
    f.write(f"WIDTH=32;\nDEPTH={DEPTH};\nADDRESS_RADIX=HEX;\nDATA_RADIX=HEX;\nCONTENT BEGIN\n")
    for addr, word in enumerate(words):
        f.write(f"\t{addr:03X} : {word:08X};\n")
    if len(words) < DEPTH:
        f.write(f"\t[{len(words):03X}..{DEPTH - 1:03X}] : {NOP:08X};\n")
    f.write("END;\n")
print(f"{len(words)} words written to {sys.argv[2]}")
