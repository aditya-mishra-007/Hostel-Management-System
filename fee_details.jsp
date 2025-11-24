<%@ page import="java.sql.*" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
<head>
    <title>Fee Details</title>
    <style>
        table {
            width: 80%;
            border-collapse: collapse;
            margin: 20px auto;
        }
        th, td {
            padding: 10px;
            border: 1px solid #333;
            text-align: center;
        }
        th {
            background-color: #f2f2f2;
        }
        .PAID { color: green; font-weight: bold; }
        .PENDING { color: orange; font-weight: bold; }
        .OVERDUE { color: red; font-weight: bold; }
    </style>
</head>
<body>
<h2 style="text-align:center;">Hostel Fee Details</h2>

<%
    // Database connection parameters
    String url = "jdbc:mysql://localhost:3306/hostel_db";
    String username = "root";
    String password = "admin";

    Connection conn = null;
    Statement stmt = null;
    ResultSet rs = null;

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection(url, username, password);

        String query = "SELECT * FROM fee_records ORDER BY student_id, due_date";
        stmt = conn.createStatement();
        rs = stmt.executeQuery(query);
%>

<table>
    <tr>
        <th>Fee ID</th>
        <th>Student ID</th>
        <th>Semester Fee</th>
        <th>Paid Amount</th>
        <th>Due Date</th>
        <th>Paid Date</th>
        <th>Status</th>
    </tr>

<%
        SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
        while (rs.next()) {
            int feeId = rs.getInt("fee_id");
            int studentId = rs.getInt("student_id");
            double semesterFee = rs.getDouble("semester_fee");
            double paidAmount = rs.getDouble("paid_amount");
            Date dueDate = rs.getDate("due_date");
            Date paidDate = rs.getDate("paid_date");
            String status = rs.getString("status");
%>
    <tr>
        <td><%= feeId %></td>
        <td><%= studentId %></td>
        <td><%= String.format("%.2f", semesterFee) %></td>
        <td><%= String.format("%.2f", paidAmount) %></td>
        <td><%= sdf.format(dueDate) %></td>
        <td><%= (paidDate != null) ? sdf.format(paidDate) : "-" %></td>
        <td class="<%=status%>"><%= status %></td>
    </tr>
<%
        }
    } catch(Exception e){
        out.println("<p style='color:red;text-align:center;'>Error: " + e.getMessage() + "</p>");
    } finally {
        try { if(rs != null) rs.close(); } catch(Exception e) {}
        try { if(stmt != null) stmt.close(); } catch(Exception e) {}
        try { if(conn != null) conn.close(); } catch(Exception e) {}
    }
%>
</table>
</body>
</html>
