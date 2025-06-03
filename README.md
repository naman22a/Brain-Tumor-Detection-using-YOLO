# 🧠 Brain Tumor detection using YOLO

Detect brain tumors in MRI images using the state-of-the-art YOLO (You Only Look Once) object detection algorithm. This project applies deep learning to assist in early and accurate diagnosis of brain tumors, enhancing radiological analysis and medical imaging workflows.

## 🚀 Features

-   🔍 Real-time object detection of brain tumors in MRI scans
-   🧠 Pre-trained YOLO model fine-tuned on brain tumor datasets
-   📊 Model evaluation metrics: mAP@0.5, mAP@0.5:0.95, Precision, Recall
-   🖼️ Bounding box visualization on test images

## 📸 Screenshots

<table>
  <tr>
    <td><img src="./assets/1.jpg" alt="Image 1" width="400"/></td>
    <td><img src="./assets/2.jpg" alt="Image 2" width="400"/></td>
  </tr>
</table>

## ⚙️ Tech Stack

-   📘 Flutter
-   🎯 Dart
-   🎁 Provider
-   📷 Image Picker
-   📨 Dio

<br/>

-   🐍 Python
-   ⚗️ Flask

<br/>

-   👁️ YOLO v11
-   🔥 Ultralytics
-   🤖 Roboflow

## 📊 Results

**Model Summary:**

-   **Architecture:** YOLO11n (fused)
-   **Layers:** 100
-   **Parameters:** 2.58M
-   **GFLOPs:** 6.3
-   **Gradient Updates:** 0 (fused model)

### 📈 Evaluation Metrics

| Class                      | Precision | Recall | mAP@0.5 | mAP@0.5:0.95 |
| -------------------------- | --------- | ------ | ------- | ------------ |
| **All Classes**            | 0.899     | 0.633  | 0.668   | 0.553        |
| **NO_tumor**               | 0.942     | 0.976  | 0.970   | 0.817        |
| **Glioma**                 | 0.863     | 0.525  | 0.647   | 0.456        |
| **Meningioma**             | 0.942     | 0.912  | 0.945   | 0.835        |
| **Pituitary**              | 0.749     | 0.754  | 0.777   | 0.657        |
| **Space-occupying lesion** | 1.000     | 0.000  | 0.000   | 0.000        |

> ⚠️ **Note:** The _space-occupying lesion_ class has very few instances and may require more labeled samples to be reliably detected.

### ⚡ Performance

| Stage         | Time/Image |
| ------------- | ---------- |
| Preprocessing | 0.3 ms     |
| Inference     | 2.9 ms     |
| Postprocess   | 3.8 ms     |

### 😵 Confusion Matrix

![Confusion Matrix](./assets/confusion_matrix.png)

## 🤝 Contributing

Contributions are welcome! Open an issue or submit a pull request for features, bugs, or improvements.

## 📫 Stay in touch

-   Author - [Naman Arora](https://namanarora.vercel.app)
-   Twitter - [@naman_22a](https://twitter.com/naman_22a)

## 🗒️ License

Brain Tumor Detection using YOLO is [GPL V3](./LICENSE)
