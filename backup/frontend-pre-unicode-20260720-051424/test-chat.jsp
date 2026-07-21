<%@ page pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" language="java" %>
<%@ page import="Model.ChatDAO" %>
<%@ page import="java.io.PrintWriter" %>
<%@ page import="java.io.StringWriter" %>
<%
    try {
        ChatDAO dao = new ChatDAO();
        // hardcode some ids or just print test
        out.println("ChatDAO instantiated.<br/>");
        int convId = dao.getOrCreateDirectConversation(1, 2);
        out.println("Result: " + convId + "<br/>");
    } catch (Exception e) {
        StringWriter sw = new StringWriter();
        e.printStackTrace(new PrintWriter(sw));
        out.println("<pre>" + sw.toString() + "</pre>");
    }
%>
