import os
import shutil
import xml.etree.ElementTree as ET

def read_capture_descs(file_path):
    """Read CaptureDesc blocks from captured_light_probes.txt _ai"""
    capture_descs = []
    current_block = []
    
    with open(file_path, 'r', encoding='utf-8') as f:
        for line in f:
            if line.strip() == '==========':
                if current_block:
                    block_text = '\n'.join(current_block)
                    try:
                        element = ET.fromstring(block_text)
                        capture_descs.append(element)
                    except ET.ParseError as e:
                        print(f"Ошибка при разборе блока: {e}")
                    current_block = []
            elif line.strip():
                current_block.append(line.strip())
    
    # Handle last block if exists _ai
    if current_block:
        block_text = '\n'.join(current_block)
        try:
            element = ET.fromstring(block_text)
            capture_descs.append(element)
        except ET.ParseError as e:
            print(f"Ошибка при разборе блока: {e}")
    
    return capture_descs

def indent_xml(elem, level=0, indent_size=4):
    """Add proper indentation to XML element _ai"""
    i = "\n" + level * " " * indent_size
    if len(elem):
        if not elem.text or not elem.text.strip():
            elem.text = i + " " * indent_size
        if not elem.tail or not elem.tail.strip():
            elem.tail = i
        for subelem in elem:
            indent_xml(subelem, level + 1)
        if not elem.tail or not elem.tail.strip():
            elem.tail = i
    else:
        if level and (not elem.tail or not elem.tail.strip()):
            elem.tail = i

def has_distant_objects(file_path):
    """Check if file has any GameObjects with Distant in name _ai"""
    with open(file_path, 'r', encoding='utf-8-sig') as f:
        content = f.read()
    
    tree = ET.fromstring(content)
    for name_attr in tree.findall(".//node[@id='GameObjects']//attribute[@id='Name']"):
        if 'distant' in name_attr.get('value', '').lower():
            return True
    return False

def get_capture_desc_key(desc):
    """Get unique key for CaptureDesc based on path up to first GUID _ai"""
    # Get path from DiffuseAlphaIBL _ai
    for attr in desc.findall("attribute[@id='DiffuseAlphaIBL']"):
        value = attr.get('value', '')
        if '/Levels/' in value:
            # Split path after /Levels/ _ai
            path = value.split('/Levels/', 1)[1]
            # Find position of last GUID in path _ai
            parts = path.split('/')
            if len(parts) >= 2:  # Should have at least LightProbes/GUID_*
                # Get path up to GUID _ai
                guid_part = parts[-1].split('_')[0]  # Get first GUID from filename
                base_path = '/'.join(parts[:-1]) + '/' + guid_part
                return base_path
    return None

def remove_duplicate_capture_descs(capture_children, original_count):
    """Remove duplicate CaptureDesc nodes keeping original ones _ai"""
    seen_keys = {}  # key -> (position, is_original)
    to_remove = []
    
    # First pass - remember all original CaptureDesc keys _ai
    for i, desc in enumerate(list(capture_children.findall("node[@id='CaptureDesc']"))[:original_count]):
        key = get_capture_desc_key(desc)
        if key:
            seen_keys[key] = (i, True)  # True means original
    
    # Second pass - check new CaptureDesc for duplicates _ai
    for i, desc in enumerate(list(capture_children.findall("node[@id='CaptureDesc']"))[original_count:], start=original_count):
        key = get_capture_desc_key(desc)
        if key:
            if key in seen_keys:
                # This is a duplicate of existing CaptureDesc, mark for removal _ai
                print(f"        Найден дубликат с базовым путем: {key} (удаляем новый)")
                to_remove.append(desc)
            else:
                # First occurrence of this key in new blocks _ai
                seen_keys[key] = (i, False)  # False means new
    
    # Remove duplicates _ai
    removed_count = 0
    for desc in to_remove:
        capture_children.remove(desc)
        removed_count += 1
    
    return removed_count

def replace_paths_in_capture_desc(desc):
    """Replace paths in CaptureDesc with GustavDev paths _ai"""
    base_path = "Mods/GustavDev/Levels/CTY_LowerCity_A/LightProbes/00648559-b44e-4f01-98c9-a0e12ca961b8_3a7102a7-4818-185a-9060-d72318c181f4"
    path_map = {
        'DiffuseAlphaIBL': f"{base_path}_Diffuse_Alpha.dds",
        'DiffuseIBL': f"{base_path}_Diffuse_RGB.dds",
        'SpecularAlphaIBL': f"{base_path}_Specular_Alpha.dds",
        'SpecularIBL': f"{base_path}_Specular_RGB.dds",
        'SphericalHarmonicsIBL': f"{base_path}_SH.dat"
    }
    
    for attr_id, new_path in path_map.items():
        attr = desc.find(f"attribute[@id='{attr_id}']")
        if attr is not None:
            attr.set('value', new_path)

