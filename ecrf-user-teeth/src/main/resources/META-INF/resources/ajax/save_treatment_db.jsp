<%@ page contentType="text/plain; charset=UTF-8" import="java.util.*, java.text.*" %>
<%@ page import="java.util.Date" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="teeth.model.TreatmentHistory" %>
<%@ page import="teeth.service.TreatmentHistoryLocalServiceUtil" %>
<%@ page import="java.util.Date" %>
<%@ page contentType="text/plain; charset=UTF-8" %>

<%
    // 클라이언트에서 넘어온 파라미터 읽기
    String EditUserId       = request.getParameter("EditUserId");
    String treatmentDate   = request.getParameter("treatmentDate");
    String mainCategory    = request.getParameter("mainCategory");
    String selectedStatus  = request.getParameter("selectedStatus");
    String selectedTeeth1   = request.getParameter("selectedTeeth"); //teeth41,teeth42 이렇게 나옴
    String permanent  = request.getParameter("permanent");
    
    String selectedTeeth = selectedTeeth1.replaceAll("[^0-9,]", ""); //teeth41,teeth42 이렇게 나오는거 정제함
    
    
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
        
        String Status = mainCategory + "_" + selectedStatus;
        Date EditedDate = new Date(); 
        long patientId = 1001; //임시
        long TN = Long.parseLong(teethNumber);
        
        long UserId = Long.parseLong(EditUserId);
        
        // 저장
        TreatmentHistory TH = TreatmentHistoryLocalServiceUtil.AddHistory(patientId, TN, treatmentDateParsed, Status, permanent, EditedDate, UserId);

        if(TH == null)
        {
        	//대충 실패 메서드
        }
        else
        {
        	//대충 성공한거
        	out.print("치료 정보 저장 완료: " + teethNumber + "\n");
        }
        
        
        // 각 치아 번호별로 저장 완료 메시지 출력
        out.print("치료 정보 저장 완료: " + teethNumber + "\n");
    }
%>
