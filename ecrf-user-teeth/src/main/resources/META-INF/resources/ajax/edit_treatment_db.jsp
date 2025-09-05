<%@ page contentType="text/plain; charset=UTF-8" import="java.util.*, java.text.*" %>
<%@ page import="java.util.Date" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="teeth.model.TreatmentHistory" %>
<%@ page import="teeth.service.TreatmentHistoryLocalServiceUtil" %>
<%@ page import="teeth.model.TreatmentAudit" %>
<%@ page import="teeth.service.TreatmentAuditLocalServiceUtil" %>
<%@ page import="java.util.Date" %>
<%@ page contentType="text/plain; charset=UTF-8" %>

<%
    String editUserId = request.getParameter("EditUserId");
    String treatmentID = request.getParameter("treatmentID");
    String mainCategory = request.getParameter("mainCategory");
    String selectedStatus = request.getParameter("selectedStatus");
    String selectedTeeth = request.getParameter("selectedTeeth");
    String selectedPermanent = request.getParameter("selectedPermanent");

    // 콘솔에 출력 (서버 로그 확인용)
    System.out.println("=== Teeth Save Request ===");
    System.out.println("EditUserId: " + editUserId);
    System.out.println("treatmentID: " + treatmentID);
    System.out.println("mainCategory: " + mainCategory);
    System.out.println("selectedStatus: " + selectedStatus);
    System.out.println("selectedTeeth: " + selectedTeeth);
    System.out.println("selectedPermanent: " + selectedPermanent);

    // 클라이언트에 응답 (ajax success 콜백에 넘어감)
    out.print(
        "저장 완료:\n" +
        "EditUserId: " + editUserId + "\n" +
        "treatmentID: " + treatmentID + "\n" +
        "mainCategory: " + mainCategory + "\n" +
        "selectedStatus: " + selectedStatus + "\n" +
        "selectedTeeth: " + selectedTeeth + "\n" +
        "selectedPermanent: " + selectedPermanent
    );
    
    String Status = selectedStatus;
    Date EditedDate = new Date(); 
    long treatmentIdLong = Long.parseLong(treatmentID);
    long editUserIdLong = Long.parseLong(editUserId);
    long selectedTeethLong = Long.parseLong(selectedTeeth);
    
    TreatmentHistory Past = TreatmentHistoryLocalServiceUtil.getPatientTreatmentByTreatmentID(treatmentIdLong);
    String PastTreatment = Past.getTreatment();
    
    TreatmentHistory TH = TreatmentHistoryLocalServiceUtil.UpdateHistory(treatmentIdLong, Status, selectedPermanent, EditedDate, editUserIdLong);
    

    
    TreatmentAudit audit = TreatmentAuditLocalServiceUtil.AddAudit(selectedTeethLong, editUserIdLong, Past.getTreatmentDate(), "Edit", PastTreatment, Status);
    
    if(TH == null)
    {
    	//실패 메서드
    }
    else
    {
    	//성공한거
    	out.print("치료 정보 저장 완료: ");
    }
%>