def modify_xml_file(file_path, capture_descs):
    """Modify XML file by removing non-Distant GameObjects and adding CaptureDesc blocks _ai"""
    try:
        # Read file content _ai
        with open(file_path, 'r', encoding='utf-8-sig') as f:
            content = f.read()
        
        # Get XML declaration _ai
        xml_decl = ''
        first_line = content.split('\n', 1)[0]
        if first_line.startswith('<?xml'):
            xml_decl = first_line
        
        # Parse XML _ai
        tree = ET.fromstring(content)
        
        # Find all regions that contain GameObjects _ai
        regions = tree.findall(".//node[@id='GameObjects']/..")
        
        print(f"    Найдено GameObjects блоков: {len(regions)}")
        
        # Check if we have any Distant objects _ai
        has_distant = False
        for name_attr in tree.findall(".//node[@id='GameObjects']//attribute[@id='Name']"):
            if 'distant' in name_attr.get('value', '').lower():
                has_distant = True
                break
        
        # If we have Distant objects, remove all non-Distant GameObjects _ai
        if has_distant:
            print("    Найдены Distant объекты, удаляем остальные")
            for region in regions:
                game_objects = region.findall("node[@id='GameObjects']")
                for game_object in game_objects:
                    has_distant_object = False
                    for name_attr in game_object.findall(".//attribute[@id='Name']"):
                        if 'distant' in name_attr.get('value', '').lower():
                            has_distant_object = True
                            break
                    
                    if not has_distant_object:
                        print(f"      Удаляем блок GameObjects без Distant")
                        region.remove(game_object)
        
        # Now process remaining GameObjects _ai
        remaining_objects = tree.findall(".//node[@id='GameObjects']")
        print(f"    Обработка оставшихся GameObjects блоков: {len(remaining_objects)}")
        
        for game_object in remaining_objects:
            name_attr = game_object.find(".//attribute[@id='Name']")
            name = name_attr.get('value', 'Unknown') if name_attr is not None else 'Unknown'
            print(f"      Обработка GameObject: {name}")
            
            # Find or create CaptureDescriptions node _ai
            capture_descriptions = game_object.find("children/node[@id='CaptureDescriptions']")
            if capture_descriptions is None:
                children = game_object.find("children")
                if children is None:
                    children = ET.SubElement(game_object, 'children')
                
                capture_descriptions = ET.SubElement(children, 'node', {'id': 'CaptureDescriptions'})
                capture_children = ET.SubElement(capture_descriptions, 'children')
                existing_keys = set()
                print("        Создан новый CaptureDescriptions узел")
            else:
                capture_children = capture_descriptions.find('children')
                if capture_children is None:
                    capture_children = ET.SubElement(capture_descriptions, 'children')
                    existing_keys = set()
                else:
                    # Get keys of existing CaptureDesc blocks _ai
                    existing_keys = set()
                    for desc in capture_children.findall("node[@id='CaptureDesc']"):
                        key = get_capture_desc_key(desc)
                        if key:
                            existing_keys.add(key)
                print(f"        Найден существующий CaptureDescriptions узел (существующих блоков: {len(existing_keys)})")
            
            # Add new CaptureDesc nodes if they don't exist _ai
            added_count = 0
            skipped_count = 0
            for desc in capture_descs:
                key = get_capture_desc_key(desc)
                if key and key not in existing_keys:
                    # Create a deep copy of the element _ai
                    new_desc = ET.fromstring(ET.tostring(desc))
                    # Replace paths in the new CaptureDesc _ai
                    replace_paths_in_capture_desc(new_desc)
                    capture_children.append(new_desc)
                    added_count += 1
                else:
                    skipped_count += 1
            
            print(f"        Добавлено новых CaptureDesc блоков: {added_count}")
            if skipped_count > 0:
                print(f"        Пропущено существующих CaptureDesc блоков: {skipped_count}")
        
        # Add proper indentation _ai
        indent_xml(tree)
        
        # Save modified content back to file _ai
        with open(file_path, 'w', encoding='utf-8', newline='\n') as f:
            if xml_decl:
                f.write(xml_decl + '\n')
            f.write(ET.tostring(tree, encoding='unicode'))
        
        print(f"    Сохранен файл: {file_path}")
        
    except Exception as e:
        print(f"Ошибка при обработке файла {file_path}: {str(e)}")

def main():
    # Paths _ai
    script_dir = os.path.dirname(os.path.abspath(__file__))
    capture_file = os.path.join(script_dir, 'captured_light_probes.txt')
    output_dir = os.path.join(script_dir, 'LightProbes_output')
    
    # Read CaptureDesc blocks _ai
    print("Чтение CaptureDesc блоков...")
    capture_descs = read_capture_descs(capture_file)
    print(f"Прочитано {len(capture_descs)} CaptureDesc блоков")
    
    # Clear output directory _ai
    if os.path.exists(output_dir):
        shutil.rmtree(output_dir)
    
    # Process all _merged.lsx files _ai
    print("\nОбработка файлов...")
    for root, dirs, files in os.walk('.'):
        if 'LightProbes' in dirs:
            src_lightprobes = os.path.join(root, 'LightProbes')
            
            # Check each _merged.lsx file _ai
            for file in os.listdir(src_lightprobes):
                if file.endswith('_merged.lsx'):
                    src_file = os.path.join(src_lightprobes, file)
                    
                    # Check if file has any Distant objects _ai
                    if has_distant_objects(src_file):
                        print(f"\nНайден файл с Distant: {os.path.relpath(src_file, '.')}")
                        
                        # Create output directory structure _ai
                        dest_lightprobes = os.path.join(output_dir, os.path.relpath(src_lightprobes, '.'))
                        os.makedirs(dest_lightprobes, exist_ok=True)
                        
                        # Copy file _ai
                        dest_file = os.path.join(dest_lightprobes, file)
                        shutil.copy2(src_file, dest_file)
                        
                        # Modify copied file _ai
                        modify_xml_file(dest_file, capture_descs)

if __name__ == "__main__":
    main()
    print("\nГотово! Результаты сохранены в папке LightProbes_output")
