// categoryLabelMap.js

window.CategoryUtil = {
  // 치료 코드 → 대분류 카테고리 맵
  statusLabelMap: {
    // ✅ 예방
    "TFA": "예방",
    "SC": "예방",

    // ✅ 수복
    "Seal": "수복",
    "AF": "수복",
    "RF": "수복",
    "Gl": "수복",
    "SS": "수복",
    "Zr": "수복",

    // ✅ 외과
    "Ext": "외과",
    "oral": "외과",

    // ✅ 치수
    "Pulpo": "치수",
    "Pulpec": "치수",
    "Apexo": "치수",
    "Apexi": "치수",
    "RCT": "치수",

    // ✅ 전신마취
    "DOR": "전신마취",
    "MOR": "전신마취",

    // ✅ 교정
    "firstStraighten": "교정",
    "secondStraighten": "교정",
    "partialStraighten": "교정",
    "muscleFunction": "교정",

    // ✅ 공간유지장치
    "BL": "공간유지장치",
    "LA": "공간유지장치",
    "NHA": "공간유지장치",
    "RSM": "공간유지장치",

    // ✅ 진정
    "N2OSedation": "진정",
    "LASedation": "진정",
    "NHASedation": "진정",
    "RSMSedation": "진정"
  },

  // 함수로 반환 (없을 경우 "기타")
  getStatusLabel(value) {
    return this.statusLabelMap[value] || "기타";
  }
  
  
};
