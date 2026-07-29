import os
import shutil
import open_rppg

# 1. Ensure output folder exists
output_dir = os.path.join(os.path.dirname(__file__), "..", "models")
os.makedirs(output_dir, exist_ok=True)
destination_path = os.path.join(output_dir, "efficientphys.onnx")

# 2. Locate open-rppg package folder
package_dir = os.path.dirname(open_rppg.__file__)

# 3. Find any .onnx model downloaded inside open-rppg
onnx_found = False
for root, dirs, files in os.walk(package_dir):
    for file in files:
        if file.endswith(".onnx"):
            source_path = os.path.join(root, file)
            shutil.copy(source_path, destination_path)
            print(f"Success! Copied {file} to {destination_path}")
            onnx_found = True
            break

if not onnx_found:
    print("No ONNX model found in open_rppg package directory yet.")
    print("Run `rppg.Model()` once in python to trigger the initial weight download.")