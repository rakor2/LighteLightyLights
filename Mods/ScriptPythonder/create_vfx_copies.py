import os
import shutil

# List of directional angles _ai
directional_angles = ['4', '10', '20', '30', '40', '60', '90', '150', '179']

# Base filenames _ai
directional_base = 'LLL_Directional_{}_VFX.lsefx'
point_base = 'LLL_Point_VFX.lsefx'

# Get script directory and set output directory _ai
script_dir = os.path.dirname(os.path.abspath(__file__))
output_dir = os.path.join(script_dir, 'lsefx_copies')

def create_copies(filename, start_number=20):
    # Check if source file exists _ai
    if not os.path.exists(filename):
        print(f"Файл {filename} не найден")
        return
    
    # Create output directory if it doesn't exist _ai
    if not os.path.exists(output_dir):
        os.makedirs(output_dir)
    
    # Get base name without extension _ai
    base_name = filename.rsplit('.', 1)[0]
    extension = filename.rsplit('.', 1)[1]
    
    # Create copies _ai
    for i in range(1, start_number + 1):
        if 'Point' in filename:
            new_filename = f"LLL_Point_{i}_VFX.{extension}"
        else:
            angle = filename.split('_')[2]
            new_filename = f"LLL_Directional_{angle}_{i}_VFX.{extension}"
            
        # Create full path for new file _ai
        new_filepath = os.path.join(output_dir, new_filename)
        source_filepath = os.path.join(script_dir, filename)
        shutil.copy2(source_filepath, new_filepath)
        print(f"Создан файл: {new_filepath}")

def main():
    # Process directional files _ai
    for angle in directional_angles:
        source_file = directional_base.format(angle)
        create_copies(source_file, 20)
    
    # Process point file _ai
    create_copies(point_base, 20)

if __name__ == "__main__":
    main() 