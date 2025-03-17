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

def modify_xml_file(src_file, dest_file, capture_descs):
    """Modify XML file by adding CaptureDesc blocks _ai"""
    try:
        # Read source file content _ai
        with open(src_file, 'r', encoding='utf-8-sig') as f:
            content = f.read()
            
        # Get XML declaration from original file _ai
        xml_decl = ''
        first_line = content.split('\n', 1)[0]
        if first_line.startswith('<?xml'):
            xml_decl = first_line
            
        # Parse XML _ai
        tree = ET.fromstring(content)
        
        # Find all GameObjects nodes _ai
        game_objects = []
        for node in tree.findall(".//node"):
            if node.get('id') == 'GameObjects':
                game_objects.append(node)
        
        print(f"    Найдено GameObjects: {len(game_objects)}")
        
        for game_object in game_objects:
            # Print GameObject info for debugging _ai
            name_attr = game_object.find(".//attribute[@id='Name']")
            if name_attr is not None:
                print(f"      Обработка GameObject: {name_attr.get('value', 'Unknown')}")
            
            # Find or create CaptureDescriptions node _ai
            capture_descriptions = game_object.find("children/node[@id='CaptureDescriptions']")
            if capture_descriptions is None:
                children = game_object.find("children")
                if children is None:
                    children = ET.SubElement(game_object, 'children')
                
                capture_descriptions = ET.SubElement(children, 'node', {'id': 'CaptureDescriptions'})
                capture_children = ET.SubElement(capture_descriptions, 'children')
                print("        Создан новый CaptureDescriptions узел")
            else:
                capture_children = capture_descriptions.find('children')
                if capture_children is None:
                    capture_children = ET.SubElement(capture_descriptions, 'children')
                print("        Найден существующий CaptureDescriptions узел")
            
            # Add new CaptureDesc nodes _ai
            added_count = 0
            for desc in capture_descs:
                # Create a deep copy of the element _ai
                new_desc = ET.fromstring(ET.tostring(desc))
                capture_children.append(new_desc)
                added_count += 1
            
            print(f"        Добавлено CaptureDesc блоков: {added_count}")
        
        # Add proper indentation _ai
        indent_xml(tree)
        
        # Convert to string _ai
        xml_str = ET.tostring(tree, encoding='unicode')
        
        # Create directory if it doesn't exist _ai
        os.makedirs(os.path.dirname(dest_file), exist_ok=True)
        
        # Save the XML with original declaration _ai
        with open(dest_file, 'w', encoding='utf-8', newline='\n') as f:
            if xml_decl:
                f.write(xml_decl + '\n')
            f.write(xml_str)
            
        print(f"    Обработан файл: {dest_file}")
        
    except Exception as e:
        print(f"Ошибка при обработке файла {src_file}: {str(e)}")

def main():
    # Paths _ai
    script_dir = os.path.dirname(os.path.abspath(__file__))
    capture_file = os.path.join(script_dir, 'captured_light_probes.txt')
    output_dir = os.path.join(script_dir, 'LightProbes_output')
    
    # Read CaptureDesc blocks _ai
    print("Чтение CaptureDesc блоков...")
    capture_descs = read_capture_descs(capture_file)
    print(f"Прочитано {len(capture_descs)} CaptureDesc блоков")
    
    # Create output directory _ai
    if os.path.exists(output_dir):
        shutil.rmtree(output_dir)
    
    # Process all _merged.lsx files _ai
    print("\nОбработка файлов...")
    for root, dirs, files in os.walk('.'):
        if 'LightProbes' in dirs:
            src_lightprobes = os.path.join(root, 'LightProbes')
            
            # Create relative output path _ai
            rel_path = os.path.relpath(src_lightprobes, '.')
            dest_lightprobes = os.path.join(output_dir, rel_path)
            
            # Copy only _merged.lsx files _ai
            for file in os.listdir(src_lightprobes):
                if file.endswith('_merged.lsx'):
                    src_file = os.path.join(src_lightprobes, file)
                    dest_file = os.path.join(dest_lightprobes, file)
                    
                    print(f"\nОбработка: {rel_path}/{file}")
                    modify_xml_file(src_file, dest_file, capture_descs)

if __name__ == "__main__":
    main()
    print("\nГотово! Результаты сохранены в папке LightProbes_output")
