#!/usr/bin/env python3
import sys
import struct

def parse_vgm_30hz(vgm_path, output_path):
    with open(vgm_path, 'rb') as f:
        data = f.read()

    if data[0:4] != b'Vgm ':
        print("Invalid VGM file")
        return

    # Find data offset
    vgm_offset = struct.unpack('<I', data[0x34:0x38])[0]
    if vgm_offset == 0:
        vgm_offset = 0x40
    else:
        vgm_offset += 0x34

    pos = vgm_offset
    output = bytearray()
    
    total_frames = 0
    pending_regs = {} # Map of reg -> val for the current 30hz frame
    
    # 60Hz frame counter to trigger merge every 2 frames
    frames_in_batch = 0
    
    # Track Last Output Regs to minimize redundancy across 30Hz frames
    # Initialize to -1
    last_output_regs = [-1] * 16

    print(f"Processing {vgm_path} (30Hz Mode)...")

    while pos < len(data):
        cmd = data[pos]

        if cmd == 0x66: # End of Sound Data
            break
            
        elif cmd == 0x62: # Wait 1/60th
            frames_in_batch += 1
            pos += 1
            
        elif cmd == 0x61: # Wait n
            # Assume 1 frame roughly? Or ignore?
            # For robustness, treat as 1 frame
            frames_in_batch += 1
            pos += 3
            
        elif cmd == 0xBB: # Write Reg
            reg = data[pos+1]
            val = data[pos+2]
            if reg < 16:
                pending_regs[reg] = val # Overwrite previous write in this batch
            pos += 3
            
        elif cmd == 0xB2: # POKEY write
             pos += 3
        elif (cmd & 0xF0) == 0x70: # Short wait
             pos += 1
        else:
             pos += 1
             
        # Check if we reached 2 frames (30Hz boundary)
        if frames_in_batch >= 2:
            # FLUSH pending regs
            for r in sorted(pending_regs.keys()):
                v = pending_regs[r]
                # Redundancy Check against LAST OUTPUT
                if last_output_regs[r] != v:
                    output.append(r)
                    output.append(v)
                    last_output_regs[r] = v
            
            output.append(0xFF) # End 30Hz Frame
            total_frames += 1
            
            # Reset
            frames_in_batch = 0
            pending_regs = {}

    output.append(0xFE) 
    
    with open(output_path, 'wb') as f:
        f.write(output)
        
    print(f"Done. {total_frames} 30Hz frames. Output size: {len(output)} bytes.")

if __name__ == "__main__":
    parse_vgm_30hz(sys.argv[1], sys.argv[2])
