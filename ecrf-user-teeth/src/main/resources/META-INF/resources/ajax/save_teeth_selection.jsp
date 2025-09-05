<%@ page contentType="text/plain; charset=UTF-8" %>
<%
    String teeths = request.getParameter("teeths");

    // 필요한 처리: 세션 저장, 로그, DB 저장 등
    //System.out.println("선택된 치아들: " + teeths);

    // 응답 메시지 전송
    out.print("선택된 치아 저장 완료: " + teeths);
%>
