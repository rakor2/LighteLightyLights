import os
import shutil
import xml.etree.ElementTree as ET

def parse_lua_like_table(text):
    """Parse Lua-like table format into Python list of dicts _ai"""
    # Remove table name and outer braces _ai
    content = text.strip()
    if '=' in content:
        content = content.split('=', 1)[1].strip()
    content = content.strip('{}')
    
    # Split into individual entries _ai
    entries = []
    current_entry = []
    brace_count = 0
    
    for line in content.split('\n'):
        line = line.strip()
        if not line or line.startswith('--'):  # Skip empty lines and comments
            continue
            
        brace_count += line.count('{') - line.count('}')
        current_entry.append(line)
        
        if brace_count == 0 and current_entry:
            entries.append(''.join(current_entry))
            current_entry = []
    
    # Parse each entry into a dict _ai
    result = []
    for entry in entries:
        entry = entry.strip('{}')
        pairs = [pair.strip() for pair in entry.split(',') if pair.strip()]
        item = {}
        for pair in pairs:
            if '=' in pair:
                key, value = pair.split('=', 1)
                key = key.strip()
                value = value.strip().strip("'\"")
                item[key] = value
        if item:
            result.append(item)
    
    return result

def read_triggers_and_templates():
    """Read triggers and templates from files _ai"""
    script_dir = os.path.dirname(os.path.abspath(__file__))
    
    # Read ATM triggers _ai
    with open(os.path.join(script_dir, 'ATM_Triggers.txt'), 'r', encoding='utf-8') as f:
        atm_triggers = parse_lua_like_table(f.read())
    
    # Read LTN triggers _ai
    with open(os.path.join(script_dir, 'LTN_Triggers.txt'), 'r', encoding='utf-8') as f:
        ltn_triggers = parse_lua_like_table(f.read())
    
    # Read ATM templates _ai
    with open(os.path.join(script_dir, 'ATM_Templates.txt'), 'r', encoding='utf-8') as f:
        atm_templates = parse_lua_like_table(f.read())
    
    # Read LTN templates _ai
    with open(os.path.join(script_dir, 'LTN_Templates.txt'), 'r', encoding='utf-8') as f:
        ltn_templates = parse_lua_like_table(f.read())
    
    return atm_triggers, ltn_triggers, atm_templates, ltn_templates

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

def modify_trigger(game_object, templates):
    """Modify trigger node with new templates and fade time _ai"""
    modified = False
    
    # Change FadeTime to 0 _ai
    fade_time = game_object.find("attribute[@id='FadeTime']")
    if fade_time is not None:
        fade_time.set('value', '0')
        modified = True
    
    # Find ResourceIDs node _ai
    resource_ids = game_object.find(".//node[@id='ResourceIDs']")
    if resource_ids is not None:
        children = resource_ids.find('children')
        if children is None:
            children = ET.SubElement(resource_ids, 'children')
        
        # Get existing template UUIDs _ai
        existing_uuids = set()
        for resource in children.findall(".//attribute[@id='Object']"):
            existing_uuids.add(resource.get('value', ''))
        
        # Add new templates _ai
        for template in templates:
            if template['uuid'] not in existing_uuids:
                # Create new ResourceID node with same structure as existing ones _ai
                new_resource = ET.Element('node')
                new_resource.set('id', 'ResourceID')
                new_attr = ET.SubElement(new_resource, 'attribute')
                new_attr.set('id', 'Object')
                new_attr.set('type', 'FixedString')
                new_attr.set('value', template['uuid'])
                
                # Add newline and indent before new node _ai
                if len(children) > 0:
                    last = list(children)[-1]
                    if last.tail:
                        new_resource.tail = last.tail
                
                children.append(new_resource)
                modified = True
    
    return modified

def process_xml_file(file_path, atm_triggers, ltn_triggers, atm_templates, ltn_templates):
    """Process XML file and modify triggers _ai"""
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
        
        modified = False
        
        # Find all GameObjects _ai
        for game_object in tree.findall(".//node[@id='GameObjects']"):
            map_key = game_object.find("attribute[@id='MapKey']")
            if map_key is not None:
                uuid = map_key.get('value', '')
                
                # Check if this is ATM trigger _ai
                for trigger in atm_triggers:
                    if trigger['uuid'] == uuid:
                        print(f"    Найден ATM триггер: {trigger['name']}")
                        if modify_trigger(game_object, atm_templates):
                            modified = True
                        break
                
                # Check if this is LTN trigger _ai
                for trigger in ltn_triggers:
                    if trigger['uuid'] == uuid:
                        print(f"    Найден LTN триггер: {trigger['name']}")
                        if modify_trigger(game_object, ltn_templates):
                            modified = True
                        break
        
        if modified:
            # Add proper indentation _ai
            indent_xml(tree)
            
            # Save modified content back to file _ai
            with open(file_path, 'w', encoding='utf-8', newline='\n') as f:
                if xml_decl:
                    f.write(xml_decl + '\n')
                f.write(ET.tostring(tree, encoding='unicode'))
            
            return True
    
    except Exception as e:
        print(f"Ошибка при обработке файла {file_path}: {str(e)}")
    
    return False

def main():
    # Read triggers and templates _ai
    print("Чтение триггеров и шаблонов...")
    atm_triggers, ltn_triggers, atm_templates, ltn_templates = read_triggers_and_templates()
    
    # Output directory _ai
    output_dir = os.path.join(os.path.dirname(os.path.abspath(__file__)), 'LTNATM_output')
    
    # Clear output directory if exists _ai
    if os.path.exists(output_dir):
        shutil.rmtree(output_dir)
    
    print("\nПоиск и обработка файлов...")
    modified_count = 0
    
    # Walk through directories _ai
    for root, dirs, files in os.walk('.'):
        if 'Triggers' in dirs:
            triggers_path = os.path.join(root, 'Triggers')
            print(f"\nНайдена папка Triggers: {os.path.relpath(triggers_path, '.')}")
            
            # Check for _merged.lsx _ai
            merged_files = [f for f in os.listdir(triggers_path) if f.endswith('_merged.lsx')]
            for file in merged_files:
                src_file = os.path.join(triggers_path, file)
                print(f"\nПроверка файла: {os.path.relpath(src_file, '.')}")
                
                # Create output directory structure _ai
                dest_triggers = os.path.join(output_dir, os.path.relpath(triggers_path, '.'))
                os.makedirs(dest_triggers, exist_ok=True)
                
                # Copy and modify file _ai
                dest_file = os.path.join(dest_triggers, file)
                shutil.copy2(src_file, dest_file)
                
                if process_xml_file(dest_file, atm_triggers, ltn_triggers, atm_templates, ltn_templates):
                    modified_count += 1
                else:
                    # Remove file if not modified _ai
                    os.remove(dest_file)
                    # Remove empty directories _ai
                    try:
                        os.removedirs(dest_triggers)
                    except OSError:
                        pass
    
    print(f"\nГотово! Обработано файлов: {modified_count}")
    print(f"Результаты сохранены в папке {output_dir}")

if __name__ == "__main__":
    main()
