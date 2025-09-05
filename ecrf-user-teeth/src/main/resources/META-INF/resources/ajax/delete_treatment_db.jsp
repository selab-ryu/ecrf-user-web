<%@include file="../init.jsp"%>
<%@ page import="com.liferay.portal.kernel.util.ParamUtil" %>
<%@ page import="com.liferay.portal.kernel.theme.ThemeDisplay" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.util.Date" %>
<%@ page import="java.util.List" %>
<%@ page import="teeth.model.TreatmentHistory" %>
<%@ page import="teeth.service.TreatmentHistoryLocalServiceUtil" %>
<%@ page import="teeth.model.TreatmentAudit" %>
<%@ page import="teeth.service.TreatmentAuditLocalServiceUtil" %>
<%@ page contentType="text/plain; charset=UTF-8" %>


<liferay-theme:defineObjects />

<%
	long userId = ParamUtil.getLong(request, "userId");
    long patientId = 1001; //ParamUtil.getLong(request, "patientId");
    String treatmentDateStr = ParamUtil.getString(request, "treatmentDate");
    String selectedStatus = ParamUtil.getString(request, "selectedStatus");
    String selectedTeeth1 = ParamUtil.getString(request, "selectedTeeth"); //teeth41,teeth42 이렇게 나옴
    
    String selectedTeeth = selectedTeeth1.replaceAll("[^0-9,]", ""); //teeth41,teeth42 이렇게 나오는거 정제함

    long selectedTreatmentID = ParamUtil.getLong(request, "selectedTreatmentID");
    
    System.out.println("삭제 요청 - userId: " + userId);
    System.out.println("삭제 요청 - 환자ID: " + patientId);
    System.out.println("삭제 요청 - 치료일자: " + treatmentDateStr);
    System.out.println("삭제 요청 - 상태: " + selectedStatus);
    System.out.println("삭제 요청 - 치아번호: " + selectedTeeth);
    System.out.println("삭제 요청 - 치아아이디: " + selectedTreatmentID);

    /*
    // 문자열 -> Date 변환
    Date treatmentDate = null;
    try {
        // 1) 입력 포맷에 맞춰 파서 생성
        SimpleDateFormat inputFmt  = new SimpleDateFormat("M/d/yyyy");
        // 2) 실제 파싱
        treatmentDate = inputFmt.parse(treatmentDateStr);

        // (선택) "yyyy-MM-dd" 문자열이 필요하다면
        SimpleDateFormat outputFmt = new SimpleDateFormat("yyyy-MM-dd");
        String formatted = outputFmt.format(treatmentDate);
        out.print("파싱된 Date → " + treatmentDate);
        out.print("다시 포맷한 문자열 → " + formatted);
        
        // 이제 treatmentDate 는 올바른 Date 객체이고,
        // formatted 는 "2025-04-02" 같은 문자열입니다.

    } catch (Exception e) {
        out.print("날짜 파싱 오류: " + e.getMessage());
        return;
    }
    */
    long teethNum = Long.parseLong(selectedTeeth);
    
    String Status = selectedStatus;
    //이걸로 업데이트
    
    
    
    
    // 해당 조건의 치료 내역 검색
    
    
    TreatmentHistory treatment = TreatmentHistoryLocalServiceUtil. getPatientTreatmentByTreatmentID(selectedTreatmentID);
    
    boolean deleted = false;

    treatment = TreatmentHistoryLocalServiceUtil.deleteTreatmentHistory(selectedTreatmentID);
    TreatmentAudit audit = TreatmentAuditLocalServiceUtil.AddAudit(teethNum, userId, treatment.getTreatmentDate(), "delete", Status, "-");
    
    if(treatment == null)
    {
    	deleted = true;
        out.print("치료 내역 삭제 완료\n");
    }

    if (!deleted) {
        out.print("일치하는 치료 내역 없음\n");
    }
%>
