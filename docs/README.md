# 🌟 **AI 기반 식단 분석 및 관리 플랫폼**  
### 🍽️ *2024-02-CSC4004-1-1-BabsangLab*<br><br>

**팀장:** 박세환<br>
**팀원:** 안여진, 윤현동, 이정섭<br><br>
---
## 📖 **프로젝트 소개**
**AI 기반 식단 분석 및 관리 플랫폼**은 사용자의 식단을 쉽고 효과적으로 관리할 수 있도록 돕는 서비스입니다.  
- 📸 음식 사진을 업로드하면 **AI 모델**이 자동으로 음식의 이름과 영양 정보를 분석합니다.  
- 🛡️ **알레르기 예방** 기능으로 안전한 식사를 지원합니다.  
- 🥗 맞춤형 식단 추천을 통해 건강 관리를 효율적으로 돕습니다.  
- 🇰🇷 **한국 음식**에 특화된 데이터베이스로 국내 사용자에게 최적화된 서비스를 제공합니다.<br><br>
### 💡 **주요 기능**
- **AI 모델 기반 음식 분석:** YOLOv5와 InceptionV3를 활용한 정확한 음식 탐지 및 분류  
- **다중 음식 탐지:** 한 사진에 여러 음식이 포함된 경우도 인식 가능  
- **맞춤형 추천:** 사용자 신체 정보와 섭취 기록을 바탕으로 최적의 식단 추천  
- **알레르기 관리:** 알레르기 유발 성분을 포함한 음식 경고 및 대체 음식 추천<br><br>  
### 💡 **앱 화면 예시**
<p align="center">
  <img src="https://github.com/CSID-DGU/2024-02-CSC4004-1-1-BabsangLab/blob/main/docs/image1.jpg" alt="앱 메인 화면" width="30%" />
  <img src="https://github.com/CSID-DGU/2024-02-CSC4004-1-1-BabsangLab/blob/main/docs/image2.jpg" alt="앱 결과 화면" width="30%" />
</p>

## 📂 **폴더 구조**

- **2024-02-CSC4004-1-1-BabsangLab/**
  - **BabsangLab/**  
    iOS 프로젝트 파일 (실행 가능한 .ipa 파일 포함)
  - **data/**  
    데이터베이스 및 관련 파일
    - **DB/**  
      데이터베이스 백업 파일
  - **docs/**  
    프로젝트 문서
    - **README.md**  
      프로젝트 설명 파일
  - **gradle/**  
    Gradle 관련 파일
  - **scripts/**  
    실행 스크립트 및 빌드 관련 파일
  - **src/**  
    소스 코드
    - **frontend/**  
      iOS 앱 관련 코드
    - **backend/**  
      Spring Boot 백엔드 코드
    - **ai/**  
      AI 모델 학습 및 서버 코드
  - **Dockerfile**  
    Docker 설정 파일
  - **README.md**  
    프로젝트 설명 문서
  - **settings.gradle**  
    Gradle 설정 파일
  - **.gitignore**  
    Git 무시 파일 설정

## 🛠️ **브랜치 구성**
### **1. `main` 브랜치**  
> **📌 통합 브랜치**  
> - 프론트엔드, AI 모델, 백엔드 기능이 포함된 통합 브랜치  
---
### **2. `ai-model` 브랜치**  
> **📸 AI 모델 관련 브랜치**  
> - YOLOv5와 InceptionV3 모델 학습 및 테스트 코드  
> - 학습된 모델(`final_model.h5`) 배포를 위한 Flask 서버 코드 포함  
---
### **3. `api-upgrade` 브랜치**  
> **🌐 백엔드 API 개발 브랜치**  
> - Spring Boot를 활용한 백엔드 API 개발  
> - 사용자 정보, 식단 기록, 알레르기 정보 등 데이터 처리 로직 구현  
> - RESTful API 설계 및 테스트  
---
### **4. `front-end` 브랜치**  
> **📱 iOS 앱 개발 브랜치**  
> - Swift와 UIKit을 활용한 iOS 앱 UI/UX 구현  
> - 사용자가 사진을 업로드하고 분석 결과를 확인할 수 있는 인터페이스 제공  
---
## 🌍 **프로젝트 배포**
 
- Flask 서버를 통해 Google Cloud Platform(GCP)에 AI 모델을 배포하여 실시간 요청을 처리합니다.  
- Spring Boot 기반 백엔드를 Google Cloud Platform(GCP)에 배포하여 안정적으로 데이터 처리를 지원합니다.  
- iOS 앱은 AltStore를 통해 배포되었습니다. 

1. **Mac에 AltServer 설치:** AltServer를 설치하고 필요한 설정을 완료합니다.  
2. **.ipa 파일 다운로드:** Babsanglab 폴더 내에 배포된 최종 .ipa 파일을 AltStore를 통해 설치하여 테스트할 수 있습니다.

