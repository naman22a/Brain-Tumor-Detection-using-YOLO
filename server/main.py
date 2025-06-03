from flask import Flask, request, jsonify
from ultralytics import YOLO
from PIL import Image

app = Flask(__name__)

model = YOLO("best.pt")

@app.route('/predict', methods=['POST'])
def predict():
    if 'image' not in request.files:
        return jsonify({'error': 'No image provided'}), 400

    file = request.files['image']

    try:
        image = Image.open(file.stream)
    except Exception as e:
        return jsonify({'error': f'Invalid image: {str(e)}'}), 400

    results = model(image, conf=0.1)

    predictions = []
    for result in results:
        if result.boxes is not None:
            for box in result.boxes:
                bbox_coords = box.xyxy[0].cpu().numpy() 
                class_id = int(box.cls.cpu().numpy())
                confidence = float(box.conf.cpu().numpy())
                
                pred = {
                    "name": model.names[class_id],
                    "confidence": confidence,
                    "bbox": [float(x) for x in bbox_coords]  # [x1, y1, x2, y2]
                }
                predictions.append(pred)

    return jsonify({"predictions": predictions})

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)