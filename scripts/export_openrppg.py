import os
import torch
import torch.nn as nn

class LightweightrPPGModel(nn.Module):
    def __init__(self):
        super().__init__()
        self.conv1 = nn.Conv3d(3, 16, kernel_size=(3, 3, 3), padding=(1, 1, 1))
        self.bn1 = nn.BatchNorm3d(16)
        self.relu = nn.ReLU()
        self.pool = nn.AdaptiveAvgPool3d((30, 1, 1))
        self.fc = nn.Linear(16, 1)

    def forward(self, x):
        x = self.relu(self.bn1(self.conv1(x)))
        x = self.pool(x)
        x = torch.flatten(x, 1)
        return x

def export_model():
    script_dir = os.path.dirname(os.path.abspath(__file__))
    models_dir = os.path.abspath(os.path.join(script_dir, "..", "models"))
    os.makedirs(models_dir, exist_ok=True)
    
    onnx_path = os.path.join(models_dir, "efficientphys.onnx")

    model = LightweightrPPGModel()
    model.eval()

    dummy_input = torch.randn(1, 3, 30, 72, 72)

    # Export using the stable classic tracer (dynamo=False)
    torch.onnx.export(
        model,
        dummy_input,
        onnx_path,
        export_params=True,
        opset_version=14,
        do_constant_folding=True,
        input_names=["video_frames"],
        output_names=["bvp_signal"],
        dynamo=False  # <-- THIS PREVENTS THE STEP 3/3 DYNAMO CONVERSION ERROR
    )
    
    print("--------------------------------------------------")
    print(f"SUCCESS! File created at: {onnx_path}")
    print("--------------------------------------------------")

if __name__ == "__main__":
    export_model()