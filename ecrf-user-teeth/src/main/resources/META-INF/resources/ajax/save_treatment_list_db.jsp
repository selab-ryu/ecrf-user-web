<%@ page contentType="text/plain; charset=UTF-8" import="java.util.*, java.text.*" %>
<%@ page import="java.util.Date" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="teeth.model.TreatmentHistory" %>
<%@ page import="teeth.service.TreatmentHistoryLocalServiceUtil" %>
<%@ page import="teeth.model.TreatmentAudit" %>
<%@ page import="teeth.service.TreatmentAuditLocalServiceUtil" %>

<%
    // 요청 파라미터 받기 (treatment_1, treatment_2, ... 파라미터만 처리)
    Enumeration<String> paramNames = request.getParameterNames();
    
    // 치료 데이터 처리
    while (paramNames.hasMoreElements()) {
        String paramName = paramNames.nextElement();
        
        if (paramName.startsWith("treatment_")) {  // treatment_1, treatment_2, ... 파라미터만 처리
            // treatment_1, treatment_2, ...와 같은 이름의 파라미터 값 추출
            String treatmentData = request.getParameter(paramName);
            
            // 치료 데이터 출력 (디버깅용)
            System.out.println("수신된 치료 데이터: " + treatmentData);
            
            // 치료 데이터 파싱
            Map<String, String> treatmentParams = new HashMap<>();
            String[] dataParts = treatmentData.split("&");
            for (String part : dataParts) {
                String[] keyValue = part.split("=");
                if (keyValue.length == 2) {
                    treatmentParams.put(keyValue[0], keyValue[1]);
                }
            }

            // 파싱된 데이터 출력 (디버깅용)
            System.out.println("치료 데이터 파싱 결과: " + treatmentParams);
            
            // 파싱된 데이터 가져오기
            
            String EditUserId = treatmentParams.get("EditUserId");
            String treatmentDate = treatmentParams.get("treatmentDate");
            String mainCategory = treatmentParams.get("mainCategory");
            String selectedTreatment = treatmentParams.get("selectedTreatment");
            String selectedTeeth1 = treatmentParams.get("selectedTeeth"); // teeth14,Teeth15
            String State = treatmentParams.get("selectedState");

            if (State == null || State.trim().isEmpty()) {
                State = null;  // State 값이 없으면 null로 설정
            }
            if ("undefined".equals(State)) {
                State = null;  // 값이 "undefined"일 경우 null로 설정
            }
            
            // selectedTeeth 값을 URL 디코딩하여 쉼표로 분리
            String selectedTeeth = java.net.URLDecoder.decode(selectedTeeth1, "UTF-8");
            selectedTeeth = selectedTeeth.replaceAll("[^0-9,]", ""); // 숫자와 쉼표만 남기기
            
            // 치료일자 문자열 -> Date 변환
            Date treatmentDateParsed = null;
            try {
                treatmentDateParsed = new SimpleDateFormat("yyyy-MM-dd").parse(treatmentDate);
            } catch (Exception e) {
                out.print("날짜 파싱 오류: " + e.getMessage());
                return;
            }

            // 치아번호를 쉼표로 분리
            String[] teethNumbers = selectedTeeth.split(",");
            
            // 각 치아번호에 대해 ToothTreatment 객체 생성 및 저장
            for (String teethNumber : teethNumbers) {
                // 각 치아에 대해 Treatment ID 생성
                String Treatment = selectedTreatment;
                Date EditedDate = new Date(); 
                long patientId = 1001; //임시
                long TN = Long.parseLong(teethNumber);
                
                long UserId = Long.parseLong(EditUserId);
                
                // 저장
                TreatmentHistory TH = TreatmentHistoryLocalServiceUtil.AddHistory(patientId, TN, treatmentDateParsed, Treatment, State, EditedDate, UserId);
                TreatmentAudit audit = TreatmentAuditLocalServiceUtil.AddAudit(TN, UserId, treatmentDateParsed, "Add", "-" , Treatment );

                if(TH == null)
                {
                    //대충 실패 메서드
                }
                else
                {
                    //대충 성공한거
                    out.print("치료 정보 저장 완료: " + teethNumber + "\n");
                }
            }
        }
    }
    
    // 응답 메시지 전송
    out.print("치료 데이터 저장 완료.");
%>

