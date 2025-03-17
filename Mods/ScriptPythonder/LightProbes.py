import os
import xml.etree.ElementTree as ET

# Function to format CaptureDesc node as pretty string _ai
def format_capture_desc(capture_desc):
    # Convert to string with manual formatting _ai
    output = []
    output.append('<node id="CaptureDesc">')
    
    # Sort attributes for consistent output _ai
    attributes = sorted(capture_desc.findall('attribute'), key=lambda x: x.get('id', ''))
    
    for attr in attributes:
        attr_id = attr.get('id', '')
        attr_type = attr.get('type', '')
        attr_value = attr.get('value', '')
        output.append(f'    <attribute id="{attr_id}" type="{attr_type}" value="{attr_value}" />')
    
    output.append('</node>')
    return '\n'.join(output)

# Function to process XML file and extract CaptureDesc blocks _ai
def process_xml_file(file_path, output_file):
    count = 0
    try:
        print(f"    Чтение файла: {file_path}")
        tree = ET.parse(file_path)
        root = tree.getroot()
        
        # Find all GameObjects nodes _ai
        game_objects = root.findall(".//node[@id='GameObjects']")
        print(f"    Найдено GameObjects: {len(game_objects)}")
        
        for game_object in game_objects:
            name_attr = game_object.find(".//attribute[@id='Name']")
            
            if name_attr is not None and 'distant' in name_attr.get('value', '').lower():
                print(f"    Найден Distant объект: {name_attr.get('value', '')}")
                
                # Get MapKey for this GameObject _ai
                map_key = None
                map_key_attr = game_object.find(".//attribute[@id='MapKey']")
                if map_key_attr is not None:
                    map_key = map_key_attr.get('value', '')
                
                # Find CaptureDesc nodes for this game object _ai
                capture_descs = game_object.findall(".//node[@id='CaptureDesc']")
                print(f"    Найдено CaptureDesc: {len(capture_descs)}")
                
                for capture_desc in capture_descs:
                    # Format CaptureDesc node _ai
                    formatted_desc = format_capture_desc(capture_desc)
                    count += 1
                    
                    # Write to output file with separator _ai
                    with open(output_file, 'a', encoding='utf-8') as f:
                        f.write(formatted_desc + '\n\n==========\n\n')
                        
    except ET.ParseError as e:
        print(f"Ошибка при обработке файла {file_path}: {str(e)}")
    except Exception as e:
        print(f"Непредвиденная ошибка при обработке {file_path}: {str(e)}")
    return count

def main():
    # Output file path _ai
    output_file = "captured_light_probes.txt"
    total_count = 0
    
    # Clear output file if exists _ai
    if os.path.exists(output_file):
        os.remove(output_file)
    
    print("Начинаем поиск файлов...")
    # Walk through directories _ai
    for root, dirs, files in os.walk('.'):
        if 'LightProbes' in dirs:
            lightprobes_path = os.path.join(root, 'LightProbes')
            print(f"\nНайдена папка LightProbes: {lightprobes_path}")
            
            # Check for _merged.lsx in LightProbes directory _ai
            merged_files = [f for f in os.listdir(lightprobes_path) if f.endswith('_merged.lsx')]
            print(f"Найдено _merged.lsx файлов: {len(merged_files)}")
            
            for file in merged_files:
                merged_file_path = os.path.join(lightprobes_path, file)
                print(f"\nОбработка файла: {merged_file_path}")
                file_count = process_xml_file(merged_file_path, output_file)
                total_count += file_count
                print(f"Извлечено CaptureDesc из файла: {file_count}")
    
    # Write total count to file _ai
    with open(output_file, 'a', encoding='utf-8') as f:
        f.write(f"\nВсего найдено CaptureDesc блоков: {total_count}")

if __name__ == "__main__":
    main()
    print("\nОбработка завершена. Результаты сохранены в captured_light_probes.txt")
