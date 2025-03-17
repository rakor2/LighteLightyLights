import os
import xml.etree.ElementTree as ET

# Get current directory and setup output directory _ai
current_dir = os.path.dirname(os.path.abspath(__file__))
output_dir = os.path.join(current_dir, 'lsx_out')

print(f"Текущая директория: {current_dir}")

def read_template_file():
    """Read template LSX file _ai"""
    template_path = os.path.join(current_dir, '0b0e20f6-2ffb-40fc-ad05-2ce49bffcf9d.lsx')
    print(f"Читаем шаблон: {template_path}")
    return ET.parse(template_path)

def read_name_guid_mapping():
    """Read name to GUID mapping from file _ai"""
    mapping = {}
    name_guid_path = os.path.join(current_dir, 'name_guid.txt')
    print(f"Читаем сопоставления: {name_guid_path}")
    
    with open(name_guid_path, 'r') as f:
        for line in f:
            line = line.strip()
            if line:
                name, guid = line.rsplit('_', 1)
                mapping[name] = guid
    
    print(f"Прочитано {len(mapping)} сопоставлений")
    return mapping

def get_free_uuid():
    """Get and remove first available UUID from file _ai"""
    guids_path = os.path.join(current_dir, 'guids.txt')
    
    with open(guids_path, 'r') as f:
        uuids = f.readlines()
    
    if not uuids:
        raise Exception("Нет свободных UUID в guids.txt")
    
    free_uuid = uuids[0].strip()
    
    # Remove used UUID from file _ai
    with open(guids_path, 'w') as f:
        f.writelines(uuids[1:])
    
    return free_uuid

def create_lsx_file(template_tree, vfx_name, visual_template_guid, output_uuid):
    """Create new LSX file with modified attributes _ai"""
    root = template_tree.getroot()
    
    # Create RootTemplate name from VFX name _ai
    root_template_name = f"{vfx_name}_RootTemplate"
    
    # Update MapKey _ai
    map_key = root.find(".//attribute[@id='MapKey']")
    map_key.set('value', output_uuid)
    
    # Update Name _ai
    name_attr = root.find(".//attribute[@id='Name']")
    name_attr.set('value', root_template_name)
    
    # Update VisualTemplate _ai
    visual_template = root.find(".//attribute[@id='VisualTemplate']")
    visual_template.set('value', visual_template_guid)
    
    # Create output directory if needed _ai
    if not os.path.exists(output_dir):
        os.makedirs(output_dir)
    
    # Save the modified XML _ai
    output_path = os.path.join(output_dir, f"{output_uuid}.lsx")
    template_tree.write(output_path, encoding='utf-8', xml_declaration=True)
    print(f"Создан файл: {output_path}")

def main():
    try:
        # Read template file _ai
        template_tree = read_template_file()
        
        # Read name to GUID mapping _ai
        name_guid_mapping = read_name_guid_mapping()
        
        # Process each VFX entry _ai
        for vfx_name, visual_template_guid in name_guid_mapping.items():
            try:
                # Get new UUID for the file _ai
                output_uuid = get_free_uuid()
                
                # Create LSX file _ai
                create_lsx_file(
                    ET.ElementTree(template_tree.getroot()), 
                    vfx_name,
                    visual_template_guid,
                    output_uuid
                )
            except Exception as e:
                print(f"Ошибка при создании файла для {vfx_name}: {str(e)}")
                continue
                
    except Exception as e:
        print(f"Критическая ошибка: {str(e)}")

if __name__ == "__main__":
    main() 