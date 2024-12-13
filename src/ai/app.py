from flask import Flask, request, jsonify
from tensorflow.keras.models import load_model
from tensorflow.keras.applications.inception_v3 import preprocess_input
import numpy as np
import cv2
import torch

app = Flask(__name__)

# 모델 경로 설정
MODEL_PATH = "model/FoodClassificationModel.h5"
YOLO_MODEL_PATH = "yolov5s.pt"

# InceptionV3 모델 로드
try:
    food_model = load_model(MODEL_PATH)
    print("InceptionV3 Model loaded successfully.")
except Exception as e:
    print(f"Error loading InceptionV3 model: {e}")
    exit(1)

# YOLO 모델 로드
try:
    yolo_model = torch.hub.load('ultralytics/yolov5', 'yolov5s', pretrained=True)
    print("YOLOv5 Model loaded successfully.")
except Exception as e:
    print(f"Error loading YOLO model: {e}")
    exit(1)

# 음식 클래스 목록
classes = [
    '가지볶음', '간장게장', '갈비구이', '갈비찜', '갈비탕', '갈치구이', '갈치조림', '감자전', '감자조림', '감자채볶음', '감자탕', '갓김치', '건새우볶음', '경단', '계란국', '계란말이', '계란찜', '계란후라이', '고등어구이', '고등어조림', '고사리나물', '고추장진미채볶음', '고추튀김', '곰탕_설렁탕', '곱창구이', '곱창전골', '과메기', '김밥', '김치볶음밥', '김치전', '김치찌개', '김치찜', '깍두기', '깻잎장아찌', '꼬막찜', '꽁치조림', '꽈리고추무침', '꿀떡', '나박김치', '누룽지', '닭갈비', '닭계장', '닭볶음탕', '더덕구이', '도라지무침', '도토리묵', '동그랑땡', '동태찌개', '된장찌개', '두부김치', '두부조림', '땅콩조림', '떡갈비', '떡국_만두국', '떡꼬치', '떡볶이', '라면', '라볶이', '막국수', '만두', '매운탕', '멍게', '메추리알장조림', '멸치볶음', '무국', '무생채', '물냉면', '물회', '미역국', '미역줄기볶음', '배추김치', '백김치', '보쌈', '부추김치', '북엇국', '불고기', '비빔냉면', '비빔밥', '산낙지', '삼겹살', '삼계탕', '새우볶음밥', '새우튀김', '생선전', '소세지볶음', '송편', '수육', '수정과', '수제비', '숙주나물', '순대', '순두부찌개', '시금치나물', '시래기국', '식혜', '알밥', '애호박볶음', '약과', '약식', '양념게장', '양념치킨', '어묵볶음', '연근조림', '열무국수', '열무김치', '오이소박이', '오징어채볶음', '오징어튀김', '우엉조림', '유부초밥', '육개장', '육회', '잔치국수', '잡곡밥', '잡채', '장어구이', '장조림', '전복죽', '젓갈', '제육볶음', '조개구이', '조기구이', '족발', '주꾸미볶음', '주먹밥', '짜장면', '짬뽕', '쫄면', '찜닭', '총각김치', '추어탕', '칼국수', '코다리조림', '콩국수', '콩나물국', '콩나물무침', '콩자반', '파김치', '파전', '편육', '피자', '한과', '해물찜', '호박전', '호박죽', '홍어무침', '황태구이', '회무침', '후라이드치킨', '훈제오리'
]

@app.route("/")
def home():
    return "Food Classification API is running. Use /predict for single food or /multi_predict for multiple foods."

