import os
from collections import defaultdict

def parse_name_guid(filename):
    """Parse RT_name_guid.txt and create structured data _ai"""
    mapping = defaultdict(list)
    point_entries = []
    
    with open(filename, 'r') as f:
        for line in f:
            line = line.strip()
            if not line:
                continue
                
            if line.startswith('LLL_Point_'):
                # Handle Point entries _ai
                parts = line.split('_')
                try:
                    if parts[2] == 'VFX':  # Base entry
                        slot = 1
                    else:
                        slot = int(parts[2])
                    guid = line.rsplit('_', 1)[1]
                    point_entries.append((slot, guid))
                except ValueError:
                    continue
            elif line.startswith('LLL_Directional_'):
                # Handle Directional entries _ai
                parts = line.split('_')
                angle = parts[2]
                
                try:
                    # Check if this is a base entry (no slot number) _ai
                    if parts[3] == 'VFX':
                        slot = 1
                    else:
                        slot = int(parts[3])
                    guid = line.rsplit('_', 1)[1]
                    mapping[f"Directional_{angle}"].append((slot, guid))
                except (ValueError, IndexError):
                    continue
    
    if point_entries:
        mapping['Point'] = point_entries
    
    return mapping

def angle_sort_key(angle_name):
    """Custom sort key for angle names _ai"""
    if angle_name == 'Point':
        return float('inf')  # Point goes last
    return int(angle_name.split('_')[1])  # Sort angles in ascending order

def create_lua_table(mapping):
    """Create Lua table string from mapping _ai"""
    lua_lines = ['Light_Actual_Templates_Slots = {']
    
    # Sort angles in descending order _ai
    for angle in sorted(mapping.keys(), key=angle_sort_key):
        lua_lines.append(f'    ["{angle}"] = {{')
        
        # Sort by slot number and create entries _ai
        slots = sorted(mapping[angle])
        for slot_num, guid in slots:
            if angle == 'Point':
                slot_name = 'Point Slot'
            else:
                slot_name = 'Directional Slot'
            lua_lines.append(f'        {{"{slot_name} {slot_num}", "{guid}"}},')
            
        # Add nil entry for slot 21 _ai
        if angle != 'Point':
            lua_lines.append('        {"Directional Slot 21", "nil"}')
        lua_lines.append('    },')
    
    lua_lines.append('}')
    return '\n'.join(lua_lines)

def main():
    script_dir = os.path.dirname(os.path.abspath(__file__))
    input_file = os.path.join(script_dir, 'RT_name_guid.txt')
    output_file = os.path.join(script_dir, 'light_templates.lua')
    
    print(f"Читаем файл: {input_file}")
    mapping = parse_name_guid(input_file)
    
    lua_table = create_lua_table(mapping)
    
    print(f"Создаем файл: {output_file}")
    with open(output_file, 'w') as f:
        f.write(lua_table)
    
    print("Готово!")

if __name__ == "__main__":
    main() 