# 단일 음식 예측 엔드포인트
@app.route('/predict', methods=['POST'])
def predict_food():
    try:
        # 이미지 읽기
        if 'image' not in request.files:
            return jsonify({"error": "No image part in the request"}), 400

        file = request.files['image']
        if file.filename == '':
            return jsonify({"error": "No selected file"}), 400

        # 파일을 OpenCV로 읽기
        file_bytes = np.frombuffer(file.read(), np.uint8)
        img = cv2.imdecode(file_bytes, cv2.IMREAD_COLOR)

        if img is None:
            return jsonify({"error": "Image decoding failed"}), 400

        # 이미지 전처리
        img = cv2.cvtColor(img, cv2.COLOR_BGR2RGB)
        img_resized = cv2.resize(img, (299, 299))
        img_preprocessed = preprocess_input(img_resized)
        img_expanded = np.expand_dims(img_preprocessed, axis=0)

        # 예측 수행
        predictions = food_model.predict(img_expanded)[0]
        top_3_indices = predictions.argsort()[-3:][::-1]
        top_3_results = [
            {"class": classes[i], "confidence": f"{predictions[i]:.2%}"}
            for i in top_3_indices
        ]
        top_prediction = top_3_results[0]

        # 신뢰도 확인
        if predictions[top_3_indices[0]] >= 0.8:
            response = {"prediction": top_prediction, "top_3": None}
        else:
            response = {"prediction": None, "top_3": top_3_results}

        return jsonify(response)
    except Exception as e:
        print(f"Error during predict: {e}")
        return jsonify({"error": str(e)}), 500

@app.route('/multi_predict', methods=['POST'])
def multi_predict():
    try:
        # 이미지 읽기
        if 'image' not in request.files:
            return jsonify({"error": "No image part in the request"}), 400

        file = request.files['image']
        if file.filename == '':
            return jsonify({"error": "No selected file"}), 400

        # 파일을 OpenCV로 읽기
        file_bytes = np.frombuffer(file.read(), np.uint8)
        img = cv2.imdecode(file_bytes, cv2.IMREAD_COLOR)

        if img is None:
            return jsonify({"error": "Image decoding failed"}), 400

        # 원본 이미지 크기
        original_height, original_width = img.shape[:2]

        # 이미지 색상 변환 (BGR -> RGB)
        img_rgb = cv2.cvtColor(img, cv2.COLOR_BGR2RGB)

        # YOLO 모델로 탐지 수행 (원본 크기로)
        results = yolo_model(img_rgb, size=640)

        # 탐지된 객체 처리
        cropped_predictions = []
        for i, (*box, conf, cls) in enumerate(results.xyxy[0]):
            x1, y1, x2, y2 = map(int, box)
            conf = float(conf)
            cls_id = int(cls)

            # 좌표가 이미지 경계를 넘지 않도록 조정
            x1 = max(0, x1)
            y1 = max(0, y1)
            x2 = min(original_width, x2)
            y2 = min(original_height, y2)

            # 크롭된 이미지 추출
            crop_img = img[y1:y2, x1:x2]
            if crop_img.size == 0:
                continue

            # 색상 변환
            crop_img_rgb = cv2.cvtColor(crop_img, cv2.COLOR_BGR2RGB)

            # 원본 크기
            h, w = crop_img_rgb.shape[:2]

            # 입력 크기
            input_size = (299, 299)

            # 비율 유지하면서 리사이즈
            scale = min(input_size[0] / h, input_size[1] / w)
            new_w = int(w * scale)
            new_h = int(h * scale)
            resized_img = cv2.resize(crop_img_rgb, (new_w, new_h), interpolation=cv2.INTER_AREA)

            # 패딩 계산
            delta_w = input_size[1] - new_w
            delta_h = input_size[0] - new_h
            top, bottom = delta_h // 2, delta_h - (delta_h // 2)
            left, right = delta_w // 2, delta_w - (delta_w // 2)

            # 패딩 적용
            color = [0, 0, 0]
            padded_img = cv2.copyMakeBorder(resized_img, top, bottom, left, right, cv2.BORDER_CONSTANT, value=color)

            # 전처리
            img_preprocessed = preprocess_input(padded_img)
            img_expanded = np.expand_dims(img_preprocessed, axis=0)

            # 예측 수행
            prediction = food_model.predict(img_expanded)[0]
            top_class = classes[np.argmax(prediction)]
            top_confidence = np.max(prediction)

            # 결과 저장
            cropped_predictions.append({
                "class": top_class,
                "confidence": f"{top_confidence:.2%}"
            })

        # 결과 반환
        return jsonify({
            "cropped_predictions": cropped_predictions
        })
    except Exception as e:
        print(f"Error during multi_predict: {e}")
        return jsonify({"error": str(e)}), 500

# Flask 서버 실행
if __name__ == "__main__":
    app.run(host='0.0.0.0', port=5000